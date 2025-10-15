import { ErrorCode, Player, PlayerError, PlayerEvent, TimeMode } from 'bitmovin-player';
import { I18n, i18n, UIManager } from 'bitmovin-player-ui';
import { defaultUiConfig } from '../../src/bitmovin/ui/config/defaultUiConfig';
import VideoPlayerEvents from './VideoPlayerEvents';
import Logger from './../Logger';
import VoiceOverAccessibility from './VoiceOverAccessibility';

const logger = new Logger();

class VideoPlayer {
    static STATUS_NONE = null;                  // Inital state when loaded
    static STATUS_ERROR = 'error';              // error state
    static STATUS_INITALIZED = 'initalized';    // player initalized
    static STATUS_LOADING = 'loading';          // video loading
    static STATUS_LOADED = 'loaded';            // video loaded
    static STATUS_READY = 'ready';              // player has enough data to start playback
    static STATUS_PLAY = 'play';                // play button hit
    static STATUS_PLAYING = 'playing';          // video playing 
    static STATUS_PAUSED = 'paused';            // video paused by user
    static STATUS_STOPPED = 'stopped';          // video stopped by user
    static STATUS_FINISHED = 'finished';        // video finished playing

    constructor(config) {
      this.events = VideoPlayerEvents;
      this.config = config;
      this.playerElement = document.getElementById(config.playerElementId);
      this.videoId = config.eventId;
      this.player = null;
      this.state = {
        status: this.STATUS_NONE
      };
      this.volume = config.volume;
      this.muted = config.muted;
      this.playCallback = config.playCallback;

      // The position where the stream should be started.
      this.startOffset = config.startOffset === undefined ? 0 : config.startOffset;

      if (typeof config.refreshFunction === 'function') {
        this.refreshFunction = config.refreshFunction;
      }

      this.isSeekbarDisplayed = true; // Default: Seekbar is shown

      let localizationConfig = null;
      if (this.config.playerControls) {
        localizationConfig= {
          language: 'gm',
          vocabularies: {
            gm:this.config.playerControls
          }
        };
      }
      
      let analyticsConfig = {
        key: this.config.isTE ? 'fd8eaee5-45f7-4ab3-a75b-5453a72be355' : '5a27f534-b907-4190-8244-9040a45ddfbb',
        title: '',
        videoId: this.videoId,
        customUserId: this.config.ui,
      }

      if (this.config.customData) {
        if (Array.isArray(this.config.customData)) {
          for (let idx = 0; idx < this.config.customData.length; idx++) {
            analyticsConfig['customData' + (idx + 1)] = this.config.customData[idx];
          }
        } else {
          analyticsConfig.customData1 = this.config.customData;
        }
      }

      this.playerConfig = {
        key: this.config.isTE ? '9bd69163-f3da-459f-b53a-3fd3a514a7a0' : '2994c75f-d1d0-46fa-abf0-d1d785f81e3a',
        analytics: analyticsConfig,
        playback: {
          autoplay: true,
          muted: this.muted,
          volume: this.volume,
        },
        logs: {
          level: config.logLevel
        },
        ui: false,
        adaptation: {
          //intentionally set low so the first loaded bitrate will be the lowest available
          startupBitrate: 1000
        },
      }

      if (typeof this.config.httpInterceptFunction === 'function') {
        this.playerConfig.network = {
          sendHttpRequest: this.config.httpInterceptFunction
        }
      }

      if (localizationConfig != null) {
        this.playerConfig.i18n = i18n.setConfig(localizationConfig);
      }

      this.player = new Player(this.playerElement, this.playerConfig);
      
      let videoElement = document.getElementById(this.config.playerVideoElementId);
      if (videoElement instanceof HTMLVideoElement) {
        this.player.setVideoElement(videoElement);
      }

      let uiManager = new UIManager(this.player, defaultUiConfig);
      
      // Initialize VoiceOver accessibility module
      this.voiceOverAccessibility = new VoiceOverAccessibility(this.player, this.config);
      this.voiceOverAccessibility.setVolumeLiveStatusCallback(this.setVolumeLiveStatus.bind(this));
      
      this.setupEventListeners();
      this.setStopOrPauseIcons();
      this.setStatus(VideoPlayer.STATUS_INITALIZED);
    }

    isLiveOrPrelive() {
      return (this.config.isPreSimLive || this.config.isSimlive || this.config.mode == "prelive" || this.config.mode == "live");
    }

    setStopOrPauseIcons(){
        if(this.isLiveOrPrelive()){
            document.getElementById("ui-container-controlbar").classList.add("liveEvent");
        }
    }


    createEvent(event, data) {
        return new CustomEvent(event, {detail: data});
    }

    dispatchEvent(event, data) {
        var customEvent = this.createEvent(event, data);
        document.dispatchEvent(customEvent);
    }

    play(callback) {
      document.getElementById('playback-toggle-button').style.display = 'block';
      document.getElementById('playback-pause-button').style.display = 'block';
      
      if (this.player.isPlaying()) {
        document.getElementById('playback-toggle-button').style.display = 'none';
        return;
      } else if (!this.isStreamLoaded()) {
        if (this.playTimeout == null) {
          this.playTimeout = setTimeout(() => {
              this.playTimeout = null;
              this.play(callback);
            }, 100);
        }
      } else {
        if (this.getStatus !== VideoPlayer.STATUS_PLAY) {
          this.setStatus(VideoPlayer.STATUS_PLAY);
          this.player.play().then(() => {
            if (typeof callback === 'function') {
              callback();
            } else if (typeof this.playCallback === 'function') {
              this.playCallback();
            }
            this.setStatus(VideoPlayer.STATUS_PLAYING);
          }).catch((error) => {
              this.setStatus(VideoPlayer.STATUS_ERROR);
              console.error(error);
          });
        }
      }
    }
  
    pause() {
      if (this.player.isPlaying()) {
        this.player.pause();
      }
    }
  
    load(uri, title, startOffset, captionsJSON=null) {
      this.setStatus(VideoPlayer.STATUS_LOADING);

      // Set optional captions to be used in SourceLoaded event handler
      this.captionsJSON = captionsJSON;

      let qualityLabelingFunction = typeof this.config.qualityLabelingFunction === 'function' ? this.config.qualityLabelingFunction : this.defaultQualityLabeling;
      let source = {
        title: (title === undefined) ? this.config.title : title,
        hls: uri,
        labeling: {
          hls: {
            qualities: qualityLabelingFunction
          }
        }
      }

      if (typeof startOffset !== 'undefined' && startOffset > 0) {
        // Add startOffset to source config
        source.options = {startOffset: startOffset};
      }
      logger.info("VideoPlayer.load: isStreamLoaded=" + this.isStreamLoaded() + " sourceConfig=" + JSON.stringify(source));

      this.player.load(source).then((res) => this.setStatus(VideoPlayer.STATUS_LOADED)).catch((error) => this.playerLoadErrorHandler(error));

      this.source = source.hls;

      logger.debug(`BitmovinPlayer::load()`);
      logger.debug(`Title: ${source.title}`);
      logger.debug(`URI: ${source.hls}`);
    }

    playerLoadErrorHandler(error) {
      logger.warn("playerLoadErrorHandler; code=" + error.code + " name=" + error.name + " message=" + error.message 
                    + " data=" + JSON.stringify(error.data));
      
      this.dispatchEvent(VideoPlayerEvents.EVENT_SOURCE_LOAD_ERROR, error);
    }

    //Use live stream labeling logic if no custom function is provided.
    defaultQualityLabeling(quality) {
      let kbps = quality.bitrate / 1000;

      if (kbps <= 830) {
        return "270p";
      }
      if (kbps <= 1080) {
        return "480p";
      }
      if (kbps <= 1980) {
        return "720p";
      }
      return '1080p';
    }

    getVideoPlayerEvents() {
      return this.events;
    }

    getState() {
        return this.state;
    }

    getStatus() { 
        return this.state.status;
    }
    
    setStatus(status) {
        this.state.status = status;
    }

    getSource() {
      return this.source;
    }

    // resize player
    resize(width, height) {

    }

    // hide video, continue playing audio
    hideVideo() {
      const playerVdo = document.getElementById("playerVdo");
        if (playerVdo) {
          playerVdo.style.display = "none";
        }
    }

    // show video
    showVideo() {
      const playerVdo = document.getElementById("playerVdo");
        if (playerVdo) {
          playerVdo.style.display = "";
        }

    }

    setPosition(position) {
      this.player.seek(position);
    }

    getPosition() {
        
    }

    toggleSeekBar(display){
        if(display){
            this.showSeekBar();
        } else {
            this.hideSeekBar();
        }
    }

    showControls() {
        const controlBar = document.getElementById("control-bar-container");
        if (controlBar) {
            controlBar.classList.remove('hideViewerElements');
        }
    }

    hideControls() {
        const controlBar = document.getElementById("control-bar-container");
        if (controlBar) {
            controlBar.classList.add('hideViewerElements');
        }
    }

    hideSettingsPanel() {
      const settingsPanel = document.getElementById("settings-panel");
      if (settingsPanel) {
        settingsPanel.classList.add('bmpui-hidden');
      }
    }

    showSeekBar() {
        const seekBar = document.getElementById("seek-bar-component");
        if (seekBar) {
            seekBar.classList.remove('hideViewerElements');
            this.isSeekbarDisplayed = true; //Update state
        }
    }

    hideSeekBar() {
        const seekBar = document.getElementById("seek-bar-component");
        if (seekBar) {
            seekBar.classList.add('hideViewerElements');
            this.isSeekbarDisplayed = false; //Update state
        }
        
    }

    hidePlaybackSpeed() {
        const videoSpeedSelect = document.getElementById("video-speed-selectbox");
        if (videoSpeedSelect) {
            videoSpeedSelect.classList.add('hideViewerElements');
        }
    }

    showTime() {
        const playbackCurrTime = document.getElementById("playback-curr-time-label");
        if (playbackCurrTime) {
          playbackCurrTime.classList.remove('hideViewerElements');
        }

        const playbackTotalTime = document.getElementById("playback-total-time-label");
        if (playbackTotalTime) {
          playbackTotalTime.classList.remove('hideViewerElements');
        }
    }

    showTotalTime() {
        const playbackTotalTime = document.getElementById("playback-total-time-label");
        if (playbackTotalTime) {
          playbackTotalTime.classList.remove('hideViewerElements');
        }
    }

    hideTime() {
        const playbackCurrTime = document.getElementById("playback-curr-time-label");
        if (playbackCurrTime) {
          playbackCurrTime.classList.add('hideViewerElements');
        }

        const playbackTotalTime = document.getElementById("playback-total-time-label");
        if (playbackTotalTime) {
          playbackTotalTime.classList.add('hideViewerElements');
        }
    }

    // Getter for playback-pause-button
    get playbackPauseButton() {
        return document.getElementById("playback-pause-button");
    }

    hidePlaybackToggleButton() {
        const playPauseButton = this.playbackPauseButton;
        if (playPauseButton) {
            playPauseButton.classList.add('hideViewerElements');
        }
        const playbackToggle = document.getElementById("playback-toggle-button");
        if (playbackToggle) {
            playbackToggle.classList.add('hideViewerElements');
        }
    }
    
    hideFullscreenToggleButton() {
        const fullscreenButton = document.getElementById("fullscreen-button");
        if (fullscreenButton) {
            fullscreenButton.classList.add('hideViewerElements');
        }
    }

    showFullscreenToggleButton() {
        const fullscreenButton = document.getElementById("fullscreen-button");
        if (fullscreenButton) {
            fullscreenButton.classList.remove('hideViewerElements');
        }
    }

    hideSettingsButton() {
      const playerSettingsBtn = document.getElementById("player-settings-button");
      if (playerSettingsBtn) {
        playerSettingsBtn.style.visibility = "hidden";
      }
    }

  showSettingsButton() {
    const playerSettingsBtn = document.getElementById("player-settings-button");
      if (playerSettingsBtn) {
        playerSettingsBtn.style.visibility = "visible";
      }
    }

    hideAudioBackupToggleButton() {
      const audioToggleButton = document.getElementById("toggleAudio");
      if (audioToggleButton) {
        audioToggleButton.classList.add('bmpui-hidden');
        //audioBackupToggleButton.classList.add("ui-helper-hidden");
      }
  }

    showAudioBackupToggleButton() {
      const audioToggleButton = document.getElementById("toggleAudio");
      if (audioToggleButton) {
        audioToggleButton.classList.remove('bmpui-hidden');
        //audioBackupToggleButton.classList.remove("ui-helper-hidden");
      }
    }

    makeUserAudioBackup() {
      // userAudioBackup is a LiveStudio setting for encoder events that allows
      // viewers to switch to a backup audio stream.

      /*
      const audioBackupToggleButton = document.getElementById("toggleAudioButton");
      if (audioBackupToggleButton) {
        audioBackupToggleButton.querySelector('span').innerText = "Switch to Video Stream";
      }

      audioBackupToggleButton.classList.remove("bmpui-hidden");
      */

      const fullscreenButton = document.getElementById("fullscreen-button");
      if (fullscreenButton) {
        fullscreenButton.style.display = "none";
      }

      // make the control bar visible so that user can switch back to video
      const controlBar = document.getElementById("ui-container-controlbar");
      if (controlBar) {
        controlBar.style.display = "block";
      }

      //this.showControls();
      this.hidePlaybackSpeed();
      this.hideQualitySelectDropdown();
    }

    makeUserAudioBackupLoadError() {
      // userAudioBackup is a LiveStudio setting for encoder events that allows
      // viewers to switch to a backup audio stream.

      logger.debug("makeUserAudioBackupLoadError");

      const fullscreenButton = document.getElementById("fullscreen-button");
      if (fullscreenButton) {
        fullscreenButton.style.display = "none";
      }

      // hide the bitmovin tv noise canvas displayed when a load stream fails
      const bmpuiId43 = document.getElementById("bmpui-id-43");
      if (bmpuiId43) {
        bmpuiId43.style.display = "none";
      }

      // make the control bar visible so that user can switch back to video
      const controlBar = document.getElementById("ui-container-controlbar");
      if (controlBar) {
        controlBar.style.display = "block";
      }

      //this.showControls();
      this.hidePlaybackSpeed();
      this.hideQualitySelectDropdown();
    }

    makeAudio() {
      const fullscreenButton = document.getElementById("fullscreen-button");
      if (fullscreenButton) {
        fullscreenButton.style.display = "none";
      }
  
      const playerSettingsBtn = document.getElementById("player-settings-button");
      if (playerSettingsBtn) {
        playerSettingsBtn.style.visibility = "hidden";
      }
    }
  
    makeVideo() {
      const fullscreenButton = document.getElementById("fullscreen-button");
      if (fullscreenButton) {
        fullscreenButton.style.display = "block";
      }
  
      const playerSettingsBtn = document.getElementById("player-settings-button");
      if (playerSettingsBtn) {
        playerSettingsBtn.style.visibility = "visible";
      }
    }

    isStreamLoaded() {
      return this.player.getSource() != null;
    }

    isPlaying() {
      return this.player.isPlaying();
    }

    isPaused() {
      return this.player.isPaused();
    }

    getDuration() {
      return this.player.getDuration();
    }

    showQualitySelectDropdown() {
      const videoQualitySelect = document.getElementById("video-quality-selectbox");
      if (videoQualitySelect) {
        videoQualitySelect.classList.remove('hideViewerElements');
      }
    }

    hideQualitySelectDropdown() {
      const videoQualitySelect = document.getElementById("video-quality-selectbox");
      if (videoQualitySelect) {
        videoQualitySelect.classList.add('hideViewerElements');
      }
    }

    shouldShowSettingsButton(){
      return document.getElementById('speed-select-box').offsetParent === null &&
      document.getElementById('video-quality-selectbox').offsetParent === null &&
      document.getElementById('video-subtitle-selectbox').offsetParent === null &&
      document.getElementById('toggleAudio').offsetParent === null
    }

    shouldShowSettingsButtonForAudioEvent(){
      return document.getElementById('video-subtitle-selectbox').offsetParent === null
    }

     // Helper method for platform check
    isMobilePlatform() {
        return this.config.OS_PLATFORM === 'iOS' || this.config.OS_PLATFORM === 'Android';
    }
	
	  setLiveStatus(statusText) {
		  const liveRegion = document.getElementById('player-status-live');
		  if (liveRegion) {
			  liveRegion.textContent = statusText;
		  }
	  }
    setVolumeLiveStatus(statusText) {
      const volumeLiveRegion = document.getElementById('player-volume-live');
      if (volumeLiveRegion) {
        volumeLiveRegion.textContent = statusText;
      }
    }

    //Gets absolute time of stream. This will be EXT-X-PROGRAM-DATE-TIME from live HLS streams if present.
    getCurrentMediaTime() {
      return this.player.getCurrentTime(TimeMode.AbsoluteTime);
    }

    isLive() {
      return this.player.isLive();
    }

    showErrorMsg(msg) {
      let errorElem = document.getElementsByClassName('bmpui-ui-errormessage-label')[0];
      if (typeof errorElem != 'undefined' && errorElem != null) {
        errorElem.textContent = msg;
        errorElem.style.display = 'inline';
      }
    }

    setupEventListeners() {
        logger.debug('BitmovinPlayer::setupEventListeners()');     

        this.player.on(PlayerEvent.Play, (playEvent) => {
            logger.debug(`PlayerEvent.Play`);
            this.setStatus(VideoPlayer.STATUS_PLAY);
			      this.setLiveStatus('Playing');
            const playButton = this.playbackPauseButton;
            if (playButton && this.isLiveOrPrelive()){
              playButton.setAttribute('alt', 'Stop');
              playButton.setAttribute('title', 'Stop');
              playButton.removeAttribute('aria-label');
              playButton.removeAttribute('aria-pressed');
			        playButton.setAttribute('aria-disabled', 'false');
            }else if(playButton){
              playButton.setAttribute('alt', 'Pause');
              playButton.setAttribute('title', 'Pause');
              playButton.removeAttribute('aria-label');
              playButton.removeAttribute('aria-pressed');
			        playButton.setAttribute('aria-disabled', 'false');
            }
            this.dispatchEvent(VideoPlayerEvents.EVENT_PLAY, playEvent);
        });

        this.player.on(PlayerEvent.Playing, (playingEvent) => {
            
            logger.debug(`PlayerEvent.Playing`);
            this.setStatus(VideoPlayer.STATUS_PLAYING);
			      this.setLiveStatus('Playing');
            const pauseButton = this.playbackPauseButton;
            if (pauseButton && this.isLiveOrPrelive()){
              pauseButton.setAttribute('alt', 'Stop');
              pauseButton.setAttribute('title', 'Stop');
              pauseButton.removeAttribute('aria-label');
              pauseButton.removeAttribute('aria-pressed');
			        pauseButton.setAttribute('aria-disabled', 'false');
            }else if(pauseButton){
              pauseButton.setAttribute('alt', 'Pause');
              pauseButton.setAttribute('title', 'Pause');
              pauseButton.removeAttribute('aria-label');
              pauseButton.removeAttribute('aria-pressed');
			        pauseButton.setAttribute('aria-disabled', 'false');
            }
            this.dispatchEvent(VideoPlayerEvents.EVENT_PLAYING, playingEvent);
        });

        this.player.on(PlayerEvent.Paused, (pausedEvent) => {
            
            logger.debug(`PlayerEvent.Paused`);
            this.setStatus(VideoPlayer.STATUS_PAUSED);
			      this.setLiveStatus('Stopped');
            const playButton = this.playbackPauseButton;
            if (playButton) {
              playButton.setAttribute('alt', 'Play');
              playButton.setAttribute('title', 'Play');
			        playButton.removeAttribute('aria-label');
              playButton.removeAttribute('aria-pressed');
			        playButton.setAttribute('aria-disabled', 'false');
            }
            this.dispatchEvent(VideoPlayerEvents.EVENT_PAUSED, pausedEvent);
        });

        this.player.on(PlayerEvent.Error, (errorEvent) => {
            logger.debug(`PlayerEvent.Error`);
            const errorMessage = document.querySelector('.bmpui-ui-errormessage-label')
            if (errorMessage) {
                errorMessage.style.display = 'none';
                logger.warn("The downloaded manifest is invalid -- SOURCE_MANIFEST_INVALID");
            } else {
                this.setStatus(VideoPlayer.STATUS_ERROR);
                this.dispatchEvent(VideoPlayerEvents.EVENT_ERROR, errorEvent);
            }   
        });

        this.player.on(PlayerEvent.Unmuted, (unmuteEvent) => {
            logger.debug(`PlayerEvent.Unmuted`);
            this.setVolumeLiveStatus('Unmuted');
            const unmuteButton = document.getElementById("volume-toggle-button");
            if (unmuteButton) {
                unmuteButton.setAttribute('title', this.config.playerControls['settings.audio.mute']);
            }
            this.dispatchEvent(VideoPlayerEvents.EVENT_UNMUTED, unmuteEvent);
        });

        this.player.on(PlayerEvent.Muted, (muteEvent) => {
            logger.debug(`PlayerEvent.Muted`);
            this.setVolumeLiveStatus('Muted');
            const muteButton = document.getElementById("volume-toggle-button");
            if (muteButton) {
                muteButton.setAttribute('title', this.config.playerControls['settings.audio.unmute']);
            }
            this.dispatchEvent(VideoPlayerEvents.EVENT_MUTED, muteEvent);
        });

        this.player.on(PlayerEvent.VolumeChanged, (event) => {
          // Get the current volume from the player API
           const currentVolume = this.player.getVolume(); // returns 0.0 - 1.0
            this.setVolumeLiveStatus(`Volume: ${Math.round(currentVolume)} percent`);
        });

        this.player.on(PlayerEvent.PlayerResized, (resizedEvent) => {
            logger.debug(`PlayerEvent.Resized`);
            const resizedButton = document.getElementById("fullscreen-button");
            if (resizedButton) {
                if (resizedButton.classList.contains('bmpui-off')) {
                  resizedButton.setAttribute('title', this.config.playerControls.fullscreen);
                } else if (resizedButton.classList.contains('bmpui-on')) {
                  resizedButton.setAttribute('title', this.config.playerControls.exitfullscreen);
                }
            }
        });

        this.player.on(PlayerEvent.Ready, (readyEvent) => {

            //maintain seekbar visibility when player is ready
            logger.debug(`BitmovinPlayer::Ready - Seekbar: ${this.isSeekbarDisplayed}`);
            this.toggleSeekBar(this.isSeekbarDisplayed);           
            const PlayPauseButton = document.getElementById('playback-pause-button');            
            if (PlayPauseButton) {
                if (PlayPauseButton.classList.contains('bmpui-off')) {
                  PlayPauseButton.setAttribute('title', this.config.playerControls.play); 
				          PlayPauseButton.removeAttribute('aria-label');
                  PlayPauseButton.removeAttribute('aria-pressed');
			            PlayPauseButton.setAttribute('aria-disabled', 'false');
                } else if (PlayPauseButton.classList.contains('bmpui-on')) {
                  PlayPauseButton.setAttribute('title', 'Stop');
				          PlayPauseButton.removeAttribute('aria-label');
                  PlayPauseButton.removeAttribute('aria-pressed');
			            PlayPauseButton.setAttribute('aria-disabled', 'false');
                }
            }

            const targetElement = document.getElementById('playback-pause-button');
            const refreshButton = document.getElementById("refresh-button");
            if (refreshButton) {
                refreshButton.setAttribute('title', this.config.playerControls.replay);
             }
            const UnmuteButton = document.getElementById("volume-toggle-button");
            if (UnmuteButton) {
                if (this.config.muted) {
                  UnmuteButton.setAttribute('title', this.config.playerControls['settings.audio.unmute']);
                } else {
                  UnmuteButton.setAttribute('title', this.config.playerControls['settings.audio.mute']);
                }
            }
            const settingsButton = document.getElementById("player-settings-button");
            if (settingsButton) {
                settingsButton.setAttribute('title', this.config.playerControls.settings);
            }
            const volumeButton = document.getElementById("volume-slider");
            if (volumeButton) {
                volumeButton.setAttribute('title', this.config.playerControls['settings.audio.volume']);
            }
            const resizeButton = document.getElementById("fullscreen-button");
            if (resizeButton) {
                resizeButton.setAttribute('title', this.config.playerControls.fullscreen);
            }
            
            if (targetElement && !refreshButton) {
                const replayButton = document.createElement('button');
                replayButton.id = 'refresh-button';
                replayButton.title = this.config.playerControls.replay;
                replayButton.classList.add('bmpui-ui-replaybutton');
                targetElement.parentNode.insertBefore(replayButton, targetElement.nextSibling);
                const player = this.player;
                replayButton.addEventListener('click', () => {
                  if (typeof this.refreshFunction === 'function') {
                    this.refreshFunction(this.getSource());
                  } else {
                    this.player.load(this.player.getSource());
                  }
                });
            }

            const allElements = document.querySelectorAll('[class*="bmpui-"]');
            const filteredElements = Array.from(allElements).filter(el =>
                el.className.split(/\s+/).some(cls => cls.startsWith('bmpui-'))
            );
            filteredElements.forEach(element => {
                let testId = element.className.split(/\s+/).find(cls => cls.startsWith('bmpui-'));
                element.setAttribute('data-testid', testId);
            });
            const volumemarkervalStyle = document.querySelector('.bmpui-ui-volumeslider .bmpui-seekbar .bmpui-seekbar-playbackposition-marker');
            const volumeplaybackposStyle = document.querySelector('.bmpui-ui-volumeslider .bmpui-seekbar .bmpui-seekbar-playbackposition');
            const playbackpositionStyle = document.querySelector('.bmpui-seekbar-playbackposition');
            const markerStyle = document.querySelector('.bmpui-seekbar-playbackposition-marker');
            const activeContent = document.querySelector(".ui-state-active");
            if (activeContent) { 
                const color = window.getComputedStyle(activeContent).backgroundColor;
                volumemarkervalStyle.style.backgroundColor = color;
                volumeplaybackposStyle.style.backgroundColor = color;
                playbackpositionStyle.style.backgroundColor = color;
                markerStyle.style.backgroundColor = color;
                markerStyle.style.border='.1875em solid ' + color;
            }
            logger.debug(`PlayerEvent.Ready`);
            this.setStatus(VideoPlayer.STATUS_READY);
            
            // hide full screen button
            if (this.isLiveOrPrelive() && this.isMobilePlatform()) {
                 document.getElementById("fullscreen-button").style.display = 'none';
            }

            this.dispatchEvent(VideoPlayerEvents.EVENT_READY, readyEvent);
            
            // Setup VoiceOver accessibility for volume slider
            this.voiceOverAccessibility.setupVoiceOverVolumeSupport();
            
            const waitForSubtitle = setInterval(() => {
              const subtitleOverlay = document.querySelector('.bmpui-ui-subtitle-overlay');
              if(subtitleOverlay){
                clearInterval(waitForSubtitle);
                const observer = new MutationObserver(mutations => {
                   mutations.forEach(mutation => {
                      mutation.addedNodes.forEach(node => {
                        if(node.nodeType === 1 && node.classList.contains('bmpui-ui-subtitle-label')){
                          node.style.removeProperty('left');
                          node.style.removeProperty('width');
                        }
                        if(node.querySelectorAll){
                          const innerLabels= node.querySelectorAll('.bmpui-ui-subtitle-label');
                          innerLabels.forEach(label => {
                                label.style.removeProperty('left');
                                label.style.removeProperty('width');
                            });
                        }
                       });
                    });
                  });
                  observer.observe(document.body, {
                    childList: true,
                    subtree: true
                  });
              }
            },100);

            const dropdownNormalSpeed =document.getElementById("speed-select-box");
             for(let i =0; i< dropdownNormalSpeed.options.length; i++){
              if(dropdownNormalSpeed.options[i].text.trim().toLowerCase()== 'normal'){
                dropdownNormalSpeed.options[i].text = '1x';
              }
             }

             dropdownNormalSpeed.addEventListener('change', function(){
              for(let i =0; i< this.options.length; i++){
                if(this.options[i].text.trim().toLowerCase()== 'normal'){
                  this.options[i].text = '1x';
                }
               }
             })
        });

        this.player.on(PlayerEvent.PlaybackFinished, (playbackFinishedEvent) => {
            logger.debug(`PlayerEvent.PlaybackFinished`);
            this.setStatus(VideoPlayer.STATUS_FINISHED);
            this.dispatchEvent(VideoPlayerEvents.EVENT_FINISHED, playbackFinishedEvent);
            if (typeof window.closeme === 'function') {
                window.closeme();
                console.log('PlaybackFinished - Current Stream has ended.');
            } else {
                console.log('closeme not a function.');
            }
        });

        this.player.on(PlayerEvent.TimeChanged, (timeChanged) => {
            this.dispatchEvent(VideoPlayerEvents.EVENT_TIMECHANGED, timeChanged);
        });

        // Maintain  seekbar visibility when source is loaded
        this.player.on(PlayerEvent.SourceLoaded, (sourceLoaded)=>{
            //logger.debug(`BitmovinPlayer::SourceLoaded - Seekbar:${this.isSeekBarDisplayed}`);
          this.toggleSeekBar(this.isSeekBarDisplayed);
          if (this.player.getAvailableVideoQualities().length <= 1) {
            this.hideQualitySelectDropdown();
          } else {
            this.showQualitySelectDropdown();
          }

          // Add captions if available
          if (this.captionsJSON !== null) {
            logger.info("onSourceLoaded: captions=" + JSON.stringify(this.captionsJSON));

            const captions = this.captionsJSON;
            for (let i = 0; i < captions.length; i++) {
              this.player.subtitles.add(captions[i]);
            }
          }

          this.dispatchEvent(VideoPlayerEvents.SOURCE_LOADED, sourceLoaded);
        });

        // Detect when playback resumes after buffering (similar to reconnect)
        this.player.on(PlayerEvent.StallEnded, ()=>{
            //logger.debug(`BitmovinPlayer::StallEnded - Seekbar:${this.isSeekBarDisplayed}`);
            this.toggleSeekBar(this.isSeekBarDisplayed);
        });
    
        this.player.on("cueenter", function (event) {
        });

        this.player.on(PlayerEvent.SubtitleAdded, (playEvent) => {
          logger.debug(`PlayerEvent.SubtitleAdded`);

          try{
            // Hide CC1 on iOS and Mac OS (in some situations)
            if(this.config.OS_PLATFORM === 'iOS' || this.config.OS_PLATFORM === 'Mac OS'){
              setTimeout(function(){
                // This will trigger for Safari on IOS when there is a added CC1 captions and off options only
                const SUBTITLE_SELECTBOX = document.getElementsByClassName("bmpui-ui-subtitleselectbox")[0];

                if(SUBTITLE_SELECTBOX.querySelectorAll('option').length === 2 && SUBTITLE_SELECTBOX.querySelectorAll('option')[0].value === "CC1")
                  document.getElementById('video-subtitle-selectbox').style.display = 'none';
              }, 1000);
            }
          }catch (err){
            // can't find element
          }

          try{
            // Hide CC1 on Mac OS
            if(this.config.OS_PLATFORM === 'Mac OS' || this.config.OS_PLATFORM === 'iOS'){
              const SUBTITLES_LIST = this.player.subtitles.list();

              SUBTITLES_LIST.forEach(elem => {
                if(elem.id === "CC1"){
                  this.player.subtitles.remove(elem.id);
                }
              });
            }
          }catch (err){
            // subtitles.list() is undefined
          }

          if(((this.config.OS_PLATFORM === 'Mac OS' || this.config.OS_PLATFORM === 'iOS')) &&
           document.getElementById('speed-select-box').offsetParent === null &&
           document.getElementById('video-quality-selectbox').offsetParent === null &&
           document.getElementById('toggleAudio').offsetParent === null){
            if (document.getElementById("player-settings-button")) {
              document.getElementById("player-settings-button").style.visibility = "hidden";
            }
          }
      });

      // Add click handler for the userAudioBackup toggle button in the settings panel
      const audioBackupToggleButton = document.getElementById("toggleAudio");

      if (audioBackupToggleButton) {
        let that = this;
        audioBackupToggleButton.addEventListener('click', function() {
          that.dispatchEvent(VideoPlayerEvents.EVENT_AUDIOBACKUP_CLICKED);
        });
      }
    }

}

export default VideoPlayer;

==============================

  import Logger from './../Logger';

const logger = new Logger();

/**
 * VoiceOver Accessibility Enhancement Module
 * Provides iOS VoiceOver support for Bitmovin Player volume controls
 */
class VoiceOverAccessibility {
    constructor(player, config) {
        this.player = player;
        this.config = config;
        this.volumeLiveStatusCallback = null;
    }

    /**
     * Set callback for volume live status announcements
     */
    setVolumeLiveStatusCallback(callback) {
        this.volumeLiveStatusCallback = callback;
    }

    /**
     * Setup VoiceOver accessibility for volume slider
     */
    setupVoiceOverVolumeSupport() {
        // Only apply VoiceOver fixes on iOS platform
        if (this.config.OS_PLATFORM !== 'iOS') {
            return;
        }

        logger.debug('Setting up VoiceOver volume support');
        
        setTimeout(() => {
            const volumeSlider = document.getElementById('volume-slider');
            if (!volumeSlider) {
                logger.warn('Volume slider not found for VoiceOver setup');
                return;
            }

            // Find the seekbar elements
            const seekbar = volumeSlider.querySelector('.bmpui-seekbar');
            const seekbarBackend = volumeSlider.querySelector('.bmpui-seekbar-backend');
            
            if (seekbar && seekbarBackend) {
                // Make the volume slider properly accessible to VoiceOver
                seekbar.setAttribute('role', 'slider');
                seekbar.setAttribute('aria-label', 'Volume');
                seekbar.setAttribute('aria-valuemin', '0');
                seekbar.setAttribute('aria-valuemax', '100');
                seekbar.setAttribute('aria-valuenow', Math.round(this.player.getVolume() * 100));
                seekbar.setAttribute('aria-valuetext', `${Math.round(this.player.getVolume() * 100)} percent`);
                seekbar.setAttribute('tabindex', '0');

                // Add keyboard support for VoiceOver
                seekbar.addEventListener('keydown', (event) => {
                    this.handleVolumeKeyboardInput(event);
                });

                // Update aria attributes when volume changes
                this.player.on('VolumeChanged', () => {
                    const currentVolume = this.player.getVolume();
                    const volumePercent = Math.round(currentVolume * 100);
                    seekbar.setAttribute('aria-valuenow', volumePercent);
                    seekbar.setAttribute('aria-valuetext', `${volumePercent} percent`);
                });

                logger.debug('VoiceOver volume support setup completed');
            }
        }, 200);
    }

    /**
     * Handle keyboard input for volume control
     */
    handleVolumeKeyboardInput(event) {
        if (!event || this.config.OS_PLATFORM !== 'iOS') {
            return;
        }

        const currentVolume = this.player.getVolume();
        let newVolume = currentVolume;
        const volumeStep = 0.1; // 10% increments

        switch (event.key) {
            case 'ArrowUp':
            case 'ArrowRight':
                event.preventDefault();
                newVolume = Math.min(1, currentVolume + volumeStep);
                break;
            case 'ArrowDown':
            case 'ArrowLeft':
                event.preventDefault();
                newVolume = Math.max(0, currentVolume - volumeStep);
                break;
            case 'Home':
                event.preventDefault();
                newVolume = 0;
                break;
            case 'End':
                event.preventDefault();
                newVolume = 1;
                break;
            case 'PageUp':
                event.preventDefault();
                newVolume = Math.min(1, currentVolume + 0.2); // 20% increment
                break;
            case 'PageDown':
                event.preventDefault();
                newVolume = Math.max(0, currentVolume - 0.2); // 20% decrement
                break;
            default:
                return; // Don't handle other keys
        }

        // Update the player volume
        this.player.setVolume(newVolume);
        
        // Announce the change for VoiceOver
        const volumePercent = Math.round(newVolume * 100);
        if (this.volumeLiveStatusCallback) {
            this.volumeLiveStatusCallback(`Volume: ${volumePercent} percent`);
        }
        
        logger.debug(`Volume changed via keyboard: ${volumePercent}%`);
    }

    /**
     * Cleanup method
     */
    cleanup() {
        // Remove event listeners if needed
        const volumeSlider = document.getElementById('volume-slider');
        if (volumeSlider) {
            const seekbar = volumeSlider.querySelector('.bmpui-seekbar');
            if (seekbar) {
                seekbar.removeEventListener('keydown', this.handleVolumeKeyboardInput);
            }
        }
    }
}

export default VoiceOverAccessibility;

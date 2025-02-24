function createGlobalMeetUi() {

    const playbackSpeedSelectBox = new bitmovin.playerui.PlaybackSpeedSelectBox(
        {
            id: 'speed-select-box',
            cssClasses: ['tagging-test-class', 'globalmeet-custom-class', 'ui-playbackspeedselectbox'],
        });
    const customSeekBarLabel = new bitmovin.playerui.SeekBarLabel(
        {
            id: 'playback-time-seekbarlabel',
            cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
        });
    
    playbackSpeedSelectBox.clearItems();
    
    const settingsPanel = new bitmovin.playerui.SettingsPanel({
        components: [
            new bitmovin.playerui.SettingsPanelPage({
                components: [
                    new bitmovin.playerui.SettingsPanelItem('Quality', new bitmovin.playerui.VideoQualitySelectBox(),
                        {
                            id: 'video-quality-selectbox',
                            cssClass: 'video-quality-selectbox',
                            cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                        }, { cssClass: 'the-item-class' }),
                    new bitmovin.playerui.SettingsPanelItem('Speed', playbackSpeedSelectBox,
                        {
                            id: 'video-speed-selectbox',
                            //cssClass: 'video-speed-selectbox', 
                            cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                        }),
                    // new SettingsPanelItem('Audio Quality', new AudioQualitySelectBox(),
                    //     {
                    //         id: 'audio-quality-selectbox',
                    //         cssClass: 'audio-quality-selectbox',
                    //         cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                    //     }),
                ],
                //cssClasses: ['settings-panel-page-extended']
            })
        ],
        hidden: true,
    });
    
    //settingsPanel.getDomElement().css({ width: '1300px', height: '1300px' });
    
    
    const defaultUiConfig = new bitmovin.playerui.UIContainer({
        components: [
            new bitmovin.playerui.SubtitleOverlay(),
            new bitmovin.playerui.BufferingOverlay(),
            //new CastStatusOverlay(),
            new bitmovin.playerui.PlaybackToggleOverlay({
                id: 'playback-toggle-button',
                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
            }),
            new bitmovin.playerui.ControlBar({
                components: [
                    settingsPanel,
                    new bitmovin.playerui.Container({
                        components: [
                            new bitmovin.playerui.PlaybackTimeLabel({
                                id: 'playback-time-label',
                                timeLabelMode: bitmovin.playerui.PlaybackTimeLabelMode.CurrentTime,
                                hideInLivePlayback: true
                            }),
                            new bitmovin.playerui.SeekBar({
                                id: 'seek-bar-component',
                                label: customSeekBarLabel
                            }),
                            new bitmovin.playerui.PlaybackTimeLabel({
                                id: 'playback-time-label',
                                timeLabelMode: bitmovin.playerui.PlaybackTimeLabelMode.TotalTime,
                                cssClasses: ['text-right']
                            }),
                        ],
                        id: 'seek-bar-container',
                        cssClasses: ['controlbar-top']
                    }),
                    new bitmovin.playerui.Container({
                        components: [
                            new bitmovin.playerui.PlaybackToggleButton({
                                id: 'playback-pause-button',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            }),
                            /*new ReplayButton({
                                id: 'replay-button',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            }),*/
                            new bitmovin.playerui.VolumeToggleButton({
                                id: 'volume-toggle-button',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            }),
                            new bitmovin.playerui.VolumeSlider({
                                id: 'volume-slider',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            }),
                            new bitmovin.playerui.Spacer(),
                            new bitmovin.playerui.Label({
                                id: 'player-status-label',
                                text: '',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class', 'status-label']
                            }),
                            new bitmovin.playerui.Spacer(),
                            /*new PlaybackSpeedSelectBox({
                                id: 'speed-button',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            }),*/
                            new bitmovin.playerui.PictureInPictureToggleButton(),
                            new bitmovin.playerui.AirPlayToggleButton(),
                            new bitmovin.playerui.CastToggleButton(),
                            new bitmovin.playerui.SettingsToggleButton({
                                settingsPanel: settingsPanel,
                                id: 'player-settings-button',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            }),
                            new bitmovin.playerui.FullscreenToggleButton({
                                id: 'fullscreen-button',
                                cssClasses: ['tagging-test-class', 'globalmeet-custom-class']
                            })
                        ],
                        id: 'control-bar-container',
                        cssClasses: ['controlbar-bottom']
                    })
                ]
            }),
            new bitmovin.playerui.ErrorMessageOverlay(),
        ],
        cssClasses: ['ui-skin-modern']
    });

    return defaultUiConfig
}


(function($){
	$.extend({
		viewerPlayer : {
		   init : function(){
    		   $.oViewerData.playerType = "phone";
    		   $.viewerControls.playerMsg("noFlashUnicast");
    		   $("#playbuttonDiv").hide();
	           $.viewerControls.logMedia("media","none"); // We will use phoneshow code but log as none for reference..
	           $.activePlayer.dispose();
	       }
		},
		viewerHDSPlayer : {
	         init : function(){
    		   $.oViewerData.playerType = "phone";
    		   $.viewerControls.playerMsg("noFlashUnicast");
    		   $("#playbuttonDiv").hide();
	           $.viewerControls.logMedia("media","none"); // We will use phoneshow code but log as none for reference..
	           $.activePlayer.dispose();
	       }
		},
		viewerWMPlayer : {
	         init : function(){
    		   $.oViewerData.playerType = "phone";
    		   $.viewerControls.playerMsg("noFlashUnicast");
    		   $("#playbuttonDiv").hide();
	           $.viewerControls.logMedia("media","none"); // We will use phoneshow code but log as none for reference..
	           $.activePlayer.dispose();
	       }	        
		},
	    viewerHTML5Player : {
	    	 init: function(onComplete) {
				$("#playbuttonDiv").hide();
				if(!$.oMulticast.isFlashmulticastfallback){
	    			 $.viewerNONEPlayer.init();
	    			 $.viewerAction.hideLobby();
	    			 return;
	    		 }

				$.viewerControls.init();
			 	$.viewerAction.init();
	    		 
	    		 var logMediaType = $.oViewerData.playerType; 
	    		 if ($.oMulticast.isHiveMulticast || $.oMulticast.isKollectiveMulticast || $.oMulticast.isRampCache) {
	    			 $.oMulticast.useMulticastFallback = false;
	    			 this.createPlayer(onComplete);
	    		 } else if ($.oMulticast.isRampMulticast) {
	    			 $.oMulticast.useMulticastFallback = false;
	    			 $.multicastTools.checkForRampClientUrl();	  
				 } else {		    		  
	    			 this.createPlayer(onComplete);
	    			 $.viewerControls.logMedia("media", logMediaType);
	    		 }
		     },
		     createPlayer: function() {
					console.log("createPlayer");
		        	 if(!$.oMulticast.isFlashmulticastfallback){
		        		 $.viewerNONEPlayer.init();
		        		 $.viewerAction.hideLobby();
		        		 return;
			    	 }
		        	
		        	 var playerType = $.oViewerData.isAudio ? "html5_audio" : "html5";
		        	 var that = this;
	        		 
		        	 $.viewerAction.getPlayerPath(playerType, $.viewerAction.getCurMediaMode(), $.oViewerData.currentstreamid, function(pathinfo) {
		        		 if (pathinfo.playertype != playerType) {
		        			 if (pathinfo.playertype=="html5_audio") {
		        				 $.viewerAction.switchToAudio();
		        				 $("#player").height("+=30");
		        			 } else {
		        				 $.viewerAction.switchToVideo();
		        			 }
		        		 }
		        		 
		        		 var volume = 0.5;
		        		 if ($.oViewerData.mutePlayer === true) {
		        			volume = 0;
		        		 }		        		 
		        		 $.oVideoInfo.currentVolume = volume;
		        		 if (volume == 0) {
		        		 	$.oVideoInfo.muted = true;
		        		 }
		        		 
		        		 var conInfo = that.getConInfo(pathinfo); 
		        		 var streamPath = conInfo.streamPath;
		        	
		        		 var allowFullScreen = true;
		        		 
		        		 if ($.oViewerData.isIOS) {		        			
		        			 allowFullScreen = !$.oViewerData.isTypeLiveOrSimlive;
		        		 }
		        		 
		        		 var isSafari = (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1);
		        		 var addOffeset = (!$.oViewerData.isWebcam && !isSafari && !$.oMulticast.isHiveMulticast && ($.oViewerData.isAdaptiveBitrate || $.oViewerData.isAudio));
		        		 
		        		 // If event is not simlive or live , and disable seeks is not on
		        		 var showPlaybackSpeed = !$.oViewerData.isTypeLiveOrSimlive && !$.oViewerData.disable_od_seek;

						 /*
		        		 $("#player").viblastprototype({
		        			 myURL : streamPath,
		        			 mywidth : $.oViewerData.isAudio ? "100%" :"100%",
		        			 myheight : $.oViewerData.isAudio ? "0" :"100%",
		        			 myeventid : $.oViewerData.sEventId,
		        			 initJump : $.oViewerData.isSimlive,
		        			 useNative: $.oViewerData.isAudio && !$.oViewerData.isOD && (isSafari && navigator.userAgent.indexOf('Mac') != -1),
		        			 isOD:$.oViewerData.isOD,
		          			 pdn : $.oViewerData.isViblastPDN,
		        			 allowFullScreen : allowFullScreen,
		        			 positionSlider : false,
							 playerName : "flvplayer",
							 autoplay: !$.oViewerData.autoPlayDisable,
		        			 //audioTag : ($.oViewerData.isAudio && navigator.userAgent.indexOf("iPhone")!=-1) ? true : false,
		        			 audioTag : false,
		        			 arrayOfMethodsToCall : that.arrayOfMethodsToCall,		        			 
		        			 reportStats : $.oViewerData.reportPlayerStat,
		        			 isAudioAT : $.oViewerData.isTelAudioAdvanced,
		        			 volume:volume,
		        			 playeroffset: addOffeset,
		        			 getLiveStatusCallBack:($.viewerAction.getCurMediaMode()=="prelive"),
		        			 showPlaybackSpeed : showPlaybackSpeed,
		        			 caption_isvtt : ($.oViewerData.isOD && $.oViewerData.caption.isvtt==1)
		        		 });
						 */

						 window.playerOptions = {
							//player: null,
							streamPath: conInfo.streamPath,
							playerDiv: 'flvplayer',
							videoId: `${$.oViewerData.sEventId}`,
							eventTitle: `Figure This Out`,
							isOD: $.oViewerData.isOD,
							initJump: $.oViewerData.isSimLive
						 };

						 let playerConfig = {
						 	playerElementId: 'flvplayer',
						 	playerVideoElementId: 'playerVdo',
						 	eventId: `${$.oViewerData.sEventId}`,
						 	title: `${$.oViewerData.sTitle}`,
						 	streamPath: conInfo.streamPath,
						 	qualityLabelingFunction: $.qualityLabeling
						 }
						 that.videoPlayer = window.loadPlayer(playerConfig);

				    	 if ($.oViewerData.isAudio) {
		        			that.videoPlayer.makeAudio();
							document.getElementById('flvplayer').style.display = 'none';
		        			$("#viewer_video").removeClass("margin-top-for-theo-viewer");
		        	     } else {
		        	    	that.videoPlayer.makeVideo();
		        	    	$("#viewer_video").addClass("margin-top-for-theo-viewer");
		        	     }
		        		 
		        		 if ($.oViewerData.isTypeLiveOrSimlive)	{
			        		that.hideTime();
			        	 } else {
			        	 	that.showTime();
			        	 }
		        		 
		        		 if ($.oViewerData.isIOS || $.oViewerData.isHLS) {
		        			 $.oVideoInfo.status = "Click Play";
		        			 $(".vjs-live-display").hide();
		        		 } else {
							 if ($.oViewerData.autoPlayDisable === false) {
								that.play();
							 }
		        		 }
		        		 
	        			 $.oViewerData.isStreamLive = true;	
		        	 });
		        	 
		        	 this.isPlayerLoaded = true;
		     },
		     getStatus: function() {
		     },
		     getConInfo: function(pathinfo) {
		    	var obj = pathinfo;
	       		obj.token =  (pathinfo.token == undefined ? "" : (pathinfo.encodetoken ? encodeURIComponent(pathinfo.token) : pathinfo.token));	       		
	        	var overlay_mediatype = pathinfo.overlay_mediatype == undefined ? "" : pathinfo.overlay_mediatype;
	        	
	        	if(overlay_mediatype=="live"){//"live" or "od"
		           	obj.streamPath = pathinfo.protocol +pathinfo.hostname + "/" +pathinfo.appid  + "/" + $.viewerAction.oActiveSecondaryMedia.oMovie.filename + "/playlist.m3u8?t=" + obj.token;
		           	if(pathinfo.fullstreampath!=undefined){
		       		 	obj.streamPath = pathinfo.fullstreampath;
		       		}		        	
		        }else if(overlay_mediatype=="ondemand"){
		        	obj.streamPath = pathinfo.protocol + pathinfo.hostname + "/" + pathinfo.appid;		   
		        	if ($.viewerAction.oActiveSecondaryMedia.oMovie.is_abr) {
		           		obj.streamPath += "/smil:" + $.viewerAction.oActiveSecondaryMedia.oMovie.smilpath + "/playlist.m3u8?t=" + obj.token;
		           	} else {
		           		obj.streamPath += "/mp4:" + $.viewerAction.oActiveSecondaryMedia.oMovie.filename + "/playlist.m3u8?t=" + obj.token;
		           	}
		           	if(pathinfo.fullstreampath!=undefined){
		       		 	obj.streamPath = pathinfo.fullstreampath;
		       		}
		        }else if(pathinfo.cdn=="Custom"){
	        		obj.streamPath = pathinfo.protocol + pathinfo.hostname + "/" + pathinfo.appid + "/" + pathinfo.filename;
	        	}else{
	        		var isLive = "live" == $.viewerAction.getCurMediaMode() ? true : false;
	        		obj.myeventid = isLive ? $.oViewerData.currentstreamid : pathinfo.filename;
	       			if (true == $.oViewerData.isAdaptiveBitrate && true == isLive && (obj.myeventid == $.oViewerData.primaryStreamId || obj.myeventid == $.oViewerData.backupStreamId)) {
		        		obj.myeventid = "amlst:" + obj.myeventid;
		        	}
	        		obj.streamPath = pathinfo.protocol + pathinfo.hostname + "/" + pathinfo.appid + "/" + obj.myeventid + "/playlist.m3u8";
	        		if(obj.token!=""){
	        			obj.streamPath += "?t=" + obj.token;
	        		}
		       		if(pathinfo.fullstreampath!=undefined){
		       		 	obj.streamPath = pathinfo.fullstreampath;
		       		}
	        	}	        	
	        	if(typeof pathinfo.unicastpath!="undefined"){
	        		obj.unicastpath = pathinfo.unicastpath;
	        	}else{
	        		obj.unicastpath = obj.streamPath;
	        	}
	        	if(typeof pathinfo.fallbackserver!="undefined"){
	        		obj.fallbackserver = pathinfo.fallbackserver;
	        	}
	        	if(document.domain.toLowerCase().endsWith("webcasts.cn")){
	        			let arrDomain = document.domain.toLowerCase().match(/\.(?:gm|cn|tp)webcasts.cn/); 
	        		if(Array.isArray(arrDomain)){
		        		obj.streamPath= obj.streamPath.replace(".webcasts.com",arrDomain[0]);
		        		if(obj.unicastpath!=undefined){
		        			obj.unicastpath=obj.unicastpath.replace(".webcasts.com",arrDomain[0]);
		        		}
		        		if(obj.fallbackserver!=undefined){
		        			obj.fallbackserver=obj.fallbackserver.replace(".webcasts.com",arrDomain[0]);
		        		}
	        		}
	        	}
	       		return obj;
		     },
		     switchVideo: function(onComplete) {
		    	 if(!$.oMulticast.isFlashmulticastfallback){
		    		 $.viewerNONEPlayer.init();
		    		 return;
		    	 }
		    	 
		    	 if (!this.isPlayerLoaded) {
		       		this.createPlayer();
		       		return;
		         }
		         
		    	 var playertype = $.oViewerData.isAudio ? "html5_audio" : "html5";
		    	 var that = this;
		    	 var tempStreamId = $.oViewerData.currentstreamid;
		    	 if ($.oMulticast.isFlashMulticastRollBackToBackup == 1 && tempStreamId != $.oViewerData.audiostreamid && $.viewerAction.getCurMediaMode() == "live") {
					 tempStreamId = "backup";
	        		 $.oMulticast.isRolledBackToBackupUnicast = true;
		    	 } else if ($.oMulticast.isFlashMulticastRollBackToBackup == 2 && $.viewerAction.getCurMediaMode() == "live") {
					 tempStreamId = $.oViewerData.audiostreamid;
	        		 $.oMulticast.isRolledBackToBackupUnicast = true;
		    	 }
		    	 
		    	 $.viewerAction.getPlayerPath(playertype, $.viewerAction.getCurMediaMode(), tempStreamId, function(pathinfo) {
		    		 if ($.oMulticast.isRolledBackToBackupUnicast) {
		    		 	$.oViewerData.currentstreamid = pathinfo.streamid;
		    		 }
		    		 if (pathinfo.playertype != playertype) {
			    		 if (pathinfo.playertype == "html5_audio") {
			    			 $("#player").height("+=30");
			    			 $.oViewerData.isAudio = true;
			    	         $.viewerAction.showHeadshot();
			    	         // that.videoPlayer.hideFullscreenToggleButton();
			    			 that.videoPlayer.makeAudio();
			    		 } else {
			    			 $("#player").height("-=30");
			    			 $.oViewerData.isAudio = false;
			 	        	 $("#headshot").hide();
			 	        	 // that.videoPlayer.showFullscreenToggleButton();
			    			 that.videoPlayer.makeVideo();
			    		 }
			    		 
		        		 if ($.oViewerData.sMode == "prelive" || $.oViewerData.sMode == "live")	{
			        		 that.videoPlayer.hideSeekBar();
			        		 that.videoPlayer.hideTime();
			        		 //that.videoPlayer.showFullscreenToggleButton();
			        	 } else {
			        		 that.videoPlayer.showSeekBar();
			        		 that.videoPlayer.showTime();
			        		 //that.videoPlayer.showFullscreenToggleButton();
			        	 }
		    		 }
		    		 var coninfo = that.getConInfo(pathinfo); 
		    		 var streamPath = coninfo.streamPath;
		    		
		    		 
		    		 //Hive P2P needs some random delay so viewers will join in groups. Still testing.
		    		 var delayStreamSwitch = 0;
		    		 if ($.oMulticast.isHiveMulticast) {
		    			 $.activePlayer.pause();		    			 
			   			 $.activePlayer.closeHiveSession();
		    			 delayStreamSwitch = Math.floor(Math.random() * 5000);
                        setTimeout(function () {
                            // that.videoplayer.setSource(streamPath);
                            $.activePlayer.setSource(streamPath);
		        		 }, delayStreamSwitch);
			   		 } else {
                        // that.videoplayer.setSource(streamPath);
                        $.activePlayer.setSource(streamPath);
			   		 }
		    		 
		    		 //Fixing an edge case where overlay is launched right at start of event
		    		 if ($.viewerAction.oActiveSecondaryMedia.active === true && !$.viewerAction.oActiveSecondaryMedia.bInline) {
		    			 console.log("Overlay is going on pause media...");
		    			 setTimeout(function() {
		    				 $.activePlayer.pause();
		    			 }, 2000);		    			 	
		    		 }		    		 
		    		 //if("function" == typeof onComplete) { onComplete(); }//This is called for simlive but we jahe jump logic in 
		    	 });	    	 
		     },
		     switchVideoOverlay:function() {
		    	 var that = this;
		    	 var overlay_mediatype = "ondemand";
				 var ss_posttext = "";
				 //that.videoPlayer.showFullscreenToggleButton();
			
		    	 $.viewerAction.getPlayerPath("html5" + ss_posttext,overlay_mediatype,$.viewerAction.oActiveSecondaryMedia.oMovie.filename,function(pathinfo) {   
		    		 if($.oMulticast.isRolledBackToBackupUnicast) {
		    		 	$.oViewerData.currentstreamid = pathinfo.streamid;
		    		 }
		    		 //that.videoplayer.makeVideo("100%","100%","");
		    		 that.videoPlayer.hideSeekBar();
		    		 that.videoPlayer.hideTime();
			     
			       	 pathinfo.overlay_mediatype = overlay_mediatype;
		    		 var coninfo = that.getConInfo(pathinfo); 
		    		 var streamPath = coninfo.streamPath;
		    		  
		    		 //Hive P2P needs some random delay so viewers will join in groups. Still testing.
		    		 var delayStreamSwitch = 0;
		    		 if ($.oMulticast.isHiveMulticast) {
		    			 $.activePlayer.pause();		    			 
			   			 $.activePlayer.closeHiveSession();
		    			 delayStreamSwitch = Math.floor(Math.random() * 5000);
                        setTimeout(function () {
                            // that.videoplayer.setSource(streamPath);
                            $.activePlayer.setSource(streamPath);
		        		 }, delayStreamSwitch);
			   		 } else {
                        // that.videoplayer.setSource(streamPath);
                        $.activePlayer.setSource(streamPath);
			   		 }

		    		 $.activePlayer.setInitJump(true);
		    		 clearTimeout($.viewerAction.oActiveSecondaryMedia.timer);
		    		 $.viewerAction.oActiveSecondaryMedia.timer = setTimeout("checkPlaying()", ($.viewerAction.oActiveSecondaryMedia.oMovie.duration-getMediaOffset() + 3) * 1000);
		    		 if ($.oViewerData.isBridgeCustom) {
		    		 	$("#viewer_phone_option").hide();
		    		 }
		    	 });	    	 
		     },
		     setInitJump: function(bFlag) {
		     	//this.html5widget.setInitJump(bFlag);
		     },
		     setPosition: function(seconds) {
		        if (!this.isPlayerLoaded) {
		        	return;
		        }
		     	this.videoPlayer.player.seek(seconds);
		     },
		     setVolume: function(vol) {
		        if (!this.isPlayerLoaded) {
		        	return;
		        }
		        
		        this.videoPlayer.player.setVolume(vol);
		     },
		     setMute: function(bMute) {
		        if (!this.isPlayerLoaded) {
		        	return;
		        }
		        
		        if (bMute) {
		        	this.videoPlayer.player.mute();
		        } else {
		        	this.videoPlayer.player.unMute();
		        }
		     },
		     getCurrentSourcePath() {
		     	return this.videoPlayer.player.getSource().hls;
		     },
		     setSource: function(newSrc) {
		        if (!this.isPlayerLoaded) {
		        	return;
		        }
		        
		     	this.videoPlayer.player.load({hls: newSrc});
		     },
		     play: function() {
		    	 var that = this;

		         if ($.oViewerData.isOD && $.oViewerData.isStreamSecured && $.oVideoInfo.currentPosition == 0) {
		        	 var cdnPath = that.getCurrentSourcePath().split('?')[0];
	    		 	 $.viewerAction.getPlayerToken(cdnPath, function(pathinfo) {
	    		 	 	var newPath = that.getCurrentSourcePath().split('?')[0] + "?t=" + pathinfo;
	    		 		that.setSource(newPath);
	    		 		that.play();
	    		 	 });
		    	 } else {
					if (this.videoPlayer.player.isPaused()) {
						this.videoPlayer.player.play();
					} else {
						that.setSource(that.getCurrentSourcePath());
						this.videoPlayer.player.play();
					}

		    	 }
		     },
		     load: function() {
		      	if (/OS [4]_\d_\d like Mac OS X/i.test(navigator.userAgent)) {
		       		$.viewerHTML5Player.switchVideo();
		       	} else {
		       		//setTimeout(this.html5widget.load(), 600);
			       	//setTimeout(this.html5widget.load(), 1200);
		       	}
		     },
		     loadspecial: function(seconds) {
		     	if (this.videoPlayer.player.getCurrentTime() > 0) {
		     		$.viewerHTML5Player.setPosition(seconds);
		     	} else {
		     		//this.html5widget.load();
			  		try {
			  			this.videoPlayer.player.seek(seconds);
			   		} catch(err) {}
			       		setTimeout("$.viewerHTML5Player.loadspecial(" + seconds + ")",3000);
			       	}
		     },
		     stop: function() {
		        if (!this.isPlayerLoaded) {
		        	return;
		        }
		        
		        this.videoPlayer.player.pause();
		     },
		     pause: function() {
		        if (!this.isPlayerLoaded) {
		        	return;
		        }
		        
		        this.videoPlayer.player.pause();
		     },
		     playerType: function() {
	        	return $.oViewerData.isAudio ? "html5_audio" : "html5";
	         },
	         dispose: function() {
	        	 if (this.isPlayerLoaded) {
	        		 this.videoPlayer.player.destroy();
	        		 this.isPlayerLoaded = false;
	        	 }
	         },
	         setLiveTitle: function(title) {
	        	if (typeof this.html5widget!="undefined") {
					 this.html5widget.setLiveTitle(title);
				}	
	         },
	         closeHiveSession: function() {
	        	//this.html5widget.closeHiveSession();
				closeHiveSession();
	         },
	         hideControls: function() {
	         	this.videoPlayer.hideControls();
	         },
	         showControls: function() {
	         	this.videoPlayer.showControls();
	         },
	         hideSeekBar: function() {
	         	this.videoPlayer.hideSeekBar();
	         },
	         showSeekBar: function() {
	         	this.videoPlayer.showSeekBar();
	         },
	         hideTime: function() {
	         	this.videoPlayer.hideTime();
	         },
	         showTime: function() {
	         	this.videoPlayer.showTime();
	         },
	         hidePlaybackSpeed: function() {
	         	this.videoPlayer.hidePlaybackSpeed();
	         },
	         hidePlaybackToggleButton: function() {
	         	this.videoPlayer.hidePlaybackToggleButton();
	         },
	         hideFullscreenToggleButton: function() {
	         	this.videoPlayer.hideFullscreenToggleButton();
	         },
	         showFullscreenToggleButton: function() {
	         	this.videoPlayer.showFullscreenToggleButton();
	         },
	         isLive: function() {
	         	return this.videoPlayer.player.isLive();
	         },
	         makeAudio: function() {
				$.oViewerData.isAudio = true;
	         	this.videoPlayer.makeAudio();
	         },
	         makeVideo: function() {
				$.oViewerData.isAudio = false;
	         	this.videoPlayer.makeVideo();
	         },
	         videoPlayer: null
	    },
	    viewerNONEPlayer : {
	       init : function(){
				console.log("viewerNONEPlayer");
    		   $.oViewerData.playerType = "phone";
    		   $.viewerControls.playerMsg("noFlashUnicast");
    		   $("#playbuttonDiv").hide();
	           $.viewerControls.logMedia("media","none"); // We will use phoneshow code but log as none for reference..
	           $.activePlayer.dispose();
	       }
	    }
	});
})(jQuery);

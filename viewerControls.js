(function ($) {
	$.extend({
		viewerControls: {
			trySetPosition: function (index) {
				var that = this;
				try {
					$.activePlayer.setPosition(index);
					$.viewerAction.initOdTimer();
				} catch (ex) {
					setTimeout(function () {
						$.viewerControls.trySetPosition(index);
					}, 200)
				}
			},
			init: function () {
				if ($.oViewerData.caption.isvtt === 'undefined') {
					$.oViewerData.caption.isvtt = 0;
				}
				$("#volslider").slider({
					orientation: "horizontal",
					value: 50,
					slide: function (event, ui) {
						$.activePlayer.setVolume(ui.value);
					}
				});
				if ($.oViewerData.isOD) {
					if (!$.oViewerData.disable_od_seek) {
						$("#odslider").slider({
							orientation: 'horizontal',
							start: function (event, ui) {
								if ($.oVideoInfo.status == "Paused") return;
								$.oVideoInfo.odSlider.status = 1;
							},
							slide: function (event, ui) {
								if ($.oVideoInfo.status == "Paused") return;
								$.oVideoInfo.odSlider.pos = $.oVideoInfo.totalDuration * ui.value / 100;
								$("#counter").html($.viewerControls.timeToString($.oVideoInfo.odSlider.pos));
							},
							stop: function (event, ui) {
								if ($.oVideoInfo.status == "Paused") return;
								$.activePlayer.setPosition($.oVideoInfo.odSlider.pos);
								$.oVideoInfo.odSlider.status = 2;
							},
							range: "min"
						}).show();
						if ($.activePlayer == $.viewerHTML5Player) {
							//$.activePlayer.html5widget.showPosSlider();
							$("#odslider").hide();
						}
					}
					if (!$.oViewerData.isSimlive) {
						$("#counterwrapper").show();
					}

					if ($.oViewerData.caption.isvtt === 0 && $.oViewerData.caption.od == 1 && $.oViewerData.caption.odpath != "") {
						$("#cc").show();
					}

					if ($.oViewerData.caption.open == 1 && $.oViewerData.caption.isvtt === 0) {
						if ($.viewerAction.arrCaptions.length == 0) {
							$.viewerControls.cc();
						}
						$("#caption").show();
						$("#cc").addClass('ui-state-active');
						$("#cc_on").addClass('on');
						$("#cc_off").removeClass('off');
					}
				};
				$('.ui-state-default').live({
					mouseenter: function () { $(this).addClass('ui-state-hover'); },
					mouseleave: function () { $(this).removeClass('ui-state-hover'); }
				});
				$("#play").click(function () {
					if ($.oViewerData.sMode == "postlive") return;
					$.activePlayer.play();
					//undo ticket 12729 Fix for iOS and Android not jumping in to simlive for audio events when the play button on the video tag is pressed.
					if (!$.oViewerData.isIOS && !$.oViewerData.isHLS && $.oViewerData.isSimlive && !$.oViewerData.isPreSimlive) {
						$.viewerControls.trySetPosition($.oViewerData.simliveIndex);
					}
				});
				$('.vjs-play-control').click(function () {
					if ($(".vjs-settings-button").hasClass("open")) {
						$.viewerControls.dopostsettingmenu();
					}
				});
				$('.vjs-refresh-control ').click(function () {
					if ($(".vjs-settings-button").hasClass("open")) {
						$.viewerControls.dopostsettingmenu();
					}

					if ($("#jumppoint").hasClass("open")) {
						$("#jumppoint").click();
					}
				});
				$('.vjs-volume-menu-button').click(function () {
					if ($(".vjs-settings-button").hasClass("open")) {
						$.viewerControls.dopostsettingmenu();
					}
				});
				$("#pause").click(function () {
					if ($.oViewerData.sMode == "postlive") return;
					$.activePlayer.pause();
				});
				$("#stop").click(function () {
					if ($.oViewerData.sMode == "postlive") return;
					$.activePlayer.stop();
				});
				$("#refreshvideo").click(function () {

					if ($.oViewerData.sMode == "postlive") return;
					if (!$.oViewerData.refreshRunning) {
						$.oViewerData.refreshRunning = true;
						if ($.viewerAction.oActiveSecondaryMedia.active) {
							//Code for inline Overlay
							$.activePlayer.switchVideoOverlay();
						} else {
							if ($.oViewerData.isSimlive && !$.oViewerData.isPreSimlive) {
								$.activePlayer.switchVideo(function () {
									$.viewerControls.trySetPosition($.oViewerData.simliveIndex);
								});
							} else {
								$.activePlayer.switchVideo();
							}
						}

						setTimeout(function () {
							$.oViewerData.refreshRunning = false;
						}, 5000);
					}
				});
				$("#changemedia").click(function () {
					console.log("changemedia()!!!");
				});
				if ($.oViewerData.userAudioBackup && $.oViewerData.audiostreamid != "" && $.oViewerData.sMode == "live" && $.oViewerData.audiostreamid != $.oViewerData.serverstreamid) {
					$("#toggleAudio").removeClass("ui-helper-hidden");
				}
				$("#toggleAudio").click(function () {
					if ($.oViewerData.isAudio) {
						$.oViewerData.currentstreamid = $.oViewerData.serverstreamid;
						$.activePlayer.switchVideo();
						$(this).find("span").removeClass("ui-icon-video").addClass("ui-icon-signal").attr("alt", $.oViewerText.alt_audio).attr("title", $.oViewerText.alt_audio);
						$(".vjs-toggleaudio-control").attr("alt", $.oViewerText.alt_audio).attr("title", $.oViewerText.alt_audio).html("&nbsp;&nbsp;&nbsp;" + $.oViewerText.alt_audio);
					} else {
						$.oViewerData.currentstreamid = $.oViewerData.audiostreamid;
						$.activePlayer.switchVideo();
						$(this).find("span").removeClass("ui-icon-signal").addClass("ui-icon-video").attr("alt", $.oViewerText.alt_video).attr("title", $.oViewerText.alt_video);
						$(".vjs-toggleaudio-control").attr("alt", $.oViewerText.alt_video).attr("title", $.oViewerText.alt_video).html("&nbsp;&nbsp;&nbsp;" + $.oViewerText.alt_video);
					}

					$.viewerControls.dopostsettingmenu();
				});
				$("#playermsg_ok").click(function () {
					$.viewerControls.hidePlayerMsg("");
				});

				$('#btnCloseSlideMsg').on('click', function () {
					$('#slideMsg').css({ 'display': 'none' });
					$('#playermsg_ok').click();

					if ($('#secondarymedia').is(':visible') === false) {
						$('#overlay_content').css({ 'display': 'none' });
						$('#overlay_body').css({ 'display': 'none' });
					}
				});

				$("#jumppoint").click(function () {
					if ($('#jumppointframe').is(':visible')) {
						$.viewerAction.hideJumpPoint('', '');
					} else {
						$.viewerAction.showJumpPoint();
					}
					if ($(".vjs-settings-button").hasClass("open")) {
						$.viewerControls.dopostsettingmenu();
					}
					if (!$('#transcript_caption').is(':visible') && $.oViewerData.captionsVisible && $.oViewerData.transcript_viewer_display) {
						$('.transcript_caption').removeClass('hidden');
					}
					return false;
				});
				$("#playbuttonDiv").click(function () {
					$.activePlayer.play();

					if ($.oViewerData.isIOS && $.oViewerData.playerType == "html5") {
						$("#playbuttonDiv").hide();
					}
				});
				$("#add_ianumbers").live("click", function () {
					$("#iaNumbers").css('left', $("#add_ianumbers").outerWidth() + $("#add_ianumbers").offset().left).css('top', $("#add_ianumbers").offset().top).show();
				});
				$("#iaexit").click(function () {
					$("#iaNumbers").hide();
				});
				$("#cc").click(function () {
					if ($.viewerAction.arrCaptions.length == 0) {
						$.viewerControls.cc();
					}
					if ($("#caption").is(":visible")) {
						$("#caption").hide();
						$("#cc").removeClass('ui-state-active');
						$("#cc_on").removeClass('on');
						$("#cc_off").addClass('off');
					} else {
						$("#caption").show();
						$("#cc").addClass('ui-state-active');
						$("#cc_on").addClass('on');
						$("#cc_off").removeClass('off');
					}
					$.viewerControls.dopostsettingmenu();
					return false;
				});
				$("#clicktojoinurl").click(function () {
					var urliframe = "#" + $(this).attr("id") + "_frame";
					if ($(urliframe).length && $(urliframe).attr("src").indexOf("javascript") == 0) {
						$(urliframe).attr("src", $.oViewerData.clicktojoinurl);
					}
					$(urliframe).dialog({
						dialogClass: "clickmeurl",
						closeText: "",
						width: 500,
						height: 500,
						resizable: false
					});
				});
				$("#dialinurl").click(function () {
					var urliframe = "#" + $(this).attr("id") + "_frame";
					if ($(urliframe).length && $(urliframe).attr("src").indexOf("javascript") == 0) {
						$(urliframe).attr("src", $.oViewerData.dialinurl);
					}
					$(urliframe).dialog({
						dialogClass: "dialinurl",
						closeText: "",
						width: 500,
						height: 500,
						resizable: false
					});
				});
				if ($.activePlayer == $.viewerHTML5Player) {
					$("#controls").hide();
					$("#status").hide();
				}
				$.statusTimer = setInterval(this.showStatus, 1000);
				$("#lobby_close").click(function () {
					$.viewerAction.hideLobby();
				});
				$("#close").click(function () {
					$.viewerAction.endSession(600);
				});
				$("#jump_close").click(function () {
					$("#jumppoint").focus().click();
				});
				$("#phone").live('click', function () {
					if ($.oViewerData.playerType != "phone") {
						$.viewerControls.switchToPhone();
					}
				});
				$("#nophone").live('click', function () {
					if ($.oViewerData.playerType == "phone") {
						$.viewerControls.switchToComputer();
					}
				});
				$('.slidesOnlyPlayer__play, .slidesOnlyPlayer__pause').on('click', function () {
					if ($('.slidesOnlyPlayer__pause').css('display') === "block") {
						$.activePlayer.pause();
						$('.slidesOnlyPlayer__pause').css({ 'display': 'none' });
						$('.slidesOnlyPlayer__play').css({ 'display': 'block' });
					} else {
						$.activePlayer.play();
						$('.slidesOnlyPlayer__pause').css({ 'display': 'block' });
						$('.slidesOnlyPlayer__play').css({ 'display': 'none' });
					}
				});

				$('.slidesOnlyPlayer__volume-up, .slidesOnlyPlayer__volume-down').on('click', function () {
					$('.vjs-volume-menu-button').click();

					if ($('.slidesOnlyPlayer__volume-up').css('display') == 'block') {
						$('.slidesOnlyPlayer__volume-up').css({ 'display': 'none' });
						$('.slidesOnlyPlayer__volume-down').css({ 'display': 'block' });
					} else {
						$('.slidesOnlyPlayer__volume-up').css({ 'display': 'block' });
						$('.slidesOnlyPlayer__volume-down').css({ 'display': 'none' });
					}
				});
			},
			isChangingMedia: false,
			changeMedia: function () {
				console.log("changeMedia()!!!");
			},
			setChangeMediaButton: function (currentType) {
				console.log("setChangeMediaButton()!!!");
			},
			switchToPhone: function () {
				try {
					$.activePlayer.stop();
				} catch (e) { }

				$("#flvplayer").hide();
				if (!$.oViewerData.isAudio) {
					$.viewerAction.flipheadshot("");
				}
				if ($.oViewerData.playerType == "html5_audio") {
					$("#player").height("-=30");
				}
				$("#bridge_info").show();
				$("#controls").hide();
				$("#phone").hide();
				$("#nophone").show();
				$.oViewerData.prevPlayerType = $.oViewerData.playerType;
				$.oViewerData.playerType = "phone";
				if ($.oViewerData.bInRoomView) {
					$.viewerControls.logMedia("media", "meeting_room");
				} else {
					$.viewerControls.logMedia("media", $.oViewerData.playerType);
				}
				if ($("#playbuttonDiv").length > 0) {
					$("#playbuttonDiv").hide();
				}
				$.viewerControls.hidePlayerMsg("");

				if ($.oViewerData.liveTranscriptEnabled && $.oViewerData.isOD === false) {
					// close verbit captions 
					//$('#transcript_close').trigger("click");
					$('#live_caption').hide();
				}
				return;
			},
			switchToComputer: function () {
				$.oViewerData.playerType = $.oViewerData.prevPlayerType;
				$("#flvplayer").show();
				$.activePlayer.switchVideo();

				$("#bridge_info").hide();
				if ($.activePlayer != $.viewerHTML5Player) {
					$("#controls").show();
				}
				$("#nophone").hide();
				$("#phone").show();
				$("#iaNumbers").hide();
				if ($.oViewerData.playerType == "html5_audio") {
					$("#player").height("+=30");
				}
				$.viewerControls.logMedia("media", $.oViewerData.playerType);

				if ($.oViewerData.liveTranscriptEnabled && $.oViewerData.sMode == "live" && $.oViewerData.showLiveCaptionsInViewerByDefault) {
					// show verbit captions 
					$('#live_caption').css('display', 'block');
				}
				return;
			},
			togglePlayPauseStop: function (tType) {
				switch (tType) {
					case "play":
						$("#play").addClass('ui-state-active');
						if ($("#pause")) $("#pause").removeClass('ui-state-active');
						if ($("#stop")) $("#stop").removeClass('ui-state-active');
						break;
					case "pause":
						if ($("#pause")) $("#pause").addClass('ui-state-active');
						if ($("#stop")) $("#stop").addClass('ui-state-active');
						$("#play").removeClass('ui-state-active');
						break;
					case "stop":
						$("#stop").addClass('ui-state-active');
						$("#play").removeClass('ui-state-active');
						break;
				}
			},
			showStatus: function () {
				$.activePlayer.getStatus();

				if ($.oViewerData.playerType === "html5_audio" || $('.vjs-toggleaudio-control').attr('title') === "Switch to Video Stream") {
					$("#flvplayer").show();
					$('#bitmovinplayer-video-flvplayer').hide()
	   	            
					if($.oViewerData.isOD){
						$('#player-settings-button').show()
					}else{
						$('#player-settings-button').hide()
					}
					
					$('#fullscreen-button').hide()
					$('#original-control-bar').addClass('show');
					$('#bmpui-id-38').css({ 'background-color': 'black', 'opacity': '1' });
				} else if ($('#original-control-bar').hasClass('show')) {
					$('#original-control-bar').removeClass('show')
				} else {
					$('#player-settings-button').show()
					$.activePlayer.hideFullscreenToggleButton();
					$('#bmpui-id-38').css({ 'background-color': '', 'opacity': '' });
				}

				if ($.oVideoInfo.status == "Playing" && $("#status").html != $.oViewerText.sts_playing) {
					$.viewerControls.togglePlayPauseStop("play");
				}
				if ($.oVideoInfo.status == "Paused" && $("#status").html != $.oViewerText.sts_paused) {
					$.viewerControls.togglePlayPauseStop("pause");
				}
				var statustxt = $.oVideoInfo.status;
				$('#top-control-bar').css('opacity', 1);

				if ($.oVideoInfo.status == "Playing") {
					statustxt = $.oViewerText.sts_playing;
					$('#top-control-bar').css('opacity', 0);
				} else if ($.oVideoInfo.status == "Connecting") {
					statustxt = $.oViewerText.sts_connecting;
				} else if ($.oVideoInfo.status == "Connecting..") {
					statustxt = $.oViewerText.sts_connecting + "..";
				} else if ($.oVideoInfo.status == "Buffering") {
					statustxt = $.oViewerText.sts_buffering;
				} else if ($.oVideoInfo.status == "Buffering..") {
					statustxt = $.oViewerText.sts_buffering + "..";
				} else if ($.oVideoInfo.status == "Connection Failed") {
					statustxt = $.oViewerText.sts_failed;
				} else if ($.oVideoInfo.status == "Paused") {
					statustxt = $.oViewerText.sts_paused;
				} else if ($.oVideoInfo.status == "Click Play") {
					statustxt = $.oViewerText.ios_click_play;
				}
				if ($.viewerAction.getCurMediaMode() != "ondemand" && statustxt == "Paused") statustxt = "Stopped";

				if (statustxt == "Stopped") {
					statustxt = $.oViewerText.sts_stopped;
				}
				if ($.oViewerData.sMode == "live") {
					$.activePlayer.hidePlaybackSpeed();
					$.activePlayer.hidePlaybackToggleButton();
				}

				if ($.oViewerData.sMode == "prelive") {
					$.activePlayer.hidePlaybackSpeed()
					$.activePlayer.hideSeekBar()
					$.activePlayer.hidePlaybackToggleButton();
					//$('#bmpui-id-22').show()
					if($.oViewerData.isOD){
						$('.bmpui-ui-playbacktimelabel').show();
					}else{
						$('.bmpui-ui-playbacktimelabel').hide();
					}
					if ($.oViewerData.sPrelive_player_layout == "LAYOUT_SLIDE_ONLY") {
						//$("#bitmovinplayer-video-flvplayer").hide()
						$('.bitmovinplayer-container').css('min-height', 'unset');
						$.activePlayer.hideSeekBar()
						$("#bmpui-id-21").hide()
					}
					if ($.oViewerData.playerType !== "html5_audio"){
					 	$.activePlayer.showFullscreenToggleButton();
					}else{
					 	$.activePlayer.hideFullscreenToggleButton();
					}
				} else if ($.oViewerData.sMode == "live") {
					$.activePlayer.hidePlaybackSpeed()
					$.activePlayer.hideSeekBar()
					$.activePlayer.showTime()
					if ($.oViewerData.playerType !== "html5_audio"){
					 	$.activePlayer.showFullscreenToggleButton();
					}else{
					 	$.activePlayer.hideFullscreenToggleButton();
					}
					if ($.viewerAction.oLastLiveAction.layout == "LAYOUT_SLIDE_ONLY") {
						//$("#bitmovinplayer-video-flvplayer").hide()
						$('.bitmovinplayer-container').css('min-height', 'unset');
						$.activePlayer.hideSeekBar()
						$("#bmpui-id-21").hide()
						$.activePlayer.hideFullscreenToggleButton();
					}
					if ($.viewerAction.oLastLiveAction.layout == "LAYOUT_SLIDE_ONLY" && $.oViewerData.sPrelive_player_layout == "LAYOUT_SLIDE_ONLY") {
							$("#bitmovinplayer-video-flvplayer").hide()
							$.activePlayer.hideFullscreenToggleButton();
					}

				} else if ($.oViewerData.sMode == "ondemand") {
					if ($.oViewerData.playerType !== "html5_audio"){
					 		$.activePlayer.showFullscreenToggleButton();
					}else{
					 	$.activePlayer.hideFullscreenToggleButton();
					}
					if ($.oViewerData.sPrelive_player_layout == "LAYOUT_SLIDE_ONLY") {
							//$("#bitmovinplayer-video-flvplayer").hide()
							$('.bitmovinplayer-container').css('min-height', 'unset');
							$("#bmpui-id-21").hide()
							$.activePlayer.hideFullscreenToggleButton();
					}

					if(!$.oViewerData.isSimlive){
						$('.bmpui-ui-playbacktimelabel').show();
					}else{
						$('.bmpui-ui-playbacktimelabel').hide();
					}

					if ($.oViewerData.disable_od_seek) {
						$.activePlayer.hideSeekBar()
						$.activePlayer.hidePlaybackSpeed()
						$.activePlayer.hideTime()
					} else {
						$.activePlayer.showSeekBar()
					}
				} else {
					$.activePlayer.showSeekBar()
				}

				if ($.oViewerData.isOD) {
					if ($.activePlayer == $.viewerHTML5Player) {
						$("#status").hide();
					}
					if (!$.oViewerData.isSimlive && ($.oVideoInfo.status == "Playing" || $.oVideoInfo.status == "Paused")) {
						$("#status").hide();
						$(".vjs-status-display").html('');
					}

					$("#duration").html($.viewerControls.timeToString($.oVideoInfo.totalDuration));
					if ($.oVideoInfo.odSlider.status == 0) {
						$("#counter").html($.viewerControls.timeToString($.oVideoInfo.currentPosition));
						var newPos = ($.oVideoInfo.currentPosition / $.oVideoInfo.totalDuration) * 100;
						if (!$.oViewerData.disable_od_seek) {
							if (!isNaN(newPos)) $("#odslider").slider('value', newPos);
						}
					}
					if ($.oVideoInfo.odSlider.status == 2) {
						if (Math.abs($.oVideoInfo.odSlider.pos - $.oVideoInfo.currentPosition) < 1) {
							$.oVideoInfo.odSlider.status = 0;
						}
					}
				}
				$("#status").html(statustxt);
				$(".vjs-status-display").html(statustxt);

				if ($('body').hasClass('removeVideo125')) {
					$(".slidesOnlyPlayer__status").html(statustxt);
				}
			},
			timeToString: function (tc) {
				var h = "00";
				var m = "00";
				var s = "00";
				if (isFinite(tc)) {
					tc = Math.round(tc);
					if (tc >= 3600) {
						hInt = Math.floor(tc / 3600);
						tc -= (hInt * 3600);
						h = hInt < 10 ? "0" + hInt : hInt;
					}
					if (tc >= 60) {
						mInt = Math.floor(tc / 60);
						tc -= (mInt * 60);
						m = mInt < 10 ? "0" + mInt : mInt;
					}
					s = tc < 10 ? "0" + tc : tc;
				}
				if (h == "00") return m + ":" + s;
				else return h + ":" + m + ":" + s;
			},
			playerMsg: function (dispType) {
				var dispTxt = $.oViewerMsg[dispType];
				if (dispType == "flashRequired") {
					dispTxt = "<span class='rtmpErrorText'>" + $.oViewerText.err_to_view_webcast + dispTxt + "</span>";
				}
				if (dispType == "noFlashUnicast") {
					$("#controls").remove();
					$("#playermsg_ok").hide();
					$("#nophone").remove();
				} else {
					$("#playermsg_ok").show();
				}
				$.oVideoInfo.playerMsgType = dispType;
				$("#playermsg_txt").html(dispTxt);

				if ($('#viewer_video').css('display') === 'none') {
					$("#slideMsgTxt").html(dispTxt);
					$('#overlay_content').css({ 'display': 'block' });
					$('#slideMsg').css({ 'display': 'block' });
					$('#overlay_body').css({ 'display': 'block' });
				}

				$("#playermsg").removeClass("player_hide");
				$("#playermsg").next().addClass("player_hide");
				if ($('body').hasClass('removeVideo125')) {
					$.viewerAction.AddMsgAllSlidesOnly();
				}
			},
			hidePlayerMsg: function (dispType) {
				if (dispType == "" || $.oVideoInfo.playerMsgType == dispType) {
					$.oVideoInfo.playerMsgType = "";
					$("#playermsg").addClass("player_hide");
					$("#playermsg").next().removeClass("player_hide");
					$.viewerAction.removeMsgAllSlidesOnly();
				}
				return false;
			},
			logMedia: function (logType, logData) {
				$.ajax({
					type: "POST",
					url: "logmedia.jsp?ei=" + $.oViewerData.sEventId,
					data: { "ui": $.oViewerData.ui, "si": $.oViewerData.si, "sh1": $.oViewerData.sh1, "sh0": $.oViewerData.sh0, "logType": logType, "logData": logData },
					success: function (jsonResult) { }
				});
			},
			cc: function () {
				var xmlpath = "/content/" + $.oViewerData.sClientid + "/" + $.oViewerData.sEventId + "/content/" + $.oViewerData.sEventGUID + $.oViewerData.caption.odpath;
				$.ajax({
					type: "GET",
					url: xmlpath,
					dataType: "xml",
					success: function (xmlResult) {
						try {
							var x = xmlResult.documentElement.getElementsByTagName("p");
							if (x.length == 0) {
								log("No caption data from xml");
								return;
							}
							var prevoffset_end = 0;
							var offset_seconds = 0;
							for (i = 0; i < x.length; i++) {
								offset_seconds = $.viewerControls.cc_time2sec(x[i].getAttribute("begin"));
								if (offset_seconds - prevoffset_end > 2) { //If there is gap between 2 nodes add blank.
									var oCaption = {};
									oCaption.offset_seconds = prevoffset_end;
									oCaption.txt = "&nbsp;";
									$.viewerAction.arrCaptions.push(oCaption);
								}
								var oCaption = {};
								oCaption.offset_seconds = offset_seconds;
								prevoffset_end = $.viewerControls.cc_time2sec(x[i].getAttribute("end"));
								oCaption.txt = x[i].childNodes[0].nodeValue;
								$.viewerAction.arrCaptions.push(oCaption);
							}

							if ($.viewerAction.arrCaptions.length > 0) {
								var oCaption = {}; // Add last node as end of last node..
								oCaption.offset_seconds = prevoffset_end;
								oCaption.txt = "&nbsp;";
								$.viewerAction.arrCaptions.push(oCaption);

							}
						} catch (err) {
							$("#caption_txt").html("Error loading Caption");
						}

					}
				});
			},
			cc_time2sec: function (ttb) {
				var ttbsplit = ttb.split(":");//split HH:MM:SS.ms into 3 sections with : as the delimiter
				var ttball = (ttbsplit[0] * 3600) + (ttbsplit[1] * 60) + Math.round(ttbsplit[2]);//The hour + The minutes + The seconds rounded to eliminate milliseconds
				return ttball
			},
			dopostsettingmenu: function () {
				$(".vjs-settings-container .vjs-menu").hide();
				$(".vjs-settings-container").hide();
				$(".vjs-settings-button").removeClass("make-green").removeClass("open");
			}
		}
	});
})(jQuery);

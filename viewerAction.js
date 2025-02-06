(function ($) {
	$.extend({
		viewerAction: {
			arrCalls: [],
			arrSlideFlip: [],
			arrHeadShotFlip: [],
			arrLayoutFlip: [],
			arrJumpPoints: [],
			arrMisc: [],
			arrSecondaryMedia: [],
			iScriptDelay: 0,
			oLastLiveAction: { "slide": "", "step": "", "headshot": "", "secondarymedia": "", "overlaymedia": "" },
			oActiveSecondaryMedia: { "oMovie": {}, "sMovieTs": "", "active": false },
			arrThumbsurl: [],
			arrCaptions: [],
			arrLiveTranscript: [],
			bThumbCachingStarted: false,
			firstSwitchVideo: true,
			isTelephony: false,
			overlayID: "",
			secondaryMediaClosed: false,
			odpausestats: { "pausecnt": 0, "pausemsg": false, "pausemsgcntdown": 60 },
			init: function () {
				//console.log("init:" + " parent=" + $(this).prev().prop('nodeName')); //.attr("value"));

				// Clear arrays; init could be called multiple times
				this.arrJumpPoints.length = 0;
				this.arrThumbsurl.length = 0;
 				$("#jumppointdiv").empty();

				if (!bnoloading) {
					setTimeout(this.hideLoading, 1000);
				} else {
					$.viewerAction.hideLobby();
				}
				if ($.oViewerData.isOD) {
					console.log(this.arrCalls);
					for (timings in this.arrCalls) {
						console.log("init: timings=" + timings);
						switch (this.arrCalls[timings].action) {
							case "slide_flip":
								console.log("init: VIEWERACTION slide_flip");
								if ($.oViewerData.bUserControlSlides) continue;
								this.arrSlideFlip.push(this.arrCalls[timings]);
								break;
							case "headshot_flip":
								console.log("init: VIEWERACTION headshot_flip");
								if ($.oViewerData.isAudio) this.arrHeadShotFlip.push(this.arrCalls[timings]);
								break;
							case "layout_flip":
								console.log("init: VIEWERACTION layout_flip");
								this.arrLayoutFlip.push(this.arrCalls[timings]);
								break;
							case "send_surveyresult":
							case "send_survey":
								this.arrMisc.push(this.arrCalls[timings]);
								break;
							case "launch_media":
								console.log("init: VIEWERACTION launch_media");
								var _oTimes = this.arrCalls[timings];
								var oMovie = $.viewerAction.getSeoondaryMediaObj(_oTimes.mediaid);
								_oTimes.oMovie = oMovie;
								this.arrSecondaryMedia.push(_oTimes);
								console.log(oMovie);
								console.log(_oTimes);
								console.log(this.arrSecondaryMedia);
								break;
						}
						if (this.arrCalls[timings].jump_point == 1 && !(!$.oViewerData.isSlides && this.arrCalls[timings].action == "slide_flip")) {
							this.arrJumpPoints.push(this.arrCalls[timings]);
						}
					}  // end for arrcalls

					if (this.arrHeadShotFlip.length > 0 && this.arrHeadShotFlip[0].offset_seconds > 0) {
						this.arrHeadShotFlip.unshift({ "offset_seconds": 0, "action": "headshot_flip", "mediaid": "", "steps": [] });
					}

					if (this.arrLayoutFlip.length > 0 && this.arrLayoutFlip[0].offset_seconds > 2) {
						var currentDefaultLayout = $.oViewerData.isAudio ? "LAYOUT_DEFAULT_AUDIO" : "LAYOUT_DEFAULT_VIDEO";
						this.arrLayoutFlip.unshift({ "offset_seconds": 0, "action": "layout_flip", "mediaid": currentDefaultLayout, "steps": [] });
					}

					$.oVideoInfo.laststep = 0;
					if ($.oViewerData.isSimlive) {
						console.log("VIEWERACTION line 84");
						$("#counterwrapper").hide();
						$.oViewerData.statusRefresh = $.viewerRefresh("status");
						$.dynamicDataTimer = setInterval(function () { $.viewerAction.getSimliveStatus() }, $.oViewerData.statusRefresh);
						if (!$.oViewerData.isPreSimlive) {
							if ($.activePlayer == $.viewerHTML5Player) {
								$.viewerAction.initOdTimer();
							} else {
								startIndex = $.oViewerData.pageloadtime - $.oViewerData.simlivestarttime;
								startIndex = Math.round(startIndex / 1000);
								var trySetPosition = function () {
									try {
										if (!$.activePlayer.playerLoaded()) {
											throw "No player loaded";
										}
										$.activePlayer.setPosition(startIndex);
										$.viewerAction.initOdTimer();
									} catch (ex) {
										setTimeout(function () {
											trySetPosition();
										}, 200)
									}
								}
								trySetPosition();
							}
						} else {
							$("#lobby").show();
						}
					} else {
						if (this.arrJumpPoints.length > 0 && !$.oViewerData.disable_od_seek) {
							this.initJumpPointDiv();
							this.loadThumbsurl();
						}
						this.initOdTimer();
					}  // end if-else isSimlive
				} else {
					if ($.oViewerData.sMode == "live") {
						if ($.oVideoInfo.sCurrentSlide != "") {
							$.viewerAction.flipslide($.oVideoInfo.sCurrentSlide);
						}
						if ($.oViewerData.isAudio) {
							if ($.browser.msie && $.browser.version == "7.0") {
								$.oVideoInfo.sCurrentHeadShot = "";
							}
							if ($.oVideoInfo.broadcasting == "0") {
								$.viewerControls.playerMsg("mediaDisconnect");
							}
						}
						if ($.oVideoInfo.sCurrentLayout != '') {
							var currentDefaultLayout = $.oViewerData.isAudio ? "LAYOUT_DEFAULT_AUDIO" : "LAYOUT_DEFAULT_VIDEO";
							$.viewerAction.oLastLiveAction.layout = $.oVideoInfo.sCurrentLayout;
							if ($.oVideoInfo.sCurrentLayout != currentDefaultLayout) {
								$.viewerAction.flipLayout($.oVideoInfo.sCurrentLayout);
							}
						}
						if ($.oViewerData.liveTranscriptEnabled) {
							$.viewerAction.initLiveTranscript();
						}
					} else {
						if ($.oViewerData.sPrelive_player_layout != '') {
							$.viewerAction.oLastLiveAction.layout = $.oVideoInfo.sCurrentLayout;
							$.viewerAction.flipLayout($.oViewerData.sPrelive_player_layout);
						}
					}
					$.oViewerData.statusRefresh = $.viewerRefresh("status");
					log("$.oViewerData.statusRefresh : " + $.oViewerData.statusRefresh);
					$.dynamicDataTimer = setInterval(function () { $.viewerAction.getLiveStatus() }, $.oViewerData.statusRefresh);
					setInterval(function () { $.viewerAction.liveflip() }, 1000);
				}  // end if-else isOD

				if ($.oViewerData.isAudio || $.oViewerData.playerType == "phone") {
					$.viewerAction.flipheadshot($.oVideoInfo.sCurrentHeadShot);
				}

				$("#odpausealert_close").click(function () {
					if ($.viewerAction.oActiveSecondaryMedia.active == true) {
						$("#secondarymedia").show();
					} else {
						$("#overlay_body").hide();
						$("#overlay_content").hide();
					}
					$("#odpausealert").hide();
					$.viewerAction.odpausestats = { "pausecnt": 0, "pausemsg": false, "pausemsgcntdown": 60 };
					document.title = $.oViewerData.sTitle;
				});
				$.oVideoInfo.totalDuration;
				this.startTracker();


			},  // end init
			initOdTimer: function () {
				log("viewerAction.initOdTimer called");
				$.dynamicODDataTimer = setInterval(function () { $.viewerAction.odflip() }, 1000);
				if ($.oViewerData.bUserControlSlides === true) {
					if ($.viewerSlide.oSlides.length > 0) {
						try {
							if ($.viewerSlide.oSlides[0].slides.length > 0) {
								$.viewerAction.flipslide($.viewerSlide.oSlides[0].slides[0].id);
							}
						} catch (error) {
							log("viewerAction.flipslide error: " + error.toString());
						}

					}
				}
			},
			hideLoading: function () {
				$("#loadingbox").remove();
				$("#overlay_body").addClass("overlay_body_opacity");
				$("#overlay_body").height($(document).height());
				if (($.oViewerData.sMode == "prelive" || $.oViewerData.isPreSimlive) && !($("#slide_title").length)) {
					$("#lobby").show();

				} else {
					$.viewerAction.hideLobby();

				}
			},
			togglebroadcasting: function (bflag) {
				if (bflag == $.oVideoInfo.broadcasting || $.oViewerData.sMode == "postlive") return;
				$.oVideoInfo.broadcasting = bflag;
				if ($.oViewerData.sMode == "live") {
					if (bflag == "0") {
						//$.viewerControls.playerMsg("mediaDisconnect");		        		
					} else {
						//Allow packatization of hls stream.
						setTimeout(function () {
							$.activePlayer.switchVideo();
							//$.viewerControls.hidePlayerMsg("mediaDisconnect");
						}, 14000);
					}
				}
			},
			hideLobby: function () {

				$("#lobby").remove();
				if ($.viewerAction.oActiveSecondaryMedia.active) {
					return;
				}
				$("#overlay_content").hide();
				$("#overlay_body").hide();
			},
			removeVideoAndShowOnlyControls: function () {
				console.log("removeVideoAndShowOnlyControls")
				$('.bitmovinplayer-container video').css({
					display: 'none',
					position: 'unset'
				});

				// Hide the .bmpui-ui-fullscreentogglebutton element
				//$('.bmpui-ui-fullscreentogglebutton').hide();
				$.activePlayer.hideFullscreenToggleButton();

				// Set the min-height of the .bitmovinplayer-container element to unset
				$('.bitmovinplayer-container').css('min-height', 'unset');

				// Select all elements within the .bmpui-ui-uicontainer.bmpui-player-state-playing.bmpui-controls-hidden element
				$('.bmpui-ui-uicontainer .bmpui-player-state-playing .bmpui-controls-hidden *').css('opacity', 1);
				$('.bmpui-ui-controlbar .bmpui-hidden').css('opacity', 1);
			},

			showVideoAndControls: function () {
				console.log("showVideoAndControls:function")
				$('.bmpui-ui-playbacktoggle-overlay .bmpui-ui-hugeplaybacktogglebutton').show();
				

				// Select the video element within the .bitmovinplayer-container
				$('.bitmovinplayer-container video').css({
					display: 'initial',
					position: 'absolute'
				});

				// Hide the .bmpui-ui-fullscreentogglebutton element
				//$('.bmpui-ui-fullscreentogglebutton').show();
				$.activePlayer.hideFullscreenToggleButton();

				// Set the min-height of the .bitmovinplayer-container element to unset
				$('.bitmovinplayer-container').css('min-height', '150px');

				// Select all elements within the .bmpui-ui-uicontainer.bmpui-player-state-playing.bmpui-controls-hidden element
				$('.bmpui-ui-uicontainer .bmpui-player-state-playing .bmpui-controls-hidden *').css('opacity', 0);
				$('.bmpui-ui-controlbar .bmpui-hidden').css('opacity', 0);
			},
			doLive: function () {
				$.viewerAction.hideLobby();
				if (!$.oViewerData.isAudio || $.oViewerData.isTelAudioAdvanced) {
					if ($.oViewerData.playerType == "phone") {
						$.viewerAction.flipheadshot("");
					} else {
						$.oViewerData.isStreamLive = true;
						$.viewerAction.iScriptDelay = $.viewerAction.iScriptDelay - $.oViewerData.getStatusLiveDelay;
						setTimeout('$.activePlayer.switchVideo()', $.viewerAction.iScriptDelay);//Audio uses broadcasting flasg..
						if ($.oViewerData.isTelAudioAdvanced) {
							$.viewerAction.flipheadshot("");
						}
					}
				} else {
					$.viewerAction.flipheadshot("");
				}
				if ($.oViewerData.isSlides) {
					$.viewerSlideTabs.activateSlideTab();
				}
				if ($.oViewerData.userAudioBackup && $.oViewerData.audiostreamid != "" && $.oViewerData.sMode == "live") {
					$("#toggleAudio").removeClass("ui-helper-hidden");
				}
				if ($.oViewerData.liveTranscriptEnabled) {
					$.viewerAction.initLiveTranscript();
				}

			},
			doPostLive: function (timestamp) {
				var delay = 0;
				if ($.oVideoInfo.status == "Playing") {
					delay = (timestamp - $.viewerTime.getCurMediaTime());
				}
				if (delay < 1) delay = 0;
				switch ($.oViewerData.playerType) {
					case "ios_audio":
					case "ios":
					case "hls_audio":
					case "hls":
						delay = delay + 4000;
						break;
					default:
						delay = delay + 1000;
						break;
				}
				delay = delay + $.viewerRefresh("endofevent");
				if (delay > 120000) delay = 120000;
				$("#passThruForm #act_type").val("end");
				log("viewerAction.doPostLive calling $.viewerAction.endSession with delay " + delay);
				$.viewerAction.endSession(delay);
			},
			liveflip: function () {
				try {
					console.log("VIEWERACTION liveflip");
					var curTime = $.viewerTime.getCurMediaTime();
					if ($("#showvt").length) {
						document.getElementById("showvt").innerHTML = new Date(curTime);
					}
					if ($.oViewerData.isSlides) {
						var sMode = $.viewerAction.getCurMediaMode();
						if ($.oViewerData.bUserControlSlides) {
							if ($.oVideoInfo.sCurrentSlide == "" && sMode === "live") {
								var slide = $.viewerSlide.oSlides[0];
								if (typeof slide != "undefined") {
									var slideId = $.viewerSlide.oSlides[0].slides[0].id;
									$.viewerAction.flipslide(slideId);
								}
							}
						} else {
							if (this.arrSlideFlip.length > 0 && curTime > this.arrSlideFlip[0].timestamp) {
								var slide = this.arrSlideFlip.shift();
								$.viewerAction.flipslide(slide.mediaid);
								if ($.oViewerData.sSlideType != "png" && slide.step !== "") {
									$.viewerSlide.loadStep(slide.step, slide.mediaid);
								}
							}
						}
					}
					if ($.oViewerData.isAudio && this.arrHeadShotFlip.length > 0 && curTime > this.arrHeadShotFlip[0].timestamp) {
						var hs = this.arrHeadShotFlip.shift();
						$.viewerAction.flipheadshot(hs.mediaid);
					}

					if (this.arrLayoutFlip.length > 0 && curTime > this.arrLayoutFlip[0].timestamp) {
						var layout = this.arrLayoutFlip.shift();
						$.viewerAction.flipLayout(layout.mediaid);
					}

					//log("curTime/LogTime" + curTime + " " + this.arrMisc[0].timestamp);
					if (this.arrMisc.length > 0 && curTime > this.arrMisc[0].timestamp) {
						var misc = this.arrMisc.shift();
						if (misc.action == "get_result") {
							$.viewerAction.showInEventSurvey('get_result', misc.mediaid)
						} else if (misc.action == "get_poll") {
							$.viewerAction.showInEventSurvey('get_poll', misc.mediaid)
						} else if (misc.action == "close_poll") {
							if ($.oVideoInfo.sCurrentSurvey == misc.mediaid) {
								$("#survey_frame").attr("src", "blank.html");
								$("#survey_frame").hide();
								$.viewerSlideTabs.hideSlideOverlay();
							}
						} else if (misc.action == "close_result") {
							if ($.oVideoInfo.sCurrentSurveyResult == misc.mediaid) {
								$("#surveyresult_frame").attr("src", "blank.html");
								$("#surveyresult_frame").hide();
								$.viewerSlideTabs.hideSlideOverlay();
							}
						}
					}
					if (this.arrSecondaryMedia.length > 0 && ($.oViewerData.playerType.indexOf("flash") == -1 || $.oVideoInfo.status.indexOf("Connecting") == -1) && curTime > this.arrSecondaryMedia[0].timestamp) {
						var misc = this.arrSecondaryMedia.shift();
						log("TPQA - misc : " + JSON.stringify(misc));
						if (misc.action == "launch_media") {
							if ($.viewerAction.overlayID != "") {
								$.viewerAction.getSeoondaryMedia(misc.mediaid, misc.timestamp, false);
							}
						} else if (misc.action == "launch_media_inline") {
							if ($.viewerAction.overlayID_inline != "") {
								$.viewerAction.getSeoondaryMedia(misc.mediaid, misc.timestamp, true);
							}
						} else if (misc.action == "launch_media_live") {
							$.viewerAction.showSecondaryMedia($.parseJSON(misc.mediaid), misc.timestamp, "live", false);
						} else if (misc.action == "close_media_live") {
							$.viewerAction.callcloseme(false);
						}
					}

					if ($.oViewerData.liveTranscriptEnabled && this.arrLiveTranscript.length > 0) {
						let transctipText = '';
						while (this.arrLiveTranscript.length > 0 && curTime > this.arrLiveTranscript?.[0].timestamp) {
							transctipText += this.arrLiveTranscript.shift().caption;
						}
						transctipText && $.viewerAction.renderTranscript(transctipText);
					}

				} catch (e) {
					log("Error in liveflip" + e.toString());
				}
			},
			odflip: function () {
				//console.log("odflip");
				//console.log(this.arrSecondaryMedia);
				//console.log($.oViewerData.isSimlive);
				//console.log($.oVideoInfo);
				if (!$.oViewerData.isSimlive) {
					if ($.oVideoInfo.status != "Playing") {
						$.viewerAction.odpausestats.pausecnt++;
						//odpausestats{"pausecnt":0,"pausemsg":false,"pausemsgcntdown":60},
						if ($.viewerAction.odpausestats.pausecnt > $.oViewerData.odpausetimeout) {
							if (!$.viewerAction.odpausestats.pausemsg) {
								$.viewerAction.odpausestats.pausemsg = true;
								$("#overlay_body").show();
								$("#overlay_body").css("z-index", "1001");
								if ($.viewerAction.oActiveSecondaryMedia.active == true) {
									$("#secondarymedia").hide();
								} else {
									$("#overlay_content").show();
								}
								$("#odpausealert").show();
							} else {
								$.viewerAction.odpausestats.pausemsgcntdown--;
								$("#odpausealert_cnt").html($.viewerAction.odpausestats.pausemsgcntdown);
								if (document.title == "") {
									document.title = $.oViewerData.sTitle;
								} else {
									$.oViewerData.sTitle = document.title;
									document.title = "";
								}
								if ($.viewerAction.odpausestats.pausemsgcntdown < 1) {
									log("odflip inactivity based on $.viewerAction.odpausestats.pausecnt " + $.viewerAction.odpausestats.pausecnt);
									log("Calling  $.viewerAction.endSession, local time : " + Date());
									$.viewerAction.endSession(600);
								}
							}
						}
						//return;
					} else if ($.viewerAction.odpausestats.pausecnt > 0) {
						$.viewerAction.odpausestats = { "pausecnt": 0, "pausemsg": false, "pausemsgcntdown": 60 };
						if (document.title == "") {
							document.title = $.oViewerData.sTitle;
						}
					}
				}

				if (this.arrCaptions.length > 0) {
					var tmpcaption = this.findLatest($.oVideoInfo.currentPosition, this.arrCaptions);
					if (tmpcaption != null) {
						$("#caption_txt").html(tmpcaption.txt);
					}
				}
				if (this.arrMisc.length > 0) {
					var misc = this.findNearest($.oVideoInfo.currentPosition, this.arrMisc);
					if (misc != null) {
						if (misc.action == "send_surveyresult" && $.oVideoInfo.sCurrentSurveyResult != misc.mediaid) {
							$.oVideoInfo.sCurrentSurveyResult = misc.mediaid;
							$.viewerAction.showInEventSurvey('get_result', misc.mediaid)
						} else if (misc.action == "send_survey" && $.oVideoInfo.sCurrentSurvey != misc.mediaid) {
							$.oVideoInfo.sCurrentSurvey = misc.mediaid;
							$.viewerAction.showInEventSurvey('get_poll', misc.mediaid)
						}
					}
				}
				if (this.arrSecondaryMedia.length > 0) {
					//console.log("OVER HERE OVER HERE OVER HERE");
					if ($.oVideoInfo.sCurrentSecondaryMedia == "") {
						//console.log("PART 2");
						for (var oTimes in this.arrSecondaryMedia) {
							//console.log("3");
							var _oTimes = this.arrSecondaryMedia[oTimes];
							if (($.oVideoInfo.currentPosition > _oTimes.offset_seconds) && ($.oVideoInfo.currentPosition < (_oTimes.offset_seconds + _oTimes.oMovie.duration - 3))) {
								$.oVideoInfo.sCurrentSecondaryMedia = _oTimes.mediaid;
								$.viewerAction.showSecondaryMedia(_oTimes.oMovie, _oTimes.offset_seconds, "od", false);
								if ($.oViewerData.isSimlive) {
									this.arrSecondaryMedia.splice(oTimes, 1);
								}
							}
						}
					} else {
						var _duration = $.viewerAction.oActiveSecondaryMedia.oMovie.duration;
						var _offset = $.viewerAction.oActiveSecondaryMedia.sMovieTs;
						if (($.oVideoInfo.currentPosition < _offset) || ($.oVideoInfo.currentPosition > (_offset + _duration))) {
							$.oVideoInfo.sCurrentSecondaryMedia = "";
						}
					}
				}
				if ($.oViewerData.isSlides) {
					if (this.arrSlideFlip.length == 0) {
						$.viewerAction.showSlideInfo($.oViewerText.wmsg_no_slides);
					} else {
						//find the latest slide
						var slide = this.findLatest($.oVideoInfo.currentPosition, this.arrSlideFlip);
						if (slide.mediaid != $.oVideoInfo.sCurrentSlide) {
							$.viewerAction.flipslide(slide.mediaid);
							$.oVideoInfo.laststep = 0;
							$.viewerSlide.currentStepIndex = 0;
							return;
						}
						if ($.oViewerData.sSlideType != "png") {
							//go to the current animation
							var stepIndex = this.findLatestStep($.oVideoInfo.currentPosition - slide.offset_seconds, slide.steps);
							if ($.oVideoInfo.laststep != stepIndex) {
								$.viewerSlide.loadStep(stepIndex, slide.mediaid);
								$.oVideoInfo.laststep = stepIndex;
							}
						}
					}
				}
				if ($.oViewerData.isAudio) {
					if (this.arrHeadShotFlip.length != 0) {
						var hs = this.findLatest($.oVideoInfo.currentPosition, this.arrHeadShotFlip);
						if (hs.mediaid != $.oVideoInfo.sCurrentHeadShot) {
							$.viewerAction.flipheadshot(hs.mediaid);
							$.oVideoInfo.sCurrentHeadShot = hs.mediaid;
						}
					}
				}

				if (this.arrLayoutFlip.length != 0) {
					var layoutTime = this.findLatest($.oVideoInfo.currentPosition, this.arrLayoutFlip);
					if (layoutTime.mediaid != $.oVideoInfo.sCurrentLayout) {
						$.viewerAction.flipLayout(layoutTime.mediaid);
						$.oVideoInfo.sCurrentLayout = layoutTime.mediaid;
					}
				}
			},
			findNearest: function (time, arrEvents) {
				for (timings in arrEvents) {
					if (time < arrEvents[timings].offset_seconds) {
						if ((arrEvents[timings].offset_seconds - time) < 2) {
							return arrEvents[timings];
						}
					}
				}
				return null;

			},
			findLatest: function (time, arrEvents) {
				var previndex = 0;
				for (timings in arrEvents) {
					if (time < arrEvents[timings].offset_seconds) {
						break;
					}
					previndex = timings;
				}
				return arrEvents[previndex];
			},
			findLatestStep: function (time, arrSteps) {
				if (arrSteps.length == 0) return 0;
				var prevIndex = 0;
				for (var currStep in arrSteps) {
					if (arrSteps[currStep].offset_seconds > time) {
						return prevIndex;
					}
					prevIndex = arrSteps[currStep].step_index;
				}
				return prevIndex;
			},
			checkRegionId: function () {
				$.ajax({
					type: "GET",
					cache: false,
					timeout: $.oViewerData.statusRefresh,
					url: "getstatus.jsp",
					data: ({ ei: $.oViewerData.sEventId, dType: "region", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime() }),
					dataType: "json",
					success: function (jsonResult) {
						try {
							$.viewerAction.doLive();
						} catch (e) {
							log("Error in checkRegionId success" + e.toString());
						}
					},
					error: function (jsonResult) {
						$.viewerAction.doLive();
					}
				});
			},
			getSimliveStatus: function () {
				$.ajax({
					type: "GET",
					cache: false,
					timeout: $.oViewerData.statusRefresh,
					url: "getstatus.jsp",
					data: ({ ei: $.oViewerData.sEventId, dType: "simlive", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime() }),
					dataType: "json",
					success: function (_jsonResult) {
						if (_jsonResult.status == "ondemand") {
							if ($.oViewerData.st == "-1" || $.oViewerData.st == "3") {
								$.oViewerData.st = "6_s";
							}
							if (isClosemeCalled || $.oVideoInfo.status != "Playing") {
								$.oViewerData.isSimlive = false;
								closeme();
							}
							return;
						} else if (_jsonResult.status == "prelive") {
							if (!$.oViewerData.isPreSimlive) {
								//event was rescheduled back to prelive, redirect to reg page
								var sRedirect = "/starthere.jsp?ei=" + $.oViewerData.sEventId;
								$.oViewerData.tp_key != '' ? window.location = sRedirect + "&tp_key=" + $.oViewerData.tp_key : window.location = sRedirect;
							}
						} else if (_jsonResult.status == "live") {
							$.oViewerData.simliveIndex = _jsonResult.playindex;
							var durationoffset = _jsonResult.durationoffset;
							if ($.oViewerData.isPreSimlive) {
								$.viewerAction.hideLobby();
								//change to "live" mode
								$.oViewerData.isPreSimlive = false;
								//load ondemand player
								$.activePlayer.switchVideo();
								$.oVideoInfo.currentPosition = 0;
								$.viewerAction.initOdTimer();
								if ($.oViewerData.isSlides) {
									$.viewerSlideTabs.activateSlideTab();
								}
							}
							if ($.oViewerData.st == "-1" || $.oViewerData.st == "3") {
								$.oViewerData.st = "4_s";
							}
							if (durationoffset < 15) {
								isSimLiveNearEnd = true;
							}

						}
						if (_jsonResult.message_to_viewers) {
							var message_to_viewers = _jsonResult.message_to_viewers.value;
							var message_to_viewers_ts = _jsonResult.message_to_viewers.timestamp;
							var serverTs = _jsonResult.serverts;
							if (message_to_viewers != "" && (serverTs - message_to_viewers_ts) > 600000) {
								message_to_viewers = "";
							}
							if (message_to_viewers == "") {
								$.oViewerMsg.custom = "";
								if ($.oVideoInfo.playerMsgType == "custom") $.viewerControls.hidePlayerMsg("custom");
							}
							if (message_to_viewers != $.oViewerMsg.custom && (serverTs - message_to_viewers_ts) < 600000) {
								$.oViewerMsg.custom = message_to_viewers;
								$.viewerControls.playerMsg("custom");
							}
						}

					}
				});
			},
			getLiveStatus: function () {
				console.log("VIEWERACTION getLiveStatus");
				$.ajax({
					type: "GET",
					cache: false,
					timeout: $.oViewerData.statusRefresh,
					url: "getstatus.jsp",
					data: ({ ei: $.oViewerData.sEventId, dType: "", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime(), lastUpdateTime: $.viewerTime.getTime("serverTs").server }),
					dataType: "json",
					success: function (_jsonResult) {
						try {
							var jsonResult = _jsonResult.status;
							var serverTs = _jsonResult.serverts;
							$.viewerTime.setTime("serverTs", serverTs);
							var mode = jsonResult.mode.value;
							if (mode == "ondemand") mode = "postlive";
							if (mode != $.oViewerData.sMode) {
								if (mode == "live") {
									$.oViewerData.livestarttime = jsonResult.mode.timestamp;
									$.oViewerData.getStatusLiveDelay = serverTs - $.oViewerData.livestarttime;
									$.viewerAction.checkRegionId();
								} else {
									if ($.oViewerData.st == "-1" || $.oViewerData.st == "0") {
										$.oViewerData.st = "5_s";
									}
									$.viewerAction.doPostLive(jsonResult.mode.timestamp);
								}
								$.oViewerData.sMode = mode;
							}

							if ($.oViewerData.sMode == "live") {
								if ($.oViewerData.st == "-1" || $.oViewerData.st == "0") {
									$.oViewerData.st = "1_s";
								}

								if (jsonResult.current_survey_id) {
									var curSurvey = jsonResult.current_survey_id.value;
									if (curSurvey != $.oVideoInfo.sCurrentSurvey) {
										$.oVideoInfo.sCurrentSurvey = curSurvey;
										$.viewerAction.arrMisc.push({ "timestamp": jsonResult.current_survey_id.timestamp, "action": "get_poll", "mediaid": curSurvey });
									}

								}
								if (jsonResult.current_surveyresult_id) {
									var curSurveyResult = jsonResult.current_surveyresult_id.value;
									if (curSurveyResult != $.oVideoInfo.sCurrentSurveyResult) {
										$.oVideoInfo.sCurrentSurveyResult = curSurveyResult;
										$.viewerAction.arrMisc.push({ "timestamp": jsonResult.current_surveyresult_id.timestamp, "action": "get_result", "mediaid": curSurveyResult });
									}
								}
								if (jsonResult.current_close_surveyresult_id) {
									var curCloseSurveyResult = jsonResult.current_close_surveyresult_id.value;
									if (curCloseSurveyResult != $.oVideoInfo.curCloseSurveyResult) {
										$.oVideoInfo.curCloseSurveyResult = curCloseSurveyResult;
										$.viewerAction.arrMisc.push({ "timestamp": jsonResult.current_close_surveyresult_id.timestamp, "action": "close_result", "mediaid": curCloseSurveyResult });
									}
								}
								if (jsonResult.current_close_survey_id) {
									var curCloseSurvey = jsonResult.current_close_survey_id.value;
									if (curCloseSurvey != $.oVideoInfo.curCloseSurvey) {
										$.oVideoInfo.curCloseSurvey = curCloseSurvey;
										$.viewerAction.arrMisc.push({ "timestamp": jsonResult.current_close_survey_id.timestamp, "action": "close_poll", "mediaid": curCloseSurvey });
									}
								}

								if ($.oViewerData.bInRoomView) {
									return;//In room view only Surveys...
								}
								if (jsonResult.current_slide_id) {

									if ($.oViewerData.playerType == "html5" && !$.oViewerData.isStreamLive) {
										//dont do anything cause html5 is delayed
									} else {
										var curSlide = jsonResult.current_slide_id.value;
										if (curSlide != $.viewerAction.oLastLiveAction.slide) {
											$.viewerAction.oLastLiveAction.slide = curSlide;
											$.viewerAction.oLastLiveAction.step = "";
											$.viewerAction.arrSlideFlip.push({ "timestamp": jsonResult.current_slide_id.timestamp, "mediaid": curSlide, "step": "" });
										}
										if ($.oViewerData.sSlideType != "png") {
											//switch to the latest animation
											if (jsonResult.current_step_index) {
												var curStep = jsonResult.current_step_index.value;
												if (curStep != $.viewerAction.oLastLiveAction.step) {
													$.viewerAction.oLastLiveAction.step = curStep;
													$.viewerAction.arrSlideFlip.push({ "timestamp": jsonResult.current_step_index.timestamp, "mediaid": curSlide, "step": +curStep });
												}
											}
										}
									}
								} else if ($.oViewerData.isSlides) {
									$.viewerAction.showSlideInfo($.oViewerText.wmsg_no_slides);
								}
								if ($.oViewerData.isAudio) {
									if (jsonResult.current_headshot_id) {
										var curHeadShot = jsonResult.current_headshot_id.value;
										if (curHeadShot != $.viewerAction.oLastLiveAction.headshot) {
											$.viewerAction.oLastLiveAction.headshot = curHeadShot;
											$.viewerAction.arrHeadShotFlip.push({ "timestamp": jsonResult.current_headshot_id.timestamp, "mediaid": curHeadShot });
										}
									}
								}
								if (jsonResult.current_viewer_layout) {
									var curLayout = jsonResult.current_viewer_layout.value;
									if (curLayout != $.viewerAction.oLastLiveAction.layout) {
										$.viewerAction.oLastLiveAction.layout = curLayout;
										$.viewerAction.arrLayoutFlip.push({ "timestamp": jsonResult.current_viewer_layout.timestamp, "mediaid": curLayout });
									}
								}
								if (jsonResult.current_secondarymedia_id) {

									var cursecondarymedia = jsonResult.current_secondarymedia_id.value;
									var cursecondarymedia_ts = jsonResult.current_secondarymedia_id.timestamp;

									$.viewerAction.overlayID = cursecondarymedia;
									if (cursecondarymedia_ts != $.viewerAction.oLastLiveAction.secondarymedia) {
										if (cursecondarymedia == "") {
											if ($("#secondarymedia").is(":visible")) {
												$.viewerAction.callcloseme(false);
											}
										} else {
											$.viewerAction.arrSecondaryMedia.push({ "timestamp": cursecondarymedia_ts, "action": "launch_media", "mediaid": cursecondarymedia });
										}
										$.viewerAction.oLastLiveAction.secondarymedia = cursecondarymedia_ts;
									}
								}
								if (jsonResult.current_secondarymedia_inline_id) {

									var cursecondarymedia = jsonResult.current_secondarymedia_inline_id.value;
									var cursecondarymedia_ts = jsonResult.current_secondarymedia_inline_id.timestamp;

									$.viewerAction.overlayID_inline = cursecondarymedia;
									if (cursecondarymedia_ts != $.viewerAction.oLastLiveAction.secondarymedia_inline) {
										if (cursecondarymedia == "") {
											//if($("#secondarymedia").is(":visible")) {//Find other check fo inline
											$.viewerAction.callcloseme(true);
											//}
										} else {
											$.viewerAction.arrSecondaryMedia.push({ "timestamp": cursecondarymedia_ts, "action": "launch_media_inline", "mediaid": cursecondarymedia });
										}
										$.viewerAction.oLastLiveAction.secondarymedia_inline = cursecondarymedia_ts;
									}
								}
								if (jsonResult.current_overlay_stream) {

									var curoverlaymedia = jsonResult.current_overlay_stream.value;
									var curoverlaymedia_ts = jsonResult.current_overlay_stream.timestamp;
									if (curoverlaymedia_ts != $.viewerAction.oLastLiveAction.overlaymedia) {
										if (curoverlaymedia == "") {
											if ($("#secondarymedia").is(":visible")) {
												$.viewerAction.arrSecondaryMedia.push({ "timestamp": curoverlaymedia_ts, "action": "close_media_live", "mediaid": "" });
											}
										} else {
											$.viewerAction.arrSecondaryMedia.push({ "timestamp": curoverlaymedia_ts, "action": "launch_media_live", "mediaid": curoverlaymedia });
										}
										$.viewerAction.oLastLiveAction.overlaymedia = curoverlaymedia_ts;
									}
								}

								if (jsonResult.current_player_stream) {
									if ($.oViewerData.userAudioBackup && $.oViewerData.audiostreamid != "" && $.oViewerData.sMode == "live" && $.oViewerData.audiostreamid != $.oViewerData.serverstreamid) {
										$("#toggleAudio").removeClass("ui-helper-hidden");
									}

									if ($.oViewerData.serverstreamid != jsonResult.current_player_stream.value && !$("#secondarymedia").is(":visible")) {
										if ($.oViewerData.currentstreamid == $.oViewerData.serverstreamid || $.oViewerData.isRolledBackToBackupUnicast) {
											$.oViewerData.currentstreamid = jsonResult.current_player_stream.value;

											//If viewer is only listen by phone, dont switch player
											if ($.oViewerData.playerType != "phone") {
												if ($.oViewerData.isIOS) {
													setTimeout("$.activePlayer.stop();", $.viewerAction.iScriptDelay);
												}
												setTimeout("$.activePlayer.switchVideo();", $.viewerAction.iScriptDelay);
											}

											//On Stream switch show a different number
											if ($.oViewerData.isTelAudioAdvanced) {// && $.oViewerData.playerType=="phone"
												if (jsonResult.current_player_stream.value == $.oViewerData.primaryStreamId) {
													$.oViewerData.bridgePriority = 0;
												} else {
													$.oViewerData.bridgePriority = 1;
												}
												$.viewerAction.getAudienceBridge();
											}
										}
										$.oViewerData.serverstreamid = jsonResult.current_player_stream.value;
										if (jsonResult.current_player_stream.value == $.oViewerData.audiostreamid) {
											$("#toggleAudio").addClass("ui-helper-hidden");
										} else if ($.oViewerData.userAudioBackup && $.oViewerData.sMode == "live") {
											$("#toggleAudio").removeClass("ui-helper-hidden").find("span").removeClass("ui-icon-video").addClass("ui-icon-signal").attr("alt", "Switch to Audio Stream").attr("title", "Switch to Audio Stream");
											$("#toggleAudio").removeClass("show-video-icon").addClass("show-audio-icon").attr("alt", "Switch to Audio Stream").attr("title", "Switch to Audio Stream");
										}
									}
								}
								var uAudioBackup = jsonResult.user_audio_backup && jsonResult.user_audio_backup.value == 1;
								if (uAudioBackup != $.oViewerData.userAudioBackup) {
									$("#toggleAudio").toggleClass("ui-helper-hidden", !uAudioBackup);
									$.oViewerData.userAudioBackup = uAudioBackup;
									if ($.oViewerData.serverstreamid == $.oViewerData.audiostreamid) {
										$("#toggleAudio").addClass("ui-helper-hidden");
									}
								}


								if ($.oViewerData.liveTranscriptEnabled) {
									let liveCaptions = _jsonResult?.captions;
									liveCaptions && liveCaptions.forEach(elem => {
										$.viewerAction.arrLiveTranscript.push({ "timestamp": elem.s, "caption": elem.text });
									});
								}
							}
							if ($.oViewerData.bInRoomView) {
								return;//In room view only Surveys...
							}

							if ($.oViewerData.playerType != "phone" && jsonResult.broadcasting && !$.viewerAction.oActiveSecondaryMedia.active) {
								var broadcasting = jsonResult.broadcasting.value;
								if (broadcasting != $.oVideoInfo.broadcasting) {
									$.viewerAction.togglebroadcasting(broadcasting);
								}
							}

							if (jsonResult.message_to_viewers) {
								var message_to_viewers = jsonResult.message_to_viewers.value;
								var message_to_viewers_ts = jsonResult.message_to_viewers.timestamp;
								if (message_to_viewers != "" && (serverTs - message_to_viewers_ts) > 600000) {
									message_to_viewers = "";
								}
								if (message_to_viewers == "") {
									$.oViewerMsg.custom = "";
									if ($.oVideoInfo.playerMsgType == "custom") $.viewerControls.hidePlayerMsg("custom");
								}
								if (message_to_viewers != $.oViewerMsg.custom && (serverTs - message_to_viewers_ts) < 600000) {
									$.oViewerMsg.custom = message_to_viewers;
									$.viewerControls.playerMsg("custom");
								}
							}

						} catch (e) {
							log("Error in getLiveStatus success" + e.toString());
						}
					}
				});
			},
			getSlideJson: function (swfid) {
				tmpswfid = swfid;
				$.ajax({
					type: "GET",
					cache: false,
					timeout: $.oViewerData.statusRefresh,
					url: "getstatus.jsp",
					data: ({ ei: $.oViewerData.sEventId, dType: "slides", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime() }),
					dataType: "json",
					success: function (jsonResult) {
						try {
							$.viewerSlide.oSlides = jsonResult;
							var slidepath = $.viewerSlide.getSlidePath(tmpswfid);
							if (slidepath.deckid != "") {
								$.viewerAction.flipslide(tmpswfid);
							} else {
								log("Error in getSlideJson, can not get details for swfid" + tmpswfid);
							}
						} catch (e) {
							log("Error in getSlideJson success" + e.toString());
						}
					}
				});
			},
			flipslide: function (swfid) {
				if (swfid != "") {
					var slidepath = $.viewerSlide.getSlidePath(swfid);
					if (slidepath.deckid != "") {
						if ($.oViewerData.bUserControlSlides) {
							$.viewerSlide.loadSlide(slidepath.deckid, 0);
						} else {
							$.viewerSlide.loadSlide(slidepath.deckid, slidepath.index);
						}
						$.oVideoInfo.sCurrentSlide = swfid;
					} else {
						this.getSlideJson(swfid);
					}
				}
			},
			showSlideInfo: function (infotxt) {
				$("#slideinfo").html(infotxt);
			},
			endSession: function (delay) {
				isCloseClicked = true;
				doEndSession(false, delay);
			},
			getSessionType: function () {
				if (($.oViewerData.st == "-1" || $.oViewerData.st == "0") && $.oViewerData.sMode == "live") {
					return "1";
				} else if (($.oViewerData.st == "-1" || $.oViewerData.st == "3") && $.oViewerData.sMode == "ondemand" && $.oViewerData.isSimlive && !$.oViewerData.isPreSimlive) {
					return "4";
				}
			},
			startTracker: function () {
				$.oViewerData.trackerRefresh = $.viewerRefresh("tracker");
				log("$.oViewerData.trackerRefresh : " + $.oViewerData.trackerRefresh);
				$.trackerid = setInterval(this.tracker, $.oViewerData.trackerRefresh);
				this.tracker();
				//$.backuptrackerid = setInterval(this.backuptracker,$.oViewerData.trackerRefresh * 4);
			},
			tracker: function () {
				if ($.oViewerData.sMode == "postlive") {
					log("tracker will not be called event mode : " + $.oViewerData.sMode);
					if ($.trackerid) clearInterval($.trackerid);
				}
				var st = "";
				if ($.oViewerData.st.indexOf("_s") > 0) {
					st = parseInt($.oViewerData.st);
				}
				var tdata = "?ei=" + $.oViewerData.sEventId + "&ui=" + $.oViewerData.ui + "&si=" + $.oViewerData.si + "&st=" + st + "&ts=" + (new Date()).getTime();
				try {
					$.ajax({
						type: 'POST',
						dataType: 'json',
						timeout: $.oViewerData.trackerRefresh,
						data: { 'ea': $.oViewerData.ea },
						url: $.oViewerData.trackerUrl + tdata,
						success: function (result) {
							if (result.status == "BANNED") {
								window.location.replace("removed.jsp?ei=" + $.oViewerData.sEventId + "&language=" + $.oViewerData.language);
							} else if (result.status == "OK") {
								if ((result.stype == "1" || result.stype == "4")) {
									$.oViewerData.st = result.stype;
								}
							}
						},
						error: function (xhr, status, error) {
							$("#reporter").attr("src", "images/blank.gif" + tdata + "&t=error1&td=" + encodeURIComponent(status + "||" + error));
							log("tracker error1: " + status + "||" + error);
							$.viewerAction.tracker_backup_ajax();
						}
					});
				} catch (error) {
					$("#reporter").attr("src", "images/blank.gif?" + tdata + "&t=error2&td=" + encodeURIComponent(error.message));
					log("tracker error2: " + error.message);
					$.viewerAction.tracker_backup_ajax();
				}
			},
			tracker_backup_ajax: function () {
				var st = "";
				if ($.oViewerData.st.indexOf("_s") > 0) {
					st = parseInt($.oViewerData.st);
				}
				var tdata = "?ei=" + $.oViewerData.sEventId + "&ui=" + $.oViewerData.ui + "&si=" + $.oViewerData.si + "&st=" + st + "&ts=" + (new Date()).getTime();
				try {
					$.ajax({
						type: 'POST',
						dataType: 'json',
						timeout: $.oViewerData.trackerRefresh,
						data: { 'ea': $.oViewerData.ea },
						url: 't11.jsp' + tdata,
						success: function (result) {
							if (result.status == "BANNED") {
								window.location.replace("removed.jsp?ei=" + $.oViewerData.sEventId + "&language=" + $.oViewerData.language);
							} else if (result.status == "OK") {
								if ((result.stype == "1" || result.stype == "4")) {
									$.oViewerData.st = result.stype;
								}
							}
						},
						error: function (xhr, status, error) {
							$("#reporter").attr("src", "images/blank.gif" + tdata + "&t=error3&td=" + encodeURIComponent(status + "||" + error));
							log("tracker error3: " + status + "||" + error);
						}
					});
				} catch (error) {
					$("#reporter").attr("src", "images/blank.gif?" + tdata + "&t=error4&td=" + encodeURIComponent(error.message));
					log("tracker error4: " + error.message);
				}
			},
			backuptracker: function () {
				try {
					document.trackerform.submit();
				} catch (error) {
					log("backuptracker error: " + error.toString());
				}
			},
			flipheadshot: function (headshot_id) {
				if ($.oViewerData.bInRoomView) {
					return;
				}

				if ($.oViewerData.sMode == "prelive") {
					$("#noheadshot").hide();
					$("#headshot").show();
					$.oVideoInfo.sCurrentHeadShot = headshot_id;
					return;
				}
				if (headshot_id == "") {
					$("#noheadshot").show();
					$("#headshot").hide();
					$.oVideoInfo.sCurrentHeadShot = headshot_id;
					return;
				}
				var filename = $.viewerUploads.getHeadShotPath(headshot_id);
				if (filename != "") {
					$.viewerAction.loadHeadshot(filename);
					$.oVideoInfo.sCurrentHeadShot = headshot_id;
					return;
				}

				//headshot was not found
				if (headshot_id != "" && filename == "") {
					$.ajax({
						type: "GET",
						cache: false,
						timeout: $.oViewerData.statusRefresh,
						url: "getstatus.jsp",
						data: ({ ei: $.oViewerData.sEventId, dType: "uploads", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime() }),
						dataType: "json",
						success: function (jsonResult) {
							try {
								$.viewerUploads.oUpoloadsData = jsonResult;
								$.viewerUploads.reloadTypes();
								filename = $.viewerUploads.getHeadShotPath(headshot_id);
								if (filename != "") {
									$.viewerAction.loadHeadshot(filename);
									$.oVideoInfo.sCurrentHeadShot = headshot_id;
								} else {
									setTimeout(function () { $.viewerAction.flipheadshot(headshot_id) }, 30000);
								}
							} catch (e) {
								log("Error in getUploads success" + e.toString());
							}
						}
					});
				}
			},

			flipLayout: function (layoutId) {
				//if($("#lobby").length==0){
				//	$('#overlay_body').css({'display' : 'none'});
				//}
				if ($.oViewerData.bInRoomView) {
					return;
				}
				//var removeVideoAndShowOnlyControls;
				/*** Removes the video and shows only the controls.*/
				//$.viewerAction.showVideoAndControls();
				console.log("TPQA - flipLayout  " + layoutId);
				//$("#player").data("ui-viblastprototype").layoutchange(layoutId);
				$("#bitmovinplayer-video-flvplayer").show()
				switch (layoutId) {
					case "LAYOUT_DEFAULT_VIDEO":
						$('#viewer_slide').removeClass('slidesTurnedOff');
						$('#viewer').removeClass('removeSlide125');
						$('body').removeClass('removeVideo125');
						$('#viewer').removeClass('largeSlideVideo');
						$('#viewer').removeClass('largeVideoSlide');
						this.removeMsgAllSlidesOnly();
						$.viewerSlideTabs.addSlideTab();
						autoResizeVid();
						$('body').removeClass('slidesOnlyNvideoOnly');
						break;
					case "LAYOUT_DEFAULT_AUDIO":
						$('#viewer_slide').removeClass('slidesTurnedOff');
						$('#viewer').removeClass('removeSlide125');
						$('body').removeClass('removeVideo125');
						this.removeMsgAllSlidesOnly();
						$.viewerSlideTabs.addSlideTab();
						autoResizeVid_viewer125(false);
						$('body').removeClass('slidesOnlyNvideoOnly');
						break;
					case "LAYOUT_VIDEO_LARGE":
						$('#viewer_slide').removeClass('slidesTurnedOff');
						$('#viewer').removeClass('removeSlide125');
						$('body').removeClass('removeVideo125');
						$('#viewer').removeClass('largeSlideVideo');
						this.removeMsgAllSlidesOnly();
						$.viewerSlideTabs.addSlideTab();

						$('#viewer').addClass('largeVideoSlide');
						autoResizeVid_viewer125(true);
						$('body').removeClass('slidesOnlyNvideoOnly');
						break;
					case "LAYOUT_SLIDE_LARGE":
						$('#viewer_slide').removeClass('slidesTurnedOff');
						$('#viewer').removeClass('removeSlide125');
						$('body').removeClass('removeVideo125');
						$('#viewer').removeClass('largeVideoSlide');
						this.removeMsgAllSlidesOnly();
						$.viewerSlideTabs.addSlideTab();

						$('#viewer').addClass('largeSlideVideo');
						autoResizeVid_viewer125(false);
						$('body').removeClass('slidesOnlyNvideoOnly');
						break;
					case "LAYOUT_VIDEO_ONLY":
					case "LAYOUT_SCREENSHARE_ONLY":
						$('body').removeClass('removeVideo125');
						$('#viewer').removeClass('largeSlideVideo');
						$('#viewer').removeClass('largeVideoSlide');

						$('#viewer_slide').addClass('slidesTurnedOff');
						$('#viewer').addClass('removeSlide125');

						this.removeMsgAllSlidesOnly();
						autoResizeVid_viewer125(true);

						if ($('.transcript_caption').hasClass('hidden') && $.oViewerData.captionsVisible) {
							$('.transcript_caption').removeClass('hidden')
						}

						// close verbit full captions view and open view below video
						//if($('.verbitTranscriptDi').hasClass('open') && $.oViewerData.liveTranscriptEnabled){
						//	$('#transcript_close').trigger("click");
						//}

						$('body').addClass('slidesOnlyNvideoOnly');
						$.viewerSlide.closeLargeSlide();
						break;
					case "LAYOUT_SLIDE_ONLY":
						if ($.viewerSlide.blrgSlide) {
							$.viewerSlide.closeLargeSlide();
						}
						$('#viewer_slide').removeClass('slidesTurnedOff');
						$('#viewer').removeClass('removeSlide125');
						$('#viewer').removeClass('largeSlideVideo');
						$('#viewer').removeClass('largeVideoSlide');

						$.viewerSlideTabs.addSlideTab();
						$('body').addClass('removeVideo125');
						
						
						//removeVideoAndShowControls();
						$("#bitmovinplayer-video-flvplayer").hide()
						$('#bmpui-id-21').hide()
						//$.viewerAction.removeVideoAndShowOnlyControls();
						if($.oViewerData.sMode=='ondemand'){
							$.activePlayer.showSeekBar()
						}


						/*if($('.vjs-playing').css('display') == 'block'){
							$('.slidesOnlyPlayer__pause').css({'display' : 'block'});
						}else{
							$('.slidesOnlyPlayer__play').css({'display' : 'block'});
							}
						if($('.vjs-vol-0').css('display') == 'block'){
							$('.slidesOnlyPlayer__volume-down').css({'display' : 'block'});
						}else{
							$('.slidesOnlyPlayer__volume-up').css({'display' : 'block'});
						}*/

						this.AddMsgAllSlidesOnly();
						autoResizeVid_viewer125(false);

						if (!$('.transcript_caption').hasClass('hidden') && $.oViewerData.captionsVisible && ($('#transcriptDiv').css('display') === 'block')) {
							$('.transcript_caption').addClass('hidden');
						}

						$('body').addClass('slidesOnlyNvideoOnly');
						break;
					default:
						break;
				}
				$.oWindowSize.w += 10; //This will force resize code..
				$.viewerResize();

			},
			loadHeadshot: function (filename) {
				if ($.oViewerData.bUseQTiframe && !$.oViewerData.isAudio) {
					//ios video event, use player background
					document.frames["fPlayer"].setVideoBg(filename);
					return;
				}
				$("#headshot").attr("src", filename);
				$("#noheadshot").hide();
				$("#headshot").show();
			},
			getCurMediaMode: function () {
				if ($.oViewerData.isAudio && !$.oViewerData.isOD && !$.oViewerData.isTelAudioAdvanced) {
					if ($.oVideoInfo.broadcasting == "1") {
						return "live";
					}
					return "prelive";
				}
				if ($.oViewerData.isPreSimlive) {
					return "prelive";
				}
				return $.oViewerData.sMode;
			},
			initJumpPointDiv: function () {

				console.log("initJumpPointDiv: " + this.arrJumpPoints.length + " jump points.");

				var onerrorsrc = $.oViewerData.sTemplatePath + "style/images/jumppoints_blank.png";
				for (jumpPoint in this.arrJumpPoints) {
					console.log("initJumpPointDiv: jumpPoint=" + JSON.stringify(this.arrJumpPoints[jumpPoint], null, 2));
					switch (this.arrJumpPoints[jumpPoint].action) {
						case "slide_flip":
							if ($.oViewerData.bUserControlSlides) continue;
							var slidepath = $.viewerSlide.getSlidePath(this.arrJumpPoints[jumpPoint].mediaid);
							var thumbsurl = $.oViewerData.sContentUrl + slidepath.deckid + "/tmb/Slide" + (parseInt(slidepath.index, 10) + 1) + "." + $.viewerSlide.findDeckObj(slidepath.deckid).thumbext;
							break;
						case "headshot_flip":
							var thumbsurl = $.viewerUploads.getHeadShotPath(this.arrJumpPoints[jumpPoint].mediaid);
							break;
						case "send_surveyresult":
							var thumbsurl = $.oViewerData.sTemplatePath + "style/images/surveyresult_icon.png";
							break;
						case "send_survey":
							var thumbsurl = $.oViewerData.sTemplatePath + "style/images/survey_icon.png";
							break;
						case "jump_point":
							var thumbsurl = $.oViewerData.sContentUrl + $.oViewerData.sEventGUID + "jump_points/" + this.arrJumpPoints[jumpPoint].odlogid + ".png";
							break;
						case "launch_media":
							var thumbsurl = $.oViewerData.sContentUrl + "previews/" + this.arrJumpPoints[jumpPoint].mediaid + ".png";
							break;
					}

					var thumbid = "jumpPointThumb_" + ($.viewerAction.arrThumbsurl.length + 1);
					$.viewerAction.arrThumbsurl.push({ "id": thumbid, "thumburl": thumbsurl });

					console.log("initJumpPointDiv: thumbid=" + thumbid + "; thumburl=" + thumbsurl);

					var jumpPointTitle = $.htmlEncode(this.arrJumpPoints[jumpPoint].title);

					var jumpPointButton = 
						"<button".concat(" href=\"#\"")
								 .concat(" onclick=\"$.viewerAction.goToJumpPoint('" + this.arrJumpPoints[jumpPoint].offset_seconds + "','" + this.arrJumpPoints[jumpPoint].action + "');return false\"")
								 .concat(" class=\"jumpPointBtns\" aria-label=\"" + jumpPointTitle + " Chapter\">")
								 .concat("<div class=\"jumpPointWrapper\">")
								 .concat("<img src=\"" + onerrorsrc + "\" id=\""+ thumbid + "\" hspace=\"0\" vspace=\"0\" width=\"80\" height=\"60\" style=\"z-index:1;display:none\" class=\"jumpPointThumb\" alt=\"" + jumpPointTitle + "\"/>")
								 //.concat("<img src=\"" + $.oViewerData.sTemplatePath + "style/images/jump_play.png\" width=\"80\" height=\"60\" style=\"z-index:2\" class=\"jumpPointPlay\" alt=\"play\"/>")	        		                               
								 .concat("<div class=\"jumpPointDetails\">")
								 .concat("<p class=\"jumpPointTitle\">" + jumpPointTitle + "</p>")
								 .concat("<p class=\"jumpPointTime\">" + $.viewerControls.timeToString(this.arrJumpPoints[jumpPoint].offset_seconds) + "</p>")
								 .concat("</div>")
								 .concat("</div>")
								 .concat("</button>");
								 
					// TODO: remove orig one-liner
					//$("#jumppointdiv").append("<button href=\"#\" onclick=\"$.viewerAction.hideJumpPoint('" + this.arrJumpPoints[jumpPoint].offset_seconds + "','" + this.arrJumpPoints[jumpPoint].action + "');return false\" class=\"jumpPointBtns\" aria-label=\"" + jumpPointTitle + " Chapter\"><div class=\"jumpPointWrapper\"><img src=\"" + onerrorsrc + "\" id=\""+ thumbid + "\" hspace=\"0\" vspace=\"0\" width=\"80\" height=\"60\" style=\"z-index:1;display:none\" class=\"jumpPointThumb\" alt=\"" + jumpPointTitle + "\"/><img src=\"" + $.oViewerData.sTemplatePath + "style/images/jump_play.png\" width=\"80\" height=\"60\" style=\"z-index:2\" class=\"jumpPointPlay\" alt=\"play\"/><div class=\"jumpPointDetails\"><span class=\"jumpPointTime\">" + $.viewerControls.timeToString(this.arrJumpPoints[jumpPoint].offset_seconds) +  " </span><span class=\"jumpPointTitle\"> " + jumpPointTitle + "</span></div></div></button>");

					//console.log("JEFF=" + jumpPointButton);
 					$("#jumppointdiv").append(jumpPointButton);
				}
			},
			loadThumbsurl: function () {
				if ($.viewerAction.arrThumbsurl.length > 0) {
					oThumb = $.viewerAction.arrThumbsurl.shift();
					//log("Loading oThumb " + oThumb.id + " " + oThumb.thumburl);
					$("#" + oThumb.id).load(function () {
						log("loadThumbsurl: Thumb loaded; id=" + oThumb.id + " url=" + oThumb.thumburl);
						$("#" + oThumb.id).show();
						setTimeout("$.viewerAction.loadThumbsurl()", 5);
					});
					$("#" + oThumb.id).error(function () {
						log("loadThumbsurl: Thumb load error; id=" + oThumb.id + " url=" + oThumb.thumburl);
						setTimeout("$.viewerAction.loadThumbsurl()", 5);
					});
					$("#" + oThumb.id).attr("src", oThumb.thumburl);
				} else {
					log("loadThumbsurl: No Thumbs to load.");
				}
			},
			showJumpPoint: function () {
				/// move jumppointframe to correct spot  \\\\\\\\\\\
				var isMobile = ($(window).width() < 640) ? true : false;

				if (isMobile) {
					document.getElementById('jumppointframe').style.top = $('#viewer_banner').height() + $('#viewer_video').height() + $('#viewer_slide').height() + 'px';
					document.getElementById('jumppointframe').style.left = 0 + 'px';
				} else {
					document.getElementById('jumppointframe').style.top = $('#viewer_banner').height() + 'px';

					if ($('#playerBody').hasClass('removeVideo125')) {
						/// if slide only \\\\\\\\\\\\
						document.getElementById('jumppointframe').style.left = (($('#playerBody').width() - $('#viewer_slide').width()) / 2) + 'px';
						var jumppointFrameHeight = $('#viewer').height() - $('#top-control-bar').height() - 5;
						$('#jumppointframe').height(jumppointFrameHeight);
					} else if ($('#viewer').hasClass('removeSlide125')) {
						/// if video only \\\\\\\\\\\\\\\\
						document.getElementById('jumppointframe').style.left = (($('#playerBody').width() - $('#viewer_video').width()) / 2) + 'px';
						var jumppointFrameHeight = $('#viewer').height() - $('#top-control-bar').height() - 5;
						$('#jumppointframe').height(jumppointFrameHeight);
					} else {
						$('#jumppointframe').height($('#viewer').height());
						var extraSpace = ($('#playerBody').width() - ($('#viewer_video').width() + $('#viewer_slide').width())) / 2;
						document.getElementById('jumppointframe').style.left = $('#viewer_video').width() + extraSpace + 'px';
					}
				}

				$("#jumppointframe").show("slide", {}, "slow");
				$("#jumppoint").addClass('ui-state-active').addClass('open');
				if ($.viewerAction.arrThumbsurl.length > 0 && !$.viewerAction.bThumbCachingStarted) {
					$.viewerAction.loadThumbsurl();
				}
				$('.vjs-jumppoint-control').addClass('jumppointColor');

				// accesibilty
				document.getElementById('jumppointframe').focus();

				if (document.getElementById('jumppointframe') !== null) {
					let jumpPointBtnsLength = $('.jumpPointBtns').length;

					tabNext(document.getElementsByClassName('jumpPointBtns')[jumpPointBtnsLength - 1], document.getElementById('jump_close'));

					// close jumpoint modal aka menu
					document.addEventListener('keydown', function (e) {
						if (e.keyCode == 27 && document.getElementById('jumppointframe').style.display === 'block') {
							e.preventDefault();
							document.getElementById('jump_close').click();
						}
					});
				}

				function tabNext(current, next) {
					current.addEventListener('keydown', function (e) {
						if (e.keyCode == 9 && document.getElementById('jumppointframe').style.display === 'block') {
							e.preventDefault();

							try {
								next.focus();
							} catch (err) {
								console.log(err);
							}
						}
					});
				}
			},
			goToJumpPoint: function (jumpto, jumpact) {
				console.log("goToJumpPoint: jumpto=" + jumpto + " jumpact=" + jumpact);
				if (jumpto != "") {
					if (jumpto > 1 && (jumpact == "send_survey" || jumpact == "send_surveyresult")) {
						jumpto--;
					}
					$.activePlayer.setPosition(jumpto);
					if ($.oVideoInfo.status == "Paused") {
					    console.log("goToJumpPoint: Player is paused; calling play");
						$.activePlayer.play();
					}
				}
			},
			showInEventSurvey: function (task, survey_id) {
				var ret_url = self.location.protocol + "//" + self.location.hostname + "/viewer/closesurvey.jsp?task=" + task + "&id=" + survey_id;
				var event_status = ($.oViewerData.isOD) ? "od" : "live";
				if ($.viewerSlide.blrgSlide) {
					$.viewerSlide.closeLargeSlide();
				}
				if (!$.oViewerData.bInRoomView) {
					$.viewerSlideTabs.showSlideOverlay();
				}
				if (task == "get_poll") {
					$("#survey_frame").show().focus();
					$("#survey_frame").attr("src", $.oViewerData.surveyModule + "index_viewer.php?task=get_poll&estatus=" + event_status + "&poll_id=" + survey_id + "&ret=" + ret_url + "&u_id=" + $.oViewerData.ui + "&session_id=" + $.oViewerData.si);
				} else if (task == "get_result") {
					$("#surveyresult_frame").show().focus();
					$("#surveyresult_frame").attr("src", $.oViewerData.surveyModule + "index_viewer.php?task=get_results&estatus=" + event_status + "&snapshot_id=" + survey_id + "&ret=" + ret_url + "&u_id=" + $.oViewerData.ui);
				} else {
					return;
				}

			},
			closeInEventSurvey: function (task) {
				if (task == "get_poll") {
					$("#survey_frame").attr("src", "blank.html");
					$("#survey_frame").hide();
					if ($.oViewerData.isOD) {
						$.oVideoInfo.sCurrentSurvey = ""; // SO if seeked again we will show it.
					}
				} else {
					$("#surveyresult_frame").attr("src", "blank.html");
					$("#surveyresult_frame").hide();
					if ($.oViewerData.isOD) {
						$.oVideoInfo.sCurrentSurveyResult = ""; // SO if seeked again we will show it.
					}
				}
				$.viewerSlideTabs.hideSlideOverlay();
			},

			showTranscriptDiv: function () {
				if ($('#survey_frame').is(':visible') || $('#surveyresult_frame').is(':visible')) {
					return;
				}

				$.viewerSlideTabs.showSlideOverlay();
				$('#transcriptDiv').show('slide', {}, 'slow');
				$('#searchBtn').addClass('jumppointColor');
			},

			hideTranscriptDiv: function () {
				$('#transcriptDiv').hide();
				$('#searchBtn').removeClass('jumppointColor');
				$.viewerSlideTabs.hideSlideOverlay();
			},

			getSeoondaryMediaObj: function (movieid) {
				for (var oMovie in $.oSecondaryMedia) {
					if ($.oSecondaryMedia[oMovie].movieid == movieid) {
						return $.oSecondaryMedia[oMovie];
					}
				}
				return null;
			},
			getSeoondaryMedia: function (movieid, moviets, bInline) {
				console.log("VIEWERACTION getSecondaryMedia");
				if ($.oSecondaryMedia != null) {
					var oMovie = $.viewerAction.getSeoondaryMediaObj(movieid);
					if (oMovie != null) {
						$.viewerAction.showSecondaryMedia(oMovie, moviets, "od", bInline);
						return;
					}
				}
				$.ajax({
					type: "GET",
					cache: false,
					timeout: $.oViewerData.statusRefresh,
					url: "getstatus.jsp",
					data: ({ ei: $.oViewerData.sEventId, dType: "secondarymedia", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime() }),
					dataType: "json",
					success: function (jsonResult) {
						try {
							$.oSecondaryMedia = jsonResult;
							var oMovie = $.viewerAction.getSeoondaryMediaObj(movieid);
							if (oMovie != null) {
								$.viewerAction.showSecondaryMedia(oMovie, moviets, "od", bInline);
							}
						} catch (e) {
							log("Error in getSeoondaryMedia success" + e.toString());
						}
					}
				});
			},
			showSecondaryMedia: function (oMovie, sMovieTs, sSecondaryMediaMode, bInline) {
				console.log("VIEWERACTION  showSecondaryMedia");
				if (!$.oViewerData.isOD && sSecondaryMediaMode != "live") {
					var curTime = $.viewerTime.getCurMediaTime();
					var movieDuration = oMovie.duration * 1000;
					//If viewer in late and less than 2second of appdemo left, don;t bother.
					if ((curTime - sMovieTs) > (movieDuration - 2000)) {
						return;
					}
				}
				$.viewerAction.oActiveSecondaryMedia.active = true;
				$.viewerAction.oActiveSecondaryMedia.oMovie = oMovie;
				$.viewerAction.oActiveSecondaryMedia.sMovieTs = sMovieTs;
				$.viewerAction.oActiveSecondaryMedia.bInline = bInline;

				if ($.oViewerData.isOD) {
					$.activePlayer.pause();
				} else {
					$.activePlayer.stop();
				}

				if ($.oMulticast.isHiveMulticast) {
					$.activePlayer.closeHiveSession();
				}



				//inline code
				if (bInline && $.oViewerData.playerType != "phone") {
					log("TPQA - Inline Overlay called..");
					$.activePlayer.switchVideoOverlay();
					return true;
				}

				//log("$.viewerAction.oActiveSecondaryMedia.oMovie" + $.viewerAction.oActiveSecondaryMedia.oMovie);
				var width = oMovie.width;
				var height = oMovie.height;
				var wh = $(window).height();
				var ww = $(window).width();
				var sizeRatio = width / height;
				if (width >= ww && width > 800) {
					if (width <= 900 || ww <= 800) {
						width = 800;
					} else {
						width = ww - 100;
					}
					height = width / sizeRatio;
				}
				var _height = height + 220;
				var duration = oMovie.duration;
				var isQa = $.oViewerData.showQA;
				if (isQa) _height = _height + 110;
				var isIos = 0;

				if (_height >= wh && height > 600) {
					if (isQa) {
						if (height <= 820 || wh <= 600) {
							height = 600;
						} else {
							height = wh - 100 - isIos;
						}
					} else {
						if (height <= 710 || wh < 600) {
							height = 600;
						} else {
							height = wh - 90 - isIos;
						}
					}
					width = height * sizeRatio;
				}

                if ($.oViewerData.isIOS && $.oViewerData.playerType == "html5") {
                //alert("$('#flvplayer_html5_api')[0]" + $("#flvplayer_html5_api")[0]);
                //$("#flvplayer_html5_api")[0].webkitExitFullscreen();
                //$("#flvplayer_html5_api").addClass("player_hide");

                    document.getElementById("bitmovinplayer-video-flvplayer").webkitExitFullScreen();
                    document.getElementById("bitmovinplayer-video-flvplayer").classList.add("player_hide");
                }

				if (!$.viewerSlide.blrgSlide) {
					$("#overlay_body").height($(document).height());
					$("#overlay_body").show();
				}
				$("#overlay_body").css("z-index", "1001");
				$("#overlay_content").show();
				$("#secondarymedia").width(width);
				$("#secondarymedia").height(_height);
				$("#secondarymedia").show().focus();
				$("#secondarymedia").attr("allowtransparency", "allowtransparency").attr("aria-label", "video");

				var url = "secondarymedia.jsp?codetag=" + $.oViewerData.codetag + "&w=" + width + "&h=" + height +
					"&bh=" + encodeURIComponent($.oBranding.sBranding_highlight) + "&mode=" + $.oViewerData.sMode +
					"&sSecondaryMediaMode=" + sSecondaryMediaMode + "&isQa=" + isQa + "&isHLS=" + $.oViewerData.isHLS +
					"&disable_od_seek=" + $.oViewerData.disable_od_seek + "&simlive=" + $.oViewerData.isSimlive +
					"&ei=" + $.oViewerData.sEventId + "&ishtml5player=" + $.oViewerData.isHTML5Player + "&qa_ans=" + $.oViewerData.showQAAnswer;

				var loadAndResizeFrame = function () {
					$("#secondarymedia").attr("src", url);
					$.viewerAction.resizeSecondardyMedia(oMovie.width, oMovie.height, sSecondaryMediaMode);
				}
				loadAndResizeFrame();
			},
			resizeSecondardyMedia: function (width, height, sSecondaryMediaMode) {//Runs if the user resize their browser
				if (($.oViewerData.playerType == "html5") || ($.oViewerData.playerType == "html5_audio")) {//If the event is HTML5 We're going to dynamically resize the video on resize
					console.log("TPQA - Resize LiveOverlay. Original video size is: " + width + "x" + height);
					var movieWidth = width;
					var movieHeight = height;
					var sizeRatio = (width / height);
					var sMode = sSecondaryMediaMode;
					var resizeCounter = 0;
					var scrollToQa = 0;
					var resizeWin;
					$(window).on("resize", function () {//Resize the Live overlay on a windows resize
						try { clearTimeout(resizeWin); } catch (err) { };//Use a cleartimeout to cancel any resize functions if the user is dragging slowly.
						var isVisible = ($("#secondarymedia").is(":visible"));
						if ((isVisible && $.manualReize === false) ||
							(isVisible && $('#playerBody').hasClass('removeVideo125'))) {
							resizeWin = setTimeout(function () {
								var windowWidth = $(window).innerWidth();
								var windowHeight = $(window).innerHeight();
								console.log("TPQA - inner window and height is: " + windowWidth + "x" + windowHeight);
								var resizeWidth = 800;
								var resizeHeight = 600;//Placeholder
								if (windowWidth > 1920) {
									windowWidth = 1920;//Setting a maximum size
								}
								if (windowWidth < 640) {
									windowWidth = 640;//Setting a minimum size
								}
								if (movieWidth < windowWidth) {
									resizeWidth = (movieWidth - 10);//Padding added
								} else {
									resizeWidth = (windowWidth - 10);//Padding added
								}
								resizeHeight = (resizeWidth / sizeRatio);

								if ((resizeHeight > (windowHeight - 50)) && (windowHeight > 360)) {//Setting a minimum height
									resizeHeight = (windowHeight - 50);
									resizeWidth = (resizeHeight * sizeRatio);
								}

								var paddedHeight = resizeHeight + 220;
								//var duration = oMovie.duration;

								var isQa = $.oViewerData.showQA;
								if (isQa) {
									paddedHeight = paddedHeight + 110;
								}

								$("#secondarymedia").width(resizeWidth);
								$("#secondarymedia").height(paddedHeight);
								$("#secondarymedia").contents().find("#player").css({ 'width': resizeWidth, 'height': resizeHeight });
								$("#secondarymedia").contents().find("#flvplayer").css({ 'width': resizeWidth, 'height': resizeHeight });
								$("#secondarymedia").contents().find("#reviewqa").on('click', function () {
									if (scrollToQa == 0) {
										var top = $("#secondarymedia").contents().find("#reviewqa").offset().top; //Getting Y of target element
										//console.log("TPQA - what is top offset?" + top);
										//window.scrollTo(0, top);
										$('html, body').animate({ scrollTop: (top / 4) }, 500);
										scrollToQa++;
									}
								});
								resizeCounter++;
							}, 400);
						}
					});
					if (resizeCounter == 0 && $.manualReize === false) {//This function makes sure the resize code runs at least once.
						setTimeout(function () {
							$(window).trigger('resize');
							resizeCounter++;
						}, 700);
					}
				}
			},

			getAudienceBridge: function () {
				if ($.oViewerData.isBridgeCustom || $.oViewerData.sBridgeType == "click_to_join") {
					$.viewerAction.showAudienceBridge();
				} else {
					console.log("New Priority:" + $.oViewerData.bridgePriority);
					$.ajax({
						type: "GET",
						cache: false,
						timeout: $.oViewerData.statusRefresh,
						url: "getstatus.jsp",
						data: ({ priority: $.oViewerData.bridgePriority, ei: $.oViewerData.sEventId, dType: "audiencebridge", ui: $.oViewerData.ui, si: $.oViewerData.si, ts: (new Date()).getTime() }),
						dataType: "json",
						success: function (jsonResult) {
							try {
								var previousProvider = "";
								if ($.oAudienceBridge != undefined && $.oAudienceBridge.length > 0) {
									previousProvider = $.oAudienceBridge[0].vendorName;
								}

								$.oAudienceBridge = jsonResult;
								if ($.oAudienceBridge != undefined && $.oAudienceBridge.length > 0) {

									if (previousProvider != $.oAudienceBridge[0].vendorName) {
										$.viewerAction.showAudienceBridge();
										if ($.oViewerData.playerType == "phone") {
											$.viewerControls.playerMsg("bridgeSwitch");
										}
									}
								}
							} catch (e) {
								log("Error in getAudienceBridge " + e.toString());
							}
						}
					});
				}
			},
			showAudienceBridge: function () {
				if ($.oViewerData.sBridgeType == "click_to_join") {
					//Do nothing...
				} else if ($.oViewerData.isBridgeCustom) {
					var sDefaultNumber = $.oAudienceBridge.number;
					var sIANumbers = $.oAudienceBridge.txt;
					var sDefaultNumberHTML = sDefaultNumber;
					var sIANumbersHTML = sIANumbers;
					if ($.oAudienceBridge.moretxt) {
						sDefaultNumberHTML += "<button type='button' class='ui-state-default ui-corner-all tp-button' id='add_ianumbers'>" + $.oAudienceBridge.moretxt + "</button> ";
					}

					$("#iaBridgeCountryAndNumber").html(sDefaultNumberHTML);
					$("#audNumbers").html(sIANumbersHTML);
				} else {


					var countryList = $.oAudienceBridge[0].bridge.countries;
					var defaultCountry = $.oAudienceBridge[0].defaultCountry;
					var sPin = $.oAudienceBridge[0].bridge.audiencePin;
					var defaultTollFreeFlag = $.oAudienceBridge[0].defaultNumberType.toLowerCase();
					var sIANumbers = "";
					var defaultNumber = "";
					var bShowAddNumbers = false;

					for (i in countryList) {
						var c = countryList[i];
						if ("" == defaultNumber && defaultCountry == c.country_code && c[defaultTollFreeFlag]) {
							sDefaultNumber = "<span class='ia_default_number'>" + c[defaultTollFreeFlag].number_formatted_international + "</span><span class='ia_default_country'>(" + c.country_desc + ")</span>";
						}

						if (countryList.length > 1 || (c.toll && c.tollfree)) {
							bShowAddNumbers = true;
							sIANumbers += ("<div class='ia_country_tr'><span class='ia_country'>");
							sIANumbers += (c.country_desc);

							sIANumbers += ("</span><span class='ia_toll_number'>");
							if (c.toll) {
								sIANumbers += (c.toll.number_formatted_international);
								bShow_ia_aud_toll = true;
							} else {
								sIANumbers += ("--");
							}
							sIANumbers += ("</span><span class='ia_tollfree_number'>");
							if (c.tollfree) {
								sIANumbers += (c.tollfree.number_formatted_international);
								bShow_ia_aud_tollfree = true;
							} else {
								sIANumbers += ("--");
							}
							sIANumbers += ("</span></div>");
						}
					}

					if (sDefaultNumber != "") {
						sDefaultNumber = sDefaultNumber + "<br><span class='ia_passcode'>" + "Passcode" + ": " + sPin + "#  </span>";
						if (bShowAddNumbers) {
							sDefaultNumber = sDefaultNumber + "<button type='button' class='ui-state-default ui-corner-all tp-button' id='add_ianumbers'>" + "More Numbers" + "</button> ";
						}

						$("#iaBridgeCountryAndNumber").html(sDefaultNumber);
						if ($.oViewerData.playerType == "phone") {
							$("#bridge_info").show();
						}
					}

					$("#audNumbers").html(sIANumbers);
					$("#bridgeList").show();
				}
				$("#viewer_phone_option").show();

			},

			getPlayerPath: function (playertype, mode, streamid, onResult) {
				if (mode == "postlive") {
					return;
				}

				var useFallback = $.oMulticast.useMulticastFallback;
				if (($.oMulticast.isKontikiMulticast || $.oMulticast.isRampMulticast) && $.oViewerData.audiostreamid == streamid) {
					useFallback = true;
				}


				console.log("eventId=" + $.oViewerData.sEventId)
				console.log("sh=" + $.oViewerData.sh)
				console.log("sh1=" + $.oViewerData.sh1)
				console.log("mode=" + mode)
				console.log("playertype=" + playertype)
				console.log("streamId=" + streamid)
				console.log("usefallback=" + useFallback)

				$.ajax({
					method: "GET",
					dataType: "json",
					url: "proc_playerpath.jsp?ei=" + $.oViewerData.sEventId + "&sh0=" + $.oViewerData.sh0 + "&sh1=" + $.oViewerData.sh1 + "&mode=" + mode + "&playertype=" + playertype + "&streamid=" + streamid + "&ts=" + (new Date()).getTime() + "&usemulticastfallback=" + useFallback,
					success: function (result) {
						if (mode != "live") {
							result.streamid = result.filename;
						}
						if (typeof (onResult) == "function") {
							onResult(result);
						}
					},
					error: function (ex) {
						log("getPlayerPath Error : " + ex);
						console.log(ex);
					}
				});
			},
			getPlayerToken: function (cdnPath, onResult) {
				var token = "";
				$.ajax({
					type: "GET",
					cache: false,
					async: false,
					timeout: $.oViewerData.statusRefresh,
					url: "/viewer/proc_playertoken.jsp?path=" + cdnPath,
					dataType: "json",
					success: function (jsonResult) {
						token = jsonResult.token;
						if (jsonResult.encodetoken) {
							token = encodeURIComponent(token);
						}
					}
				});
				onResult(token);
			},
			switchToAudio: function () {
				$.oViewerData.isAudio = true;
				$.viewerAction.showHeadshot();
			},
			showHeadshot: function () {
				//find headshot
				var headshot = $.oVideoInfo.sCurrentHeadShot;
				if (headshot == "" || headshot == null) {
					this.loadHeadshot(this.getDefaultBackupHeadshot());
				} else {
					$.viewerAction.flipheadshot(headshot);
				}
			},
			getDefaultBackupHeadshot: function () {
				return "images/audio-backup-slate_" + $.oViewerData.playerwidth + "x" + $.oViewerData.playerheight + ".png";
			},
			switchToVideo: function () {
				$.oViewerData.isAudio = false;
				$("#headshot").hide();
			},
			callcloseme: function (bInline) {
				if ($.oViewerData.playerType != "phone") {
					if (bInline) {
						closeme();
					} else {
						$("#secondarymedia")[0].contentWindow.closeme();
					}
				} else {
					$.viewerAction.secondaryMediaClosed = true;
					$.viewerAction.closeSecondaryMedia();
				}
			},
			closeSecondaryMedia: function () {
				console.log('viewerAction - closeSecondaryMedia');
				if ($.oViewerData.isOD) {
					console.log('isOD');
					if ($.oMulticast.isHiveMulticast) {
						$.activePlayer.switchVideo();
					}
					var jumpto = $.viewerAction.oActiveSecondaryMedia.sMovieTs + $.viewerAction.oActiveSecondaryMedia.oMovie.duration + 1;
					if (jumpto > $.oVideoInfo.totalDuration) {
						jumpto = $.oVideoInfo.totalDuration;
					}
					//$.activePlayer.setPosition(jumpto);
					//$.activePlayer.play();

					setTimeout(function () {
						$.viewerAction.secondaryMediaClosed = false;
					}, 3000);
				} else {
					console.log('else');
					if ($.oViewerData.playerType != "phone") {
						if ($.oViewerData.playerType == "html5" || $.oViewerData.playerType == "html5_audio") {
							$.activePlayer.switchVideo();
						} else {
							$.activePlayer.play();
						}
					}

				}
                if ($.oViewerData.isIOS && $.oViewerData.playerType == "html5") {
                    // $("#flvplayer_html5_api").removeClass("player_hide");
                    document.getElementById("bitmovinplayer-video-flvplayer").classList.remove("player_hide");

                    //   if ($("#playbuttonDiv").length > 0) {
                    //     $("#playbuttonDiv").show();
                    //   }
                }
                
				if ($.oViewerData.isIOS || $.oViewerData.isHLS) {
					$.oVideoInfo.status = "Click Play";
					$(".vjs-live-display").hide();
				}

				console.log('hide stuff');

				$("#secondarymedia").attr("src", "blank.html");
				$("#secondarymedia").hide();
				$("#overlay_content").hide();

				if (!$.viewerSlide.blrgSlide) {
					$("#overlay_body").hide();
				} else {
					$("#overlay_body").css("z-index", "1");
				}
				$.viewerAction.oActiveSecondaryMedia.active = false;
			},
			AddMsgAllSlidesOnly: function () {
				if ($('#playermsg').hasClass('player_hide') === false) {
					$("#slideMsgTxt").html($.oViewerMsg.custom);
					$('#overlay_content').css({ 'display': 'block' });
					$('#slideMsg').css({ 'display': 'block' });
					$('#overlay_body').css({ 'display': 'block' });
				}
			},
			removeMsgAllSlidesOnly: function () {
				if ($('#slideMsg').css('display') == 'block') {
					$('#overlay_content').css({ 'display': 'none' });
					$('#slideMsg').css({ 'display': 'none' });
					$('#overlay_body').css({ 'display': 'none' });
				}
			},
			serverLog: function (logFile, text, level, className, methodName) {
				var logText = 'f=' + logFile +
					'&l=' + (undefined === level ? 'info' : level) +
					'&c=' + (undefined === className ? '' : className) +
					'&m=' + (undefined === methodName ? '' : methodName) +
					'&t=' + text +
					'&ei=' + $.oViewerData.sEventId +
					'&si=' + $.oViewerData.si +
					'&ui=' + $.oViewerData.ui;

				try {
					$.ajax({
						type: 'GET',
						url: '/proc_log.jsp',
						data: logText,
						dataType: 'text',
						success: function (data) { },
						error: function () { }
					});
				}
				catch (e) { }
			},
			renderTranscript: function (transctipText) {
				let liveCaption = document.getElementById('live_caption');
				let captionElem = document.getElementById('verbit_caption_txt');
				let sdiv = document.createElement("div");

				if (!$.viewerAction.oActiveSecondaryMedia.active) {
					if (captionElem.hasAttribute("skipcaption")) {
						captionElem.removeAttribute("skipcaption", "true");
					}
					sdiv.textContent = transctipText;
					captionElem.appendChild(sdiv);
				} else {
					if (!captionElem.hasAttribute("skipcaption")) {
						captionElem.setAttribute("skipcaption", "true");
						sdiv.textContent = '[CAPTIONS UNAVAILABLE]';
						captionElem.appendChild(sdiv);
					}
				}
				try {
					liveCaption.scrollTo({ left: 0, top: liveCaption.scrollHeight, behavior: "smooth" });
				} catch (err) {
					sdiv.scrollIntoView({ behavior: "smooth", block: "end", inline: "nearest" });
				}
			},
			initLiveTranscript: function () {
				let captionDiv = document.getElementById("live_caption");
				if ($.oViewerData.playerType != "phone") {
					if ($.oViewerData.showLiveCaptionsInViewerByDefault) {
						captionDiv.style.display = "block";
					}

					// safari's async loading of document data forces us to use a MutationObserver to wait for the right element to load
					function waitForElement(selector, callback) {
						const element = document.querySelector(selector);
						if (element) {
							callback(element);
							return;
						}

						const observer = new MutationObserver((mutations) => {
							mutations.forEach((mutation) => {
								const element = document.querySelector(selector);
								if (element) {
									callback(element);
									observer.disconnect(); // Stop observing once the element is found
								}
							});
						});

						observer.observe(document.body, {
							childList: true,
							subtree: true
						});
					}

					waitForElement('.bmpui-ui-settingstogglebutton', (element) => {
						console.log('Element is now available:', element);
						if (!document.getElementById('verbitSearchBtn')) {
							$('<button id="verbitSearchBtn" title="Captions" class="verbitSearchBtn" alt="Live Captions" tabindex="0"><svg class="verbitIcon" xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24" style="fill: white;"><path d="M0 0h24v24H0z" fill="none"/><path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zM4 12h4v2H4v-2zm10 6H4v-2h10v2zm6 0h-4v-2h4v2zm0-4H10v-2h10v2z"/></svg></button>').insertAfter('.bmpui-ui-settingstogglebutton');
							$('#verbitSearchBtn').css('display', 'flex');
							document.getElementById('verbitSearchBtn').addEventListener('click', () => {
								if (captionDiv.style.display === 'block') {
									captionDiv.style.display = 'none';
									//$('#transcript_close').trigger("click");
								} else {
									captionDiv.style.display = 'block';
								}
							});
						}
					});

				}
				// add eventlistner to full caption btn
				/*
		$('#verbit_full_caption_btn').click(function(){
			document.getElementById("verbit_full_caption_btn").style.display="none";
			captionDiv.style.height = "100%";
			document.getElementById("fullTranscript").appendChild(captionDiv);
			document.getElementById("transcriptDiv").style.display="block";
			//document.querySelector(".transcript_txt").style.textAlign="left";
			$('.verbitTranscriptDiv').addClass('open') 
		});

		// add eventlistner to close full caption btn
		$('#transcript_close').click(function(){
			document.getElementById("transcriptDiv").style.display="none";
			captionDiv.style.height = "60px";
			document.getElementById("viewer_video").insertBefore(captionDiv,document.getElementById("viewer_video_tabs"));
			document.getElementById("verbit_full_caption_btn").style.display="block";
			//document.querySelector(".transcript_txt").style.textAlign="center";
			document.getElementById('verbit_caption_txt').scrollIntoView(false);
			$('.verbitTranscriptDiv').removeClass('open') 
			
		});
		*/

			}


		}
	});
})(jQuery);

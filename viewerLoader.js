function postMsg(sType,sStatus){
	if($.oViewerData.sPostMsgApiTarget!=""){
    	try{
    		postMsgJson[sType] = sStatus;
    		window.parent.postMessage(postMsgJson,$.oViewerData.sPostMsgApiTarget);
    	}catch(e){
    		log("Error in postMessage " + e);
    	}
	}
}
function loadViewer(){
	if(!bnoloading){
		$("#loadingtxt").show();
	}
	postMsg("event_status","enter");
	 if($.oViewerData.sSlideType=="swf"){
	    	$.oViewerData.sSlideType="png";
	 }
   	$.activePlayer = $.viewerHTML5Player;

	window.playerOptions = {
		player: null,
		streamPath: null,
		playerDiv: 'flvplayer',
		videoId: `${$.oViewerData.sEventId}`,
		eventTitle: `Figure This Out`,
		isOD: $.oViewerData.isOD,
		initJump: $.oViewerData.isSimLive
 	};

 	window.g_player = null;
 	window.g_sPath = null;
 	window.g_sPlayerDiv = 'flvplayer';
 	window.g_sVideoId = `${$.oViewerData.sEventId}`; // analytics stuff
	window.g_sEventTitle = ''; // event title
	window.isHiveMulticast = $.oMulticast.isHiveMulticast;
	window.oViewerData = $.oViewerData;
	window.oViewerAction = $.oViewerAction;
	// if ($.oViewerData.vtt_caption && $.oViewerData.vtt_caption.length > 0 &&
	// !$.oViewerData.isPreSimlive && !$.viewerAction.oActiveSecondaryMedia.active) {

	function waitForFunction(func, callback) {
		const interval = setInterval(() => {
			if (typeof window[func] === 'function') {
				clearInterval(interval);
				callback(window[func]);
			}
		}, 1500);
	}
	//window.loadPlayer();

   	$.oViewerData.playerType = "html5";
			
	if($.oViewerData.isAudio){
		$.oViewerData.playerType = "html5_audio";
		$("#player").height("+=30");
		//For iphone and android pause audio when  out of focus
		if($.oViewerData.isIOS || $.oViewerData.isHLS){
			document.addEventListener("visibilitychange", function() {		
				if (document.hidden) {     
					$.activePlayer.pause();
				} else {
					$.activePlayer.play();
				} 
			});
		}
	}
	$.viewerAction.iScriptDelay = 18000;
	var isSafari = (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1);
	if(!$.oViewerData.isWebcam && !isSafari && !$.oMulticast.isHiveMulticast && ($.oViewerData.isAdaptiveBitrate || $.oViewerData.isAudio)){
		$.viewerAction.iScriptDelay = $.oViewerData.isAudio ? 10000 : 13000;
	}

	$.viewerUploads.init();
	$.viewerResize();

	$.viewerSlideTabs.init();
				
	if($("#viewer_video_tabs>h3").length){
		$("#viewer_video_tabs").viewerAccordion();
		$("#viewer_video_tabs>h3.isopen").trigger("click");
	}
	
	if(!$.oViewerData.isPhoneDefault) {
		//$.activePlayer.init();

		waitForFunction('loadPlayer', (loadPlayer) => {
			console.log('loadPlayer available');
			$.activePlayer.init();//loadPlayer('flvplayer', '', );
		})
	}else{
		$.viewerControls.init();
		$.viewerControls.switchToPhone();
		$.viewerAction.init();
	}
	
	if($.oViewerData.isSlides){
		$.viewerSlide.init();
	}
	
	if($.oViewerData.isListenByPhone){
		$.viewerAction.showAudienceBridge();
	}

	$(window).on("unload",doUnload);
	
	$("#playerBody").bind("onbeforeunload",function() {doEndSession(true,0)});
	
	$(window).on("resize",function(){
		var tabs = $("#viewer_slide_tabs > .ui-tabs-nav >li").length;
		if(tabs>0 || $.oViewerData.bInRoomView || ($.oViewerData.playerType == "html5" && $.oViewerData.playerwidth>800)){
			clearTimeout($.resizeTimer);
			if($('body').hasClass('removeVideo125') === true && $("#tabs_content").outerWidth() === 0){
				// do nothing
			}else{
				$.resizeTimer = setTimeout("$.viewerResize()", 300);
			}
		}
	});
	
	 //use the property name to generate the prefixed event name
	
	var visProp = getHiddenProp();
	if (visProp) {
		var evtname = visProp.replace(/[H|h]idden/,'') + 'visibilitychange';
		document.addEventListener(evtname, handleVisibilityChange, false);
	}

}

function trackEndSession() {}
function doEndSession(bBrowserClosed,idelay){
	if(bBrowserClosed && isCloseClicked)return;
	log("doEndSession bBrowserClosed " + bBrowserClosed + " isCloseClicked " + isCloseClicked + " idelay " + idelay);
	if($.trackerid)clearInterval($.trackerid);
	if($.dynamicDataTimer)clearInterval($.dynamicDataTimer);
	if($.backuptrackerid){
	    clearInterval($.backuptrackerid);
	}
	
	if(bBrowserClosed){
		window.open("blank.html","endsessionwindow");
		$("#passThruForm").attr("target","endsessionwindow");
		$.viewerAction.tracker();
		postMsg("event_status","exit");
		$("#passThruForm").submit();
	}else{
		setTimeout('$.viewerAction.tracker()',idelay/2);
		setTimeout(function(){postMsg("event_status","exit");$("#passThruForm").submit()},idelay);
	}
	return false;
}
function doUnload(){
	try{
		log("doUnload");
		if($.trackerid)clearInterval($.trackerid);
		if($.dynamicDataTimer)clearInterval($.dynamicDataTimer);
		
		if(!$.oViewerData.isIOS && !$.oViewerData.isHLS && !$.oViewerData.isHTML5Player) {
			if(swfobject){
				swfobject.removeSWF("flvplayer");
				swfobject.removeSWF("flvslideloader");
				swfobject = null;
			}
			
		}
	}catch(error){}
}

//Video stream resizing code - start
function setVideoWxh(width,height) {
	var vWidth = (width + "px");
	var vHeight = (height + "px");
	var playDivH = (height-30 + "px");//Allow space on the play buton div to account for player controls
	$("#viewer_video").css("width",vWidth);
	$("#player").css("height",vHeight);
	$("#playbuttonDiv").css({"height":playDivH,"width":vWidth});
	var scaledPlayButton = Math.ceil((25 / 100)*width);//Resize the play button to stay proportional to the video player
	$("#playbutton").css("width", scaledPlayButton + "px"); 
	console.log("TPQA - Setting Video WxH to: " + vWidth + "," + vHeight);
}

function getBrowserWidth() {
	var bWidth = window.innerWidth;
	return bWidth;
}

function autoResizeVid() {
	var originalWidth=$.oViewerData.playerwidth;
	var originalHeight=$.oViewerData.playerheight;
	var ratio=(originalWidth/originalHeight);
	var canResize = true;
	if(($(window).width() > 770) && parseInt($.oViewerData.playerwidth) <= 640){
		setVideoWxh($.oViewerData.playerwidth,$.oViewerData.playerheight);
		canResize = false;
	}
	try {
		console.log("TPQA - autoResizeVid : Original wXh :" + originalWidth + "px X " + originalHeight + "px, ratio: " + ratio);
	} catch (err) {}
	
    if($('#jumppointframe').is(':visible')){	
    	$('#jumppointframe').hide();
    	$('#jumppoint').removeClass('ui-state-active').removeClass('open').removeClass('jumppointColor');
    	$('#slide_overlay').hide();
    	//$.viewerSlideTabs.bslideOverlay = false;
    }	
	
	if(canResize){
		if((!$.oViewerData.isSlides)&&($("#viewer_slide_tabs > .ui-tabs-nav >li").length<1)){//If the event does not feature slides or tabs
			if (ratio<1.5) {//If the video is 4x3
				if (getBrowserWidth()>980) {
					setVideoWxh("960","720");
				} else if (getBrowserWidth()>660) {
					setVideoWxh("640","480");
				} else if (getBrowserWidth()>500) {
					setVideoWxh("480","360");
				} else {
					setVideoWxh("320","240");
				} 
			} else {//The video must be 16x9
				if (getBrowserWidth()>1367) {
					setVideoWxh("1280","720");
				} else if (getBrowserWidth()>880) {
					setVideoWxh("854","480");
				} else if (getBrowserWidth()>660) {
					setVideoWxh("640","360");
				} else if (getBrowserWidth()>500) {
					setVideoWxh("480","270");
				} else {
					setVideoWxh("320","180");
				}
			}
		} else {//The event must have slides or tabs
			if (ratio<1.5) {//If the video is 4x3
				if (getBrowserWidth()>1700) {
					setVideoWxh("960","720");
				} else if (getBrowserWidth()>1024) {
					setVideoWxh("640","480");
				} else if (getBrowserWidth()>780) {
					setVideoWxh("480","360");
				} else {
					setVideoWxh("320","240");
				}
			} else {//If the player is 16/9
				if (getBrowserWidth()>3000) {//Only use 720p video wiht slides on 4k monitors
					setVideoWxh("1280","720");
				} else if (getBrowserWidth()>1930) {
					setVideoWxh("1024","576");
				} else if (getBrowserWidth()>1700) {
					setVideoWxh("854","480");
				} else if (getBrowserWidth()>1024) {
					setVideoWxh("640","360");
				} else if (getBrowserWidth()>780) {
					setVideoWxh("480","270");
				} else {
					setVideoWxh("320","180");
				} 
			}
		}
	}
	changePlayerTopBarLoc(); 
}

/// NEW NEW
// TODO: VIDEO ONLY !!!!
function autoResizeVid_viewer125(bigger) {
	$.manualReize = true;
	
    var originalWidth=$.oViewerData.playerwidth,
    	originalHeight=$.oViewerData.playerheight,
    	ratio=(originalWidth/originalHeight),
    	browserWidth = $(window).width();
    
    if($('#jumppointframe').is(':visible')){	
    	$('#jumppointframe').hide();
    	$('#jumppoint').removeClass('ui-state-active').removeClass('open').removeClass('jumppointColor');
    	$('#slide_overlay').hide();
    	//$.viewerSlideTabs.bslideOverlay = false;
    }
    
    if(bigger === false){
        browserWidth = 400;
    }
    //trigger mobile view..
    if(($('#viewer').hasClass('largeSlideVideo') === true || $('#viewer').hasClass('largeVideoSlide') === true)&& browserWidth < 1025){
    	browserWidth -= 320;
    }
    
    try {
		console.log("TPQA - autoResizeVid_viewer125 : Original wXh :" + originalWidth + "px X " + originalHeight + "px, ratio: " + ratio + ", browserWidth: " + browserWidth);
    } catch (err) {}    

            if (ratio<1.5) {//If the video is 4x3
                if (browserWidth>2120) {
                    setVideoWxh("1920","1080");
                } else if (browserWidth>980) {
                    setVideoWxh("960","720");
                } else if (browserWidth>660) {
                    setVideoWxh("640","480");
                } else if (browserWidth>500) {
                    setVideoWxh("480","360");
                } else {
                    setVideoWxh("320","270");
                } 
            } else {//The video must be 16x9
                if (browserWidth>2120) {
                    setVideoWxh("1920","1080");
                } else if (browserWidth>1752) {
                    setVideoWxh("1280","720");
                } else if (browserWidth>880) {
                    setVideoWxh("854","480");
                } else if (browserWidth>660) {
                    setVideoWxh("640","360");
                } else if (browserWidth>500) {
                    setVideoWxh("480","270");
                } else {
                    setVideoWxh("320","180");
                }
            }
            changePlayerTopBarLoc();
}

function changePlayerTopBarLoc(){
	$('#top-control-bar').css({'top': 0});
	//For Audio and slides only we need to change to
	// $("#top-control-bar").css("top", 30 - $("#player").height());
}

function changeViewerWidth(newWidth){
	// newWidth -= $.viewerSlide.marginSpace;
	console.log("TPQA - changeViewerWidth  " + newWidth);
	$('#viewer').css({'width' : newWidth});
	$('#viewer_banner').css({'width' : newWidth});
	$('#viewer_footer').css({'width' : newWidth});		
}

// END OF NEW NEW

var tpjumpcounter=0;
function tpjump() {
	try {
		var totaltime = $.oVideoInfo.totalDuration;
		var jumptime = $.oVideoInfo.initJump;
		if ((totaltime=="0")&&(tpjumpcounter<10)) {
			tpjumpcounter++;//We'll stop trying if the counter reaches 10
			console.log("TPQA - Jump counter is now: " + tpjumpcounter + " Total time: " + totaltime);
			setTimeout(function() {
				tpjump();	
			},300);
			return;
		}
		if ((jumptime > 0)&&(jumptime <= totaltime)&&(!isNaN(jumptime))) {
			$.activePlayer.setPosition(jumptime);
			console.log("TPQA - Jumping into file " + jumptime + " seconds");	
		} else {
			console.log("TPQA - Jump function did not fire. Jumptime: " + jumptime + " totaltime: " + totaltime);	
		}
	}catch(err){
		console.log("TPQA - Unable to jump into file. Reason: " + err);
	}
}

//Tracker/getstatus call update when browser out of focus..
function getHiddenProp(){
    var prefixes = ['webkit','moz','ms','o'];
      // if 'hidden' is natively supported just return it
    if ('hidden' in document) return 'hidden';
      // otherwise loop over all the known prefixes until we find one
    for (var i = 0; i < prefixes.length; i++){
        if ((prefixes[i] + 'Hidden') in document) 
            return prefixes[i] + 'Hidden';
    }
    // otherwise it's not supported
    return null;
}


var pageVisible = true;  
function handleVisibilityChange() {
	if (document.hidden) {
		pageVisible = false;
	}else{
		pageVisible = true;
	}
	reInitStatusTimer();
}
function reInitStatusTimer(){
	try{
		clearInterval($.dynamicDataTimer);
		$.dynamicDataTimer = null;
		var statusRefreshRate = $.oViewerData.statusRefresh;
		if (!pageVisible) {
			statusRefreshRate = 90000;//1.5 Minute
		}
		if(statusRefreshRate==undefined || statusRefreshRate==0){
			statusRefreshRate = 90001;//1.5 Minute
		}
		console.log("pageVisible : " +  pageVisible + " statusRefreshRate : " + statusRefreshRate);
		if($.oViewerData.isOD){
		   if($.oViewerData.isSimlive) {
			   $.dynamicDataTimer = setInterval(function(){$.viewerAction.getSimliveStatus()},statusRefreshRate);
		   }
		}else{
		   $.dynamicDataTimer = setInterval(function(){$.viewerAction.getLiveStatus()},statusRefreshRate);
		}
	}catch(err){
		console.log("Error reInitStatusTimer " +  err);
	}
}
var lastTime = 0;
function getLiveStatus(curTime){
	try{
		//if not in prelive mode return..
		if($.viewerAction.getCurMediaMode()!="prelive"){
			return;
		}
		if(!pageVisible  && curTime!=lastTime){
		   	console.log("pageVisible / $.viewerAction.getCurMediaMode() / curTime : " + pageVisible + " / " + $.viewerAction.getCurMediaMode() + " / " + curTime);
			lastTime = curTime;
			if($.oViewerData.isOD){
				if($.oViewerData.isSimlive) {
				   $.viewerAction.getSimliveStatus();
				}
			}else{
			   $.viewerAction.getLiveStatus();
			}
		}
	}catch(err){
		console.log("Error getLiveStatus " +  err);
	}
}

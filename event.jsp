<%@page import="tcorej.bean.MulticastConfigBean"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.*"%>
<%@ page import="tcorej.*"%>
<%@ page import="tcorej.util.LocaleTools"%>
<%@ page import="tcorej.stream.LiveStream"%>
<%@ page import="tcorej.bean.TabListBean" %>
<%@ page import="tcorej.audiobridge.*"%>
<%@ page import="tcorej.video.adaptivebitrate.*"%>
<%@ page import="org.json.*"%>
<%@ page import="tcorej.security.*"%>
<%@ page import="tcorej.speechtotext.*"%>
<%@ page import="tcorej.multicast.*" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils"%>
<%@ include file="/viewer/include/globalinclude.jsp"%>
<%
String sEventId =  StringTools.n2s(request.getParameter(Constants.RQEVENTID));
String stp_special = StringTools.n2s(request.getParameter("tp_special"));
if (stp_special.indexOf("notavailable_")!=-1) {
	if (DateTools.getDrift(stp_special.replace("notavailable_",""))<30) { %>
		<jsp:include page="notavailable.jsp">
		<jsp:param name="ei" value="<%=sEventId%>"/>
	</jsp:include>
	<% return;
	}
}
int iEventId = -1;
String sTrackerRefresh =  Constants.EMPTY;
String sStatusRefresh =  Constants.EMPTY;
String sStatusRefreshFactor =  Constants.EMPTY;
String sUser_cnt =  Constants.EMPTY;
int iAudience_cap=0;
int iChatroom_cap=0;
long lOdpauseTimeout = 600;
boolean isOD = false;
boolean isSimlive = false;
boolean isPreSimlive = false;
boolean isModeLiveOrPrelive = false;
boolean isLiveQA = false;
boolean isODQA = false;
boolean isQAAnswer = false;
boolean isSlides = false;
boolean isOtherTabs = false;
boolean isStreamSecured = false;
boolean isAdaptiveBitrateEnabled = false;
boolean hasSMILFilesForCurrentVersion = false;
boolean displayChat = false;
boolean isBridgeCustom = false;
boolean isWebcam = false;
boolean analyticsActive = false;
int nFlashBandwidthCheckerDelaySec = 10;
String sAdaptiveBitrateStreamsJson = Constants.EMPTY;
String sPrimaryStreamId = Constants.EMPTY;
String sBackupStreamId = Constants.EMPTY;
String sVideoUrl = Constants.EMPTY;
String sVideoEventid = Constants.EMPTY;
String sVideoContentType = Constants.EMPTY;
String QAModule = Constants.EMPTY;
String surveyModule = Constants.EMPTY;
String sEventType= Constants.EMPTY;
String sTitle = Constants.EMPTY;
String sMode = Constants.EMPTY;
String sCurrentSlide = Constants.EMPTY;
String sCurrentSurvey = Constants.EMPTY;
String sCurrentSurveyResult = Constants.EMPTY;
String sCurrentLayout = Constants.EMPTY;
int currentBridgePriority = 0;
String sContentPath = Constants.EMPTY;
String sContentUrl = Constants.EMPTY;
String sVTTUrl = Constants.EMPTY;
String sBannerUrl= Constants.EMPTY;
String sClientid = Constants.EMPTY;
String sLobby = Constants.EMPTY;
String sDate = Constants.EMPTY;
String sPlayerSize = Constants.EMPTY;
String si = Constants.EMPTY;
String ui= Constants.EMPTY;
String ea= Constants.EMPTY;
String trackerUrl = Constants.EMPTY;
String sSlides = Constants.EMPTY_JSON;
String sVideoIndex = Constants.EMPTY;
Event myEvent = null;
Configurator globalConfig = null;
Configurator eventConfig = null;
Configurator multicastConfig = null;
Configurator chatConfig = null;
List<TabListBean> alAllTabs = null; 
ArrayList<TabListBean> alTabs = new ArrayList<TabListBean>();
ArrayList<TabListBean> alAcordTabs = new ArrayList<TabListBean>();
HashMap<String, String> hmAllPlayerText = null;
String sStandbyGif = Constants.EMPTY;
String sLanguage = Constants.EMPTY;
String tp_jump = Constants.EMPTY;
String sCurrFixedTextLang = Constants.EMPTY;
String fname= Constants.EMPTY;
String lname= Constants.EMPTY;
String company = Constants.EMPTY;
String QATabTitle =  Constants.EMPTY;
String audienceBridge = Constants.EMPTY;
boolean isPreviewMode = false;
String sTemplatePath = Constants.TEMPLATE_PATH; //Later on we can change this in db and point to different template for branding..
OdStudioManager odm = null;
String ODEvents = Constants.EMPTY_JSON;
String oSecondaryMedia = Constants.EMPTY_JSON;
Logger logger = Logger.getInstance();

String userAgent = Constants.EMPTY;
boolean isIOS = false;
boolean isIPhone = false;
boolean isAndroidChrome = false;

String isTp = Constants.EMPTY;
String qa_email_address=Constants.EMPTY;

StringBuffer sRequestURL = request.getRequestURL();
java.net.URL url = new java.net.URL(sRequestURL.toString());
String sDomain = url.getHost();
String sVideoWidth = "320";
String sVideoHeight = "240";
String sPlayButtonDivPad = "30"; //Padding that ensures play button doesn't overlap player controls
boolean isWideScreen = false;

String sViewerUploads = Constants.EMPTY;
String sQueryString= Constants.EMPTY;
String sEventGUID = Constants.EMPTY;
boolean isAudio  = false;
boolean isPhoneDefault = false;
boolean isPhoneOnly = false;

String sCurrentHeadShot = Constants.EMPTY;
String codetag = Constants.EMPTY;
String sBroadcasting = Constants.EMPTY;
String sBackground_image = Constants.EMPTY;
String sBackground_color = Constants.EMPTY;
String sBranding_highlight = Constants.EMPTY;
String sPlayer_customcss = Constants.EMPTY;
String sViewerBackground_color = Constants.EMPTY;
String sBannerBackground_color = Constants.EMPTY;
String sBannerRight_image = Constants.EMPTY;
String sFooter= Constants.EMPTY;

boolean bPhoneOption =false;
String sBridge_number = Constants.EMPTY;
String sBannerRightUrl = Constants.EMPTY;
boolean mp3download = false;
String mp3_download_url =  Constants.EMPTY;
String sTscinfo  =  Constants.EMPTY;
boolean bUserControlSlides = false;
boolean isArchiveScheduleOpen = true;
boolean isPreliveOpen = true;
boolean isPreSimliveOpen = true;

int tp_special = 0;
int tpPlayer = 0;
String sShowWebcastBy = Constants.EMPTY;
String sStreamId = Constants.EMPTY;

boolean isHLS = false;
boolean isHDS = false;
String sFlashVersion = "10.1";
String sFlashVersionText = "20";
boolean bUseQTiframe = false;

boolean isFlashMulticast = false;
boolean isWindowsVideo = false;
boolean isWindowsAudio = false;
boolean isViblastPDN = false;
String sMulticastGroup = Constants.EMPTY;
String sMulticastPassword = Constants.EMPTY;
String sMulticastIp = Constants.EMPTY;
String sMulticastStreamName = Constants.EMPTY;
String sMulticastType = Constants.EMPTY;
String sMulticastConfJson = Constants.EMPTY_JSON;
String sMulticastNscUrl = Constants.EMPTY;
String sMedia_selection = Constants.EMPTY_JSON;
boolean disable_od_seek = false;
boolean isWindowsmulticastfallback = true;
boolean isFlashmulticastfallback = true;
boolean isHiveFallback = false;
String sFlashMulticastRollToBackupType = Constants.EMPTY;
String caption = Constants.EMPTY_JSON;
String vtt_caption = Constants.EMPTY_JSON;
String sPlayer_templatecss = Constants.EMPTY_JSON;
org.json.JSONObject oIANumbers = null;
org.json.JSONArray aIACountries= null;
boolean bShowAddNumbers = false;
String selectedBridgeType = Constants.EMPTY;
boolean bShow_ia_aud_toll = false;
boolean bShow_ia_aud_tollfree = false;
long lCurrentDate = 0;
String sh1 = Constants.EMPTY;
String sh0 = Constants.EMPTY;
boolean isUserAudioBackup = false;
String sAudioStreamId = "";

long lPlayIndex = 0;

boolean isLiveOverlayEnabled = false;
boolean isStreamUserIDTracking = false;

String sSecuredContentFolder = Constants.EMPTY;

String sAnalytics_code = Constants.EMPTY;

boolean bShowAddCustomNumbers = false;
String sCustomNumbers = Constants.EMPTY;
String sCustomNumbers_moretext = Constants.EMPTY;
boolean isKontikiMulticast = false;
boolean isHiveMulticast = false;
boolean isKollectiveMulticast = false;
String playAlt = Constants.EMPTY;
String playAltMulticast = "Playing Multicast Stream";
String sSlideType = "swf";
String sPlayerType = Constants.EMPTY;
boolean ishtml5player = false;
boolean ishtml5slide = false;
boolean bShowCounter = false;
boolean bStatusOn2 = false;
boolean bInRoomView = false;
String sSessionTypeOnLoad = "-1";
boolean isSimLiveRunning = false;
String sPassThruUrl = Constants.EMPTY;
String sTpKey = Constants.EMPTY;
String chatMessageString = Constants.EMPTY;
boolean displayQA = false;
boolean displayChaptersTab = false;

String userLocalTZDate = Constants.EMPTY;

boolean generateQATab = false;

boolean isIntegratedAudio = false;
boolean isTelAudioAdvanced = false;
boolean isRampMulticast = false;
boolean isRampCache = false;
boolean enableHiveJS = false;
boolean isEnableFastyCookie = false;
String sViblast = "viblast";
String sVideojs = "videojs";

String sClicktojoinurl  = Constants.EMPTY;
String sDialinurl  = Constants.EMPTY;
String sClicktojoinlabel = Constants.EMPTY;
String sTranscriptUrl = Constants.EMPTY;
String sPostMsgApiTarget = Constants.EMPTY;
boolean bIE11 = false;
String tpSocialCode = Constants.EMPTY;
boolean bVideoJSOnly = false;
String sPrelive_player_layout = Constants.EMPTY;
String sBanner_alt_tags = Constants.EMPTY;
String sBannerMain_alt = Constants.EMPTY;
String sBannerRight_alt= Constants.EMPTY;
String kollective_contentToken = Constants.EMPTY;
boolean bPlayerOnly = false; 
try{
	
	sEventId =  StringTools.n2s(request.getParameter(Constants.RQEVENTID));
    si =  StringTools.n2s(request.getParameter(Constants.RQSESSIONID));
    ui = StringTools.n2s(request.getParameter(Constants.RQUSERID));
    ea = StringTools.n2s(request.getParameter(Constants.RQEMAILADDRESS));
    userLocalTZDate= StringTools.n2s(request.getParameter("userLocalTZDate"));
    fname = StringTools.n2s(request.getParameter("fname"));
    lname = StringTools.n2s(request.getParameter("lname"));
    company= StringTools.n2s(request.getParameter("company"));
    isTp =  StringTools.n2s(request.getParameter("tp_land"));
    tp_special = StringTools.n2i(stp_special);
    ishtml5player = StringTools.n2b(request.getParameter("ishtml5player"));
    ishtml5slide = StringTools.n2b(request.getParameter("ishtml5slide"));
	userAgent = StringTools.n2s(request.getHeader("user-agent"), "Unknown").toLowerCase();
	sSessionTypeOnLoad = StringTools.n2s(request.getParameter("sessiontype"));
    sTpKey = StringTools.n2s(request.getParameter("tp_key"));    
    tpPlayer = StringTools.n2i(request.getParameter("tp_player"));
    String sServerName = request.getServerName().toLowerCase();
    
    bIE11 = userAgent.contains("windows nt 6.1") && userAgent.contains("rv:");
    
   	if(Constants.EMPTY.equals(sEventId)){
	    %><jsp:forward page="/session-error.html" /><%
	    return;
	}

    if(ui.equals(Constants.EMPTY) || si.equals(Constants.EMPTY) || ea.equals(Constants.EMPTY)){
    	logger.log(Logger.INFO,"jsp","Some important paramteres were not passed (ui,si,ea)  "
    			+ " Event Id = " + sEventId + " UI = " + ui + " SI = " + si + " ea = " + ea ,"event.jsp");
    	String redirectUrl = "/starthere.jsp?ei=" + sEventId;
    	if(!Constants.EMPTY.equals(sTpKey)){
    		redirectUrl += "&tp_key=" + sTpKey;	   	
	   	}
    	if(tpPlayer>0){
    		redirectUrl += "&tp_player=" + tpPlayer;	   	
	   	}		
    	response.sendRedirect(redirectUrl);
    	 return;
    }
    
    
    try{
	    iEventId = Integer.parseInt(sEventId);
	}catch (NumberFormatException e) {
		logger.log(Logger.INFO,"jsp","Invalid eventid :  ei  - " + sEventId,"event.jsp");
	   	%><jsp:forward page="/session-error.html" /><%
	    return;
	}

	if(Event.exists(iEventId)){
		myEvent = Event.getInstance(iEventId);
	}else{
		logger.log(Logger.INFO,"jsp","Event does not exist :  ei  - " + sEventId,"event.jsp");
		%><jsp:forward page="/session-error.html" /><%
	    return;
	}
		 
	 if(ishtml5slide){
		 sSlideType = "html5";
	 }
	 
	sEventGUID = myEvent.getProperty(EventProps.eventguid);
	isStreamSecured =  StringTools.n2b(myEvent.getProperty(EventProps.secure_stream));
    if(!eventPageSecurity.verifyHash(request,sEventId,false,sEventGUID)){
    	logger.log(Logger.INFO,"jsp","Event failed hash verification " + sEventId,"event.jsp");
    	%><jsp:forward page="/session-error.html" /><%
	    return;
    }
    
    sh1 = URLEncoder.encode(eventPageSecurity.getHash(request,sEventId), "UTF-8");// Create secure hash to be checked on next pae.
 	sh0 = sEventGUID;
		   
    sEventType = myEvent.getProperty(EventProps.contenttype).equals("") ? "live" : myEvent.getProperty(EventProps.contenttype).toLowerCase();
    sMode = myEvent.getStatus(EventStatus.mode).getValue();
    isOD = (sEventType.equals("od") || (sMode.equals("ondemand")));

	// Note: may be able to use TabType.CHAPTERS.displayTabForEvent(), but this will work for now
	// Chapters tab is only displayed for OnDemand events. The mode is also "ondemand" for simLive events, so need to exclude simLive events.
	displayChaptersTab = myEvent.isModeOnDemand() && !myEvent.isSimLive() && myEvent.isChaptersEnabled();

	tp_jump = StringTools.n2s(request.getParameter("tp_jump"));

    sLanguage = StringTools.n2s(request.getParameter("language"));	
    if(Constants.EMPTY.equals(sLanguage)){
		sLanguage = myEvent.getDefaultLanguage();
	}
    hmAllPlayerText = myEvent.getAllPlayerText(sLanguage);
    sStandbyGif = "style/images/standby.gif";
   
    QATabTitle =StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tab_ask_question"));
    playAlt = StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("sts_playing"));
    playAltMulticast = "Playing Multicast Stream";
    myEvent.loadEventDateDisplay();
    
    chatMessageString = "&chat_send_btn_txt=" + URLEncoder.encode(hmAllPlayerText.get("chat_send_btn_txt"), "UTF-8")
    + "&chat_connected_msg=" + URLEncoder.encode(hmAllPlayerText.get("chat_connected_msg"), "UTF-8")
    + "&chat_disconnected_msg=" + URLEncoder.encode(hmAllPlayerText.get("chat_disconnected_msg"), "UTF-8")
    + "&chat_security_msg=" + URLEncoder.encode(hmAllPlayerText.get("chat_security_msg"), "UTF-8")
    + "&chat_deny_chat_disabled=" + URLEncoder.encode(hmAllPlayerText.get("chat_deny_chat_disabled"), "UTF-8")
    + "&room_full=" + URLEncoder.encode(hmAllPlayerText.get("chat_deny_room_full"), "UTF-8")
    + "&connection_failed=" + URLEncoder.encode(hmAllPlayerText.get("sts_failed"), "UTF-8");
    
    String _sLanguage = Constants.EMPTY;
    if(Constants.EMPTY.equals(sLanguage)){
    	 sCurrFixedTextLang = myEvent.getProperty(EventProps.default_language);//Is there a default language set?
   	    if(!Constants.EMPTY.equals(sCurrFixedTextLang)) {
   	    	JSONObject jDefaultLang = new JSONObject(sCurrFixedTextLang);
   	        _sLanguage = jDefaultLang.optString("default_lang");//Set the language template if one exists with the event id. Will override the query param.
   	   	}
    }
    if(!Constants.EMPTY.equals(sLanguage)){
    	sStandbyGif = "style/images/standby-" + sLanguage + ".gif";
    }else if(!Constants.EMPTY.equals(_sLanguage)){
    	sStandbyGif = "style/images/standby-" + _sLanguage + ".gif";
    }
    isAudio = myEvent.getProperty(EventProps.acquisition_source).equals("audio")?true:false;
    if(!isAudio){
    	isWideScreen = myEvent.getProperty(EventProps.widescreen).equals("1") ? true : false;
    	sVideoWidth = String.valueOf(myEvent.getPlayerWidth());
    	sVideoHeight = String.valueOf(myEvent.getPlayerHeight());
    } else {
    	sPlayButtonDivPad = "0"; //Ensures play button sits on properly on top of headshot window
    }
    
    if(isOD) {
    	//TODO: remove
		logger.log(Logger.INFO,"event.jsp", "eventId=" + sEventId + " is OD; myEvent.isSimLive=" + myEvent.isSimLive());
    
    	//check for simlive
    	if(myEvent.isSimLive()) {
    		lCurrentDate = System.currentTimeMillis();    		 
    		isPreSimlive = myEvent.isPreSimLive();
    		isSimLiveRunning = myEvent.isSimLiveRunning();
    		isSimlive = isPreSimlive || isSimLiveRunning;
    		
    	   	//TODO: remove
    		logger.log(Logger.INFO,"event.jsp", "eventId=" + sEventId + " isSimlive=" + isSimlive + " isPreSimlive=" + isPreSimlive + " isSimLiveRunning=" + isSimLiveRunning);
   
    		if(isPreSimlive) {
    			sDate = myEvent.getSimliveStartDateDisplay();
    			if(!sDate.equals("")) {
    				sDate = hmAllPlayerText.get("wmsg_scheduled_for") + ": " + sDate;
    			}
    		}
    	}
    	//isHDS = true;
    	if(!isPreSimlive && !isSimlive) {
    		bShowCounter = true;
    		if(StringTools.n2I(sVideoWidth)<321){
    			bStatusOn2 = true;	
    		}
    	}
    }
    
    if(isSimlive && !isPreSimlive) {
    	long currentDate = System.currentTimeMillis();
    	lPlayIndex = (currentDate - myEvent.getSimliveStartTime()) / 1000;
    }
    
	if(!myEvent.isPlayerOpen()){%>
		<jsp:forward page="notavailable.jsp" />
	<%
		}
	  
	    codetag = myEvent.getProperty(EventProps.codetag);
	   
	    sTitle = myEvent.getProperty(EventProps.title);
	    sContentUrl = "https://" + myEvent.getProperty(EventProps.content_url) + "/content/";
	    sContentUrl = LocaleTools.matchToRequestDomain(sServerName,sContentUrl);
	    
	    /*if(sServerName.indexOf(".gmwebcasts.cn")>0){
	    	sContentUrl= sContentUrl.replace(".webcasts.com",".gmwebcasts.cn");
	    }*/    
	     
	    sBannerUrl =  myEvent.getProperty(EventProps.banner_url);
	       
	    if(!Constants.EMPTY.equals(sEventGUID)){
	    	sEventGUID = sEventGUID+ "/";
	    }
	    
	    
	    sClientid = myEvent.getProperty(EventProps.fk_clientid);
	    sPlayerSize = myEvent.getProperty(EventProps.video);
	    
	    if(Constants.EMPTY.equals(sPlayerSize)){
	    	sPlayerSize = "standard";
	    }
	      
	    isIOS = (userAgent.indexOf("iphone")!=-1 || userAgent.indexOf("ipad")!=-1);
	    isIPhone = userAgent.indexOf("iphone")!=-1;
	    if(!isIOS){
	    	isHLS = ((userAgent.indexOf("chrome")!=-1 && userAgent.indexOf("android")!=-1) || userAgent.indexOf("blackberry")!=-1 || userAgent.indexOf("bb10;")!=-1 || userAgent.indexOf("playbook")!=-1);
	    	isAndroidChrome = isHLS;
	    }
	    
	   	isSlides = myEvent.getProperty(EventProps.slides).equals("1") ? true : false;
	    bUserControlSlides = "1".equals(myEvent.getProperty(EventProps.user_control_slide_enable))?true:false;
	        
	    if(isSlides){
	        sSlides = myEvent.getViewerSlideJsonString();
	    }  
	    String sStreamsJson = "";
	    if(isOD){
	    	if(isSimlive) {
	    		isLiveQA = myEvent.hasLiveQA();
	            isQAAnswer = myEvent.displayLiveQAAnswer();
	            qa_email_address = myEvent.getProperty(EventProps.live_qa_email_address);
	    	}else{
	    		isODQA = isOD && myEvent.hasODQA();
	            isQAAnswer = isOD && myEvent.displayODQAAnswer();	
	            qa_email_address = myEvent.getProperty(EventProps.od_qa_email_address);
	    	}
	        
	        sMode = "ondemand";
	        odm = new OdStudioManager(iEventId, true);
	        odm.load(myEvent.getCurrentVersion());
	        ODEvents = odm.json(true,true).toString();
	       
	        oSecondaryMedia =new OdPlaylist(Constants.DB_VIEWERDB,iEventId,true).getSecondaryMediaViewerJson().toString();
	        mp3download = myEvent.getProperty(EventProps.mp3download).equals("1")?true:false;

	        vtt_caption = myEvent.getProperty(EventProps.vtt_caption);
	        if (Constants.EMPTY.equals(vtt_caption)) { 
	        	vtt_caption = Constants.EMPTY_JSON;
	        }

	        disable_od_seek = myEvent.getProperty(EventProps.disable_od_seek).equals("1") || isSimlive;
	        caption = myEvent.getProperty(EventProps.caption);
	        if(Constants.EMPTY.equals(caption)){
	        	caption= Constants.EMPTY_JSON;
			}
	        
	        sTranscriptUrl = myEvent.getSpeechToTextViewerFileUrl();
	        sTranscriptUrl = LocaleTools.matchToRequestDomain(sServerName,sTranscriptUrl);    
	    }else{
	    	if(sMode.equals("live")){
	    		if(!bUserControlSlides){
	    			sCurrentSlide = myEvent.getStatus(EventStatus.current_slide_id).getValue();
	    		}
	    		sCurrentSurvey = myEvent.getStatus(EventStatus.current_survey_id).getValue();
	    		sCurrentSurveyResult = myEvent.getStatus(EventStatus.current_surveyresult_id).getValue();
	    		if(isAudio){
	    			sCurrentHeadShot = myEvent.getStatus(EventStatus.current_headshot_id).getValue();
	    		}
	    		
	    		sCurrentLayout = myEvent.getStatus(EventStatus.current_viewer_layout).getValue();
	    		
	    
	       	}
			sBroadcasting = myEvent.getStatus(EventStatus.broadcasting).getValue();

	        sDate = myEvent.getProperty(EventProps.start_date_display).replace("Scheduled for", hmAllPlayerText.get("wmsg_scheduled_for"));
	        isLiveQA = !isOD && myEvent.hasLiveQA();
	        isQAAnswer = !isOD && myEvent.displayLiveQAAnswer();
	        bPhoneOption = myEvent.allowListenByPhone();
	        selectedBridgeType = myEvent.audienceBridgeType();
	       
	        qa_email_address = myEvent.getProperty(EventProps.live_qa_email_address);
	        isUserAudioBackup = myEvent.getStatus(EventStatus.user_audio_backup).value.equals("1");
	       
	    }
	    globalConfig = Configurator.getInstance(Constants.ConfigFile.GLOBAL);
	    trackerUrl = "https://" + Tracker.getTrackerDomainByEvent(myEvent)  +  "/status/loginstatus.jsp";
	    
	    sVTTUrl = "https://" + myEvent.getProperty(EventProps.content_url) + "/content/" + sEventGUID + globalConfig.get(Constants.SECURED_DOCUMENT_FOLDER_CONFIG) + "/vtt/";
	    sVTTUrl = LocaleTools.matchToRequestDomain(sServerName, sVTTUrl); 
	   
	    trackerUrl = LocaleTools.matchToRequestDomain(sServerName,trackerUrl);   
	    isStreamUserIDTracking = globalConfig.get("use_stream_userid").equals("1")? true:false;
	    sTrackerRefresh = myEvent.getProperty(EventProps.trackerrefreshrate);
	    if(Constants.EMPTY.equals(sTrackerRefresh)){
	    	sTrackerRefresh = globalConfig.get("trackerrefreshrate","30001");
	    }
			
		lOdpauseTimeout = StringTools.n2l(globalConfig.get("odpausetimeout"),600) +  myEvent.getArchiveOdDuration();
		
	    if(!isOD || isSimlive){
	    	sStatusRefresh = myEvent.getProperty(EventProps.statusrefreshrate);
	    	if(Constants.EMPTY.equals(sStatusRefresh)){
	    		sStatusRefresh= globalConfig.get("statusrefreshrate","5001");
	    	}
	       	sStatusRefreshFactor = globalConfig.get("sStatusRefreshFactor","0.0025");
	    	
	    }
	    
	    sUser_cnt = myEvent.getProperty(EventProps.audiencecap);
	   
	    if(Constants.EMPTY.equals(sUser_cnt))sUser_cnt = "1001";
	  
	    if(myEvent.getProperty(EventProps.chat_enabled).equals("1")){
	    	 iAudience_cap = StringTools.n2i(sUser_cnt);
	    	 chatConfig = Configurator.getInstance(Constants.ConfigFile.CHAT);
	    	 iChatroom_cap = StringTools.n2i(chatConfig.get("room_cap"),1000);
	    }
	    
	    if(mp3download){
	    	mp3_download_url = globalConfig.get("mp3_download_url");
	    }
	    if(isLiveQA || isODQA){
	        QAModule = globalConfig.get("qnaurl").replace("http://","https://");
	    }
	    surveyModule = globalConfig.get("surveyurl").replace("http://","https://");
	   
	    
	    sSecuredContentFolder = globalConfig.get(Constants.SECURED_DOCUMENT_FOLDER_CONFIG);
	    
	    sViewerUploads=myEvent.getVisibleUploadsJsonString();
	    displayChat = (isSimlive || sMode.equals("live") || sMode.equals("prelive")) && iChatroom_cap >= iAudience_cap;
	    alAllTabs = new ArrayList<TabListBean>(myEvent.getTabs());
	    final String sTabGroupAccordion = Integer.toString(Constants.TAB_TYPE_ACCORDION);
	    int tabTypeValue;
	    for (TabListBean tab : alAllTabs) {
	    	tabTypeValue = StringTools.n2i(tab.getTabType(), -1);
	    	
			if (tabTypeValue != Constants.TabType.CHAT.value() || displayChat) {
				if (!"en-us".equalsIgnoreCase(sLanguage)) {
					if (tabTypeValue == Constants.TabType.QA.value()) {
						if ("ask a question".equalsIgnoreCase(tab.getTabTitle())) {
							tab.setTabTitle(myEvent.getPlayerTextForField("tab_ask_question"));
						}
					} else if (tabTypeValue == Constants.TabType.RESOURCES.value()) {
						if ("event resources".equalsIgnoreCase(tab.getTabTitle())) {
							tab.setTabTitle(myEvent.getPlayerTextForField("tab_evt_resources"));
						}
					} else if (tabTypeValue == Constants.TabType.CHAT.value()) {
						if ("chat".equalsIgnoreCase(tab.getTabTitle())) {
							tab.setTabTitle(myEvent.getPlayerTextForField("aud_chat_title"));
						}
					}
				}
		
				if (sTabGroupAccordion.equals(tab.getTabgroup())) {
					alAcordTabs.add(tab);
				} else {
					alTabs.add(tab);
				}
			}
		}
	 
	   sBackground_image =  myEvent.getBranding().getEvent_Background_image();
	    sBackground_color =  myEvent.getBranding().getEvent_background_color_hex();
	    if (sBackground_image.startsWith(Constants.EVENT_BG_SAME_AS_REG)){
	   	  sBackground_image =  myEvent.getBranding().getBackground_image();
	    }
	    if (sBackground_color.startsWith(Constants.EVENT_BG_SAME_AS_REG)){
	    	sBackground_color =  myEvent.getBranding().getBackground_color();
	    }
	    
	    sBranding_highlight =  myEvent.getBranding().getPlayer_highlight();
	    sPlayer_customcss = myEvent.getBranding().getPlayer_customcss();
	    sViewerBackground_color = myEvent.getBranding().getViewer_background_color();
	    sBannerBackground_color = myEvent.getBranding().getBanner_background_color();
	    sBannerRight_image = myEvent.getBranding().getBannerRight_image();
	    sPlayer_templatecss = myEvent.getTemplateBranding().getPlayer_templatecss();
	    
	    sFooter = myEvent.getProperty(EventProps.custom_footer);
	    
	    if(!Constants.EMPTY.equals(sContentUrl)){
	    	if(!Constants.EMPTY.equals(sBannerUrl)) {
	           	sBannerUrl = sContentUrl + sEventGUID + "banner/" + sBannerUrl;
	        }
	    	if(!Constants.EMPTY.equals(sBannerRight_image)) {
	           	sBannerRightUrl = sContentUrl + sEventGUID + "banner/" + sBannerRight_image;
	        }
	    }
	    
	    if(Constants.EMPTY.equals(sBannerUrl) && Constants.EMPTY.equals(sBannerRight_image)){
	    	sBannerBackground_color=sViewerBackground_color;
	    }
	    sTscinfo = myEvent.getProperty(EventProps.tsc_info);
		sShowWebcastBy = myEvent.getProperty(EventProps.showwebcastby);
		isIntegratedAudio = myEvent.isEventIntegratedAudio();
		isTelAudioAdvanced = myEvent.isAdvanceAudioProp() && isIntegratedAudio;
		
		if(!isOD) {
			//load streams
			ArrayList<LiveStream> alStreams = LiveStream.loadByEventId(iEventId);
			
			for (LiveStream ls : alStreams) {
		if (ls.getProfile().getMediaType().equals("audio")) {
			sAudioStreamId = ls.getLiveStreamId();
		}
		
		if ("Primary Stream".equalsIgnoreCase(ls.getStreamDesc())) {
			sPrimaryStreamId = ls.getLiveStreamId();
		}else if ("Backup Stream".equalsIgnoreCase(ls.getStreamDesc())) {
			sBackupStreamId = ls.getLiveStreamId();
		}			
			}
			
			sStreamId = myEvent.getStatus(EventStatus.current_player_stream).value;		
			
			if(!isAudio){
		
		//Multicast and windows media Video
		if(myEvent.isFlashMulticast()){
			isFlashMulticast = true;
			//ishtml5player = false;
			isFlashmulticastfallback = myEvent.isFlashMulticastRollBack();
			sFlashMulticastRollToBackupType = myEvent.FlashMulticastRollBackToBackupType();
			sMulticastConfJson = myEvent.getMulticastConfigListJsonString(Constants.MULTICAST_TYPE_FLASH);
			
			if(Constants.EMPTY.equals(sMulticastConfJson)){
				sMulticastConfJson= Constants.EMPTY_JSON;
			}
		}else{
			sMulticastConfJson= Constants.EMPTY_JSON;
		}
		
			}
			
			
			isLiveOverlayEnabled = StringTools.n2b(myEvent.getProperty(EventProps.live_overlay));
			
			if(isTelAudioAdvanced){
		sBroadcasting = "1"; //Keep broadcast flag 1 
		ishtml5player=true;
			}
			
			if(bPhoneOption){
		if(Constants.AudienceBridgeType.AUTO_AUDIENCE_BRIDGE.dbValue().equalsIgnoreCase(selectedBridgeType)){
			if(myEvent.getProperty(EventProps.acquisition_source).equalsIgnoreCase(Constants.ACQUISITION_SRC_AUDIO) && isIntegratedAudio){
		    	try{
		    		if(myEvent.isAdvanceAudio()){
		    			if(sStreamId.equals(sPrimaryStreamId)){
							currentBridgePriority = 0;
						}else if(sStreamId.equals(sBackupStreamId)){
							currentBridgePriority = 1;
						}
		    			audienceBridge = myEvent.getAudienceBridgeJson(currentBridgePriority).toString();	
		    		}else{
		    			audienceBridge = myEvent.getAudienceBridgeJsonString();
		    		}			    		
		    	}catch(Exception e){
		    		logger.log(Logger.CRIT,"jsp","Error parsing BridgeInfo for eventid: " +  iEventId  + "\nstacktrace:\n" + ErrorHandler.getStackTrace(e),"event.jsp");
		    	}
			}
			if(audienceBridge.equals(Constants.EMPTY)){
				bPhoneOption = false;
			}
		}else if(Constants.AudienceBridgeType.CLICK_TO_JOIN.dbValue().equalsIgnoreCase(selectedBridgeType)){
			 //check for bridge type first....
		     sClicktojoinlabel  = myEvent.getClickToJoinInfoByKey(Constants.ClickToJoinKeys.SECTION_LABEL);
		     if(Constants.DEFAULT_PLACEHOLDER.equals(sClicktojoinlabel)){
		      	sClicktojoinlabel = StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_c2j_label"));
		      }
		      sClicktojoinurl  = myEvent.getClickToJoinInfoByKey(Constants.ClickToJoinKeys.CALL_ME_URL);
		      sDialinurl  = myEvent.getClickToJoinInfoByKey(Constants.ClickToJoinKeys.DIAL_IN_URL);
		}else if(Constants.AudienceBridgeType.CUSTOM_BRIDGE.dbValue().equalsIgnoreCase(selectedBridgeType)){
			JSONObject customBridge = new JSONObject();
		  	customBridge.put("number",myEvent.getProperty(EventProps.bridge_number));
		  	sCustomNumbers = myEvent.getProperty(EventProps.custom_bridge_text);
		  	isBridgeCustom = true;
		  	if(!Constants.EMPTY.equals(sCustomNumbers)){
				JSONObject jText = new JSONObject(sCustomNumbers);
				customBridge.put("txt", jText.optString("txt"));
				customBridge.put("moretxt", jText.optString("moretxt"));
				customBridge.put("enabled", jText.optString("enabled"));					
			}
		  	audienceBridge = customBridge.toString();
		  	if(audienceBridge.equals(Constants.EMPTY)){
				bPhoneOption = false;
			}
		}else{
			bPhoneOption = false;
		}
		
			
			}
			if(bPhoneOption && isAudio) {
			   	isPhoneDefault = myEvent.getProperty(EventProps.phone_default).equals("1");
			   	isPhoneOnly = myEvent.getProperty(EventProps.phone_only).equals("1");
			}
		}
		
		// load ABR features ONLY if there is no MC feature enabled
		if (!isFlashMulticast) {	
	    	isAdaptiveBitrateEnabled = myEvent.isAdaptiveBitrate();
	    
	    	if (isAdaptiveBitrateEnabled == true && isIOS == false && isAndroidChrome == false) {
	    		sAdaptiveBitrateStreamsJson = "[{\"rate\":800000,\"name\":\"mp4:" + sPrimaryStreamId + "\"},{\"rate\":200000,\"name\":\"mp4:" + sPrimaryStreamId + "_1\"}]";
	    	    try {
	    	    	nFlashBandwidthCheckerDelaySec = Integer.valueOf(globalConfig.get("flash_abr_bwcdelay_sec", "10")).intValue();
	    	        if (nFlashBandwidthCheckerDelaySec < 0) nFlashBandwidthCheckerDelaySec = 0;
	    	        else if (nFlashBandwidthCheckerDelaySec > 120) nFlashBandwidthCheckerDelaySec = 120;	
	    	    } catch (NumberFormatException e) {    	
	    	    }
	    	}    
		}
		
		hasSMILFilesForCurrentVersion = myEvent.hasSMILFilesForCurrentVersion();
		
		String oAnalytics_val = myEvent.getProperty(EventProps.analytics);
		
		 if(!Constants.EMPTY.equals(oAnalytics_val)){
		   	sAnalytics_code = myEvent.getAnalyticsCodeForEvent();
		 }
		 
		 isKontikiMulticast = myEvent.isKontikiMulticast();
		 isHiveMulticast = myEvent.isHiveMulticast() && (myEvent.hasSimLiveSchedule() || !myEvent.isModeOnDemand());
		 isKollectiveMulticast = !isOD && myEvent.isKollectiveMulticast();	 
		 isHiveFallback = myEvent.isHiveMulticastRollBack();
		 multicastConfig = Configurator.getInstance(Constants.ConfigFile.MULTICAST);
		 
		 if(isHiveMulticast){	    	
		     enableHiveJS = StringTools.n2b(myEvent.getMediaSelection("hivejs"));
		 }		
		 if(isKollectiveMulticast){
			 kollective_contentToken = myEvent.getProperty(EventProps.kollective_token);
		 }
		 isViblastPDN = false;
		 
		 if((tp_special>15 && !isOD) && (tp_special < 63 && !isOD)){ //In room view
			 bInRoomView = true;
			 alAcordTabs.clear();
			 alTabs.clear();
			 sCurrentSlide = Constants.EMPTY;
			 sCurrentHeadShot = Constants.EMPTY;
			 isPhoneDefault = true;
		     isPhoneOnly = true;
		     bShowAddCustomNumbers = false;
		     sBridge_number = Constants.EMPTY;
		     isSlides = false;
		     sSlides = Constants.EMPTY_JSON;
		     sVideoHeight = "0";
		     sViewerUploads = "{}";
		 }
		 sPassThruUrl = "/viewer/endsession.jsp?ei=" + sEventId;
		if(!Constants.EMPTY.equals(sTpKey)){
			sPassThruUrl = sPassThruUrl + "&tp_key=" + sTpKey;
		}
		
		displayQA = isLiveQA || isODQA;
		generateQATab = bInRoomView || (!myEvent.hasTabType(Constants.TabType.QA.value()) &&  displayQA);
		
		isModeLiveOrPrelive = sMode.equals("live") || sMode.equals("prelive");
		isRampMulticast = myEvent.isRampMulticast() && isModeLiveOrPrelive;
		isRampCache = myEvent.isRampCache() && isModeLiveOrPrelive;
		sViblast = myEvent.getProperty(EventProps.viblast_folder);
		if(!bIE11){
			sVideojs = myEvent.getProperty(EventProps.videojs_folder);
		}
		if(isModeLiveOrPrelive){
			sMulticastType = myEvent.getMulticastType();	
		}
		
		//myEvent.addScheduleData();
		String resourceType = myEvent.getProperty(EventProps.resourcetype);
		isWebcam = Constants.ResourceType.WEBCAM_ADVANCED.dbName().equals(resourceType) || Constants.ResourceType.WEBCAM.dbName().equals(resourceType) ;
		isEnableFastyCookie = StringTools.n2b(globalConfig.get("fastly_enable_cookie"));
		sPostMsgApiTarget = myEvent.getProperty(EventProps.postmsgapitarget);
		tpSocialCode = myEvent.getProperty(EventProps.add_social);
		bVideoJSOnly = myEvent.isVideoJSOnly();
		if(alTabs.size()>0 || isSlides){
			sPrelive_player_layout = myEvent.getProperty(EventProps.prelive_player_layout);
		}else{
			bPlayerOnly = true;
		}
		sBanner_alt_tags = myEvent.getProperty(EventProps.banner_alt_tags);
		if(!Constants.EMPTY.equals(sBanner_alt_tags)){
			JSONObject jAltText = new JSONObject(sBanner_alt_tags);
			sBannerMain_alt = StringTools.n2s(jAltText.optString("main"));
			sBannerRight_alt  = StringTools.n2s(jAltText.optString("right"));
		}

		if(!Constants.EMPTY.equals(sPlayer_customcss) && sPlayer_customcss.indexOf("__MODERNLAYOUT__")>-1){
			String sReplace = "</style><link href=\"" + sTemplatePath + "style/modernlayout.css?" + codetag + "\" rel=\"stylesheet\" type=\"text/css\" /><style>"; 
			sPlayer_customcss = sPlayer_customcss.replaceAll("__MODERNLAYOUT__",sReplace);
		}
		analyticsActive = StringTools.n2b(globalConfig.get(Constants.ANALYTICS_ACTIVE_CONFIG));
	
	} catch (Exception e) {
		logger.log(Logger.CRIT,"jsp","Error for event " + sEventId,"event.jsp");
		logger.log(Logger.DEBUG,"jsp","stacktrace:\n" + ErrorHandler.getStackTrace(e),"event.jsp");
	  response.sendRedirect("/error.html");
	  return;
	}
	%>
<!DOCTYPE html>
<html lang="<%=sLanguage%>">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name=viewport content="width=device-width, initial-scale=1">
<jsp:include page="share_include.jsp">
	<jsp:param name="tpSocialCode" value="<%=tpSocialCode%>"/>
	<jsp:param name="sTitle" value="<%=sTitle%>"/>
	<jsp:param name="sEventId" value="<%=sEventId%>"/>
	<jsp:param name="sTpKey" value="<%=sTpKey%>"/>
</jsp:include>
<title><%=sTitle%> - <%=sEventId%></title>
<link href="<%=sTemplatePath%>style/jquery-ui.css?<%=codetag%>" rel="stylesheet" type="text/css" />
<link href="<%=sTemplatePath%>style/player.css?<%=codetag%>" rel="stylesheet" type="text/css" />
<link href="/include/<%=sVideojs%>/video-js.min.css?<%=codetag%>" rel="stylesheet" type="text/css" />
<%if(bIE11){%>
	<link href="/include/talkpoint_IE11_Win7.css?<%=codetag %>" rel="stylesheet" type="text/css" />
<%}else{%>
	<link href="/include/talkpoint.css?<%=codetag %>" rel="stylesheet" type="text/css" />
<%}%>
<% response.setHeader("X-DOWNLOAD-OPTIONS","NOOPEN"); %>
<jsp:include page="branding.jsp">
	<jsp:param name="sBranding_highlight" value="<%=sBranding_highlight%>"/>
	<jsp:param name="sBackground_content" value="<%=sContentUrl + sEventGUID%>"/>
	<jsp:param name="sBackground_image" value="<%=sBackground_image%>"/>
	<jsp:param name="sBackground_color" value="<%=sBackground_color%>"/>
	<jsp:param name="sPlayer_customcss" value="<%=sPlayer_customcss%>"/>
	<jsp:param name="sReg_customcss" value=""/>
	<jsp:param name="sViewerBackground_color" value="<%=sViewerBackground_color%>"/>
	<jsp:param name="sBannerBackground_color" value="<%=sBannerBackground_color%>"/>
	<jsp:param name="sReg_templatecss" value=""/>
	<jsp:param name="sPlayer_templatecss" value="<%=sPlayer_templatecss%>"/>
</jsp:include>
<script type="text/javascript" src="/js/analytics.js"></script>
<style>
/*******************/
/* responsive code */
/*******************/
@media only screen and (max-width: 639px) { 
   #viewer_video{
        width: 100% !important;
   }
	
   #viewer{
       display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
	
    #viewer_footer, #viewer, #viewer_banner{
        width: auto !important;
    }
	
    #player, #viewer_video, #viewer, #playbuttonDiv, #secondarymedia{
       width: 100vw !important;
    }
	    
    #survey_frame{
       height: 150% !important;
    }
    
    #lobby{
       width: 65%;
    }
}

@media only screen and (max-height: 500px) {
   #secondarymedia{
      width: 100% !important;
      height: 99vh !important;
   }
   
   #loadingbox{
      padding: 0px !important;
   }
   
   .removeVideo125 .ui-tabs-nav{
	    display: none !important;
	}
}
/**** same as removeSlide125 #surveyresult_frame from playercss ****/
.playerOnly #surveyresult_frame, .playerOnly #survey_frame{
    width: 50vw;
    height: 60vh;
    position: fixed;
    left: 20%;
    right: 20%;
    top: 15vh;
    z-index: 10;
}
.bmpui-ui-watermark {
	display: none;
}
.bmpui-ui-piptogglebutton {
	display: none !important;
}
</style>
<%if(bInRoomView){%>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<style>
p,div,ul,li,td,input,select,textarea,span {font-size:16px}
input.tp-button, button.tp-button {padding:6px 16px}
#viewer, #viewer_banner {width:100%!important; max-width:100%!important; }
#lobby { max-width:300px!important;}

@media only screen and (max-width: 820px) {
    #viewer_video{
        width: 100%;
    }
}
</style>
<% } %>
<% if(isIPhone){ %>
<style type="text/css">video::-webkit-media-controls {display:none !important;}</style>
<% } %>
<% if(ishtml5slide){ %>
<style type="text/css">
#slidecontrolbuttons .ui-icon-arrow-4-diag { background-position: -241px -80px}
#slidecontrolbuttons .ui-icon-closethick { background-position: -224px -80px}
</style>
<% } %>
</head>
<body id="playerBody">
<jsp:include page="banner.jsp">
	<jsp:param name="sBannerUrl" value="<%=sBannerUrl%>"/>
	<jsp:param name="sBannerRightUrl" value="<%=sBannerRightUrl%>"/>
	<jsp:param name="mType" value="<%=isAudio?'a':'v'%>"/>
	<jsp:param name="exithelp" value="1"/>
	<jsp:param name="ei" value="<%=sEventId%>"/>
	<jsp:param name="alt_help" value="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get(\"alt_help\"))%>"/>
	<jsp:param name="alt_exit" value="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get(\"alt_exit\"))%>"/>
	<jsp:param name="language" value="<%=sLanguage%>"/>
	<jsp:param name="sBannerMain_alt" value="<%=sBannerMain_alt%>"/>
	<jsp:param name="sBannerRight_alt" value="<%=sBannerRight_alt%>"/>
</jsp:include>
   
<div id="viewer" class="ui-widget <%=bPlayerOnly?" playerOnly":""%>">
  <div id="viewer_video"  style="width:<%=sVideoWidth%>px;" class="left">
  <div id="debug_ts" style="display:none">PDT: <span id="showcap"></span> viewer: <span id="showvt"></span></div>
    <div id="player" style="height:<%=sVideoHeight%>px" class="ui-corner-tl ui-corner-tr">
       	<div id="player_headshot">
      		<img name="headshot" id="headshot" src="<%=sTemplatePath + sStandbyGif%>" hspace="0" vspace="0" border="0" style="display:none" tabindex='0' aria-label='head shot'/>
      		<div id="noheadshot" style="display:none"><span><%=sTitle%></span></div>
      		<% if (!isAudio && (isOD || isSimlive)) { %>
      			<div id="vttcaptions" style="display:none; position: absolute; bottom: 30px; width: 100%; mix-width: 100%; max-width: 100%; text-align: center; color: #ddd; background: rgba(0, 0, 0, 0.75); font-weight: bold; font-size: 14pt;"></div> -->
      		<% } %>
      	</div>
      	<div id="playermsg" class="player_hide"><div id="playermsg_wrapper"><span id="playermsg_txt"></span><br>
        	<button type="button" class="ui-state-default ui-corner-all tp-button" id="playermsg_ok"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("close"))%></button></div>
      	</div>
    	<div id="flvplayer"><video id="playerVdo" disablePictureInPicture=true></video></div>
		<div id="ReactWedge"></div>
    	<div id="playbuttonDiv" style="height:<%=StringTools.n2I(sVideoHeight)-StringTools.n2I(sPlayButtonDivPad)%>px;width:<%=sVideoWidth%>px;position:absolute;display:flex;justify-content:center;align-items:center;left:0px;top:0px;z-index:10;">
       	    <span>
       	   	<img src="<%=sTemplatePath%>style/images/playbutton-large.png" tabindex="0" onkeypress="$('#playbuttonDiv').click()" name="playbutton" id="playbutton" style="display:block;margin:auto;width:25%;" title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_play"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_play"))%>"/></span>
    	</div>
    	
    	<%if(isKollectiveMulticast){ %>    	
    	<div id="streamProgressDiv">
       	    <div id="streamProgress">
       	    	<div id="streamSuccess"></div>
   				 <div id="progressText">Loading Stream <span id="streampercent">5%</span></div>
    		</div>
    	</div>
    	<%}%>
	</div>
	<% if (/*isAudio && */(isOD || isSimlive)) { %>
		<div id="vttcaptions" style="display: none; width: 100%; mix-width: 100%; max-width: 100%; text-align: center; color: #ddd; background: rgba(0, 0, 0, 0.75); font-weight: bold; font-size: 14pt;"></div>
	<% } %>
	<div id="vttcontentonly" style="display: none; width: 100%; mix-width: 100%; max-width: 100%; text-align: center; color: #ddd; background: rgba(0, 0, 0, 0.75); font-weight: bold; font-size: 14pt;"></div>
	
   <%if(!bInRoomView && bPhoneOption){%>
	   	<div id="bridge_info" class="ui-corner-bl ui-corner-br ui-widget-header" style="display:none">
	  	<%if(!Constants.EMPTY.equals(sClicktojoinurl) || !Constants.EMPTY.equals(sDialinurl)){%>
	  	  	<div><strong><%=sClicktojoinlabel%></strong></div>
	   		<%if(!Constants.EMPTY.equals(sDialinurl)){%>
	    	<button type="button" class="ui-state-default ui-corner-all tp-button" id="dialinurl"/><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_c2j_dial_in"))%></button>
	    	<div id="dialinurl_div" class="tab_content tab_hide ui-corner-bottom"><iframe id="dialinurl_frame" name="dialinurl_frame" src="javascript:'';" allowtransparency="false" frameborder="0" scrolling="auto"></iframe></div>
	    	<%} %>  		
	  		<%if(!Constants.EMPTY.equals(sClicktojoinurl)){%>
	   		<button type="button" class="ui-state-default ui-corner-all tp-button" id="clicktojoinurl"/><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_c2j_call_me"))%></button>
	   		<div id="clicktojoinurl_div" class="tab_content tab_hide ui-corner-bottom"><iframe id="clicktojoinurl_frame" name="clicktojoinurl_frame" src="javascript:'';" allowtransparency="false" frameborder="0" scrolling="auto"></iframe></div>
	   		<%} %>	    	
	     <%}else{%>
	    	<div><strong><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_dial_in"))%></strong></div>
	    	<div class="iaBridgeCountryAndNumber" id="iaBridgeCountryAndNumber"></div>
	    <%} %>
	     </div>
	<%}%>
   	<div id="viewer_phone_option"  style="display:none">
   		<button type="button" class="ui-state-default ui-corner-all tp-button" id="phone">&nbsp;<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_listen_phone"))%>&nbsp;</button>
   		<% if(isOD || !isPhoneOnly) { %>
   		<button type="button" class="ui-state-default ui-corner-all tp-button" id="nophone" style="display:none">&nbsp;<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_listen_comp"))%>&nbsp;</button>
   		<%} %>
   	</div>
     <%if(!Constants.EMPTY_JSON.equals(caption)){%>
    	<div id="caption" class="ui-corner-bl ui-corner-br ui-widget-header" style="display:none">
    		<span id="caption_txt"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_load_caption"))%></span>
    	</div>
     <%}%>
     
     <%if(myEvent.isOpenCaptionsInViewerEnabled() && !isSimlive && isOD){%>
    	<div id="caption" class="transcript_caption ui-corner-bl ui-corner-br ui-widget-header" style="display:none">
    		<span id="transcript_txt" class="transcript_txt"></span>
    		<i class="fa fa-external-link-square" aria-hidden="true"></i>
    	</div>
     <%}%>  
              
   	 <% if(myEvent.isLiveTranscriptionEnabled() && !isSimlive && !isOD){ %>
         <div id="live_caption" class="verbit_caption verbitCaption transcript_caption ui-corner-bl ui-corner-br">
    		<span id="verbit_caption_txt" class="transcript_txt"></span>
    		<!-- <i id="verbit_full_caption_btn" class="fa fa-external-link-square verbit_full_caption_btn" aria-hidden="true"></i> -->
    	</div>
     <% } %>

    <div id="viewer_video_tabs" class="ui-accordion ui-widget">
    <% if(generateQATab){ %>
	   <h3  class="accordianiframeheader isopen" id="reviewqa"> <a href="#"  class="qa_title" id="reviewqa_title" tabindex='0'><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tab_ask_question"))%></a> </h3>
	   <div class="accordian_div">
       		  <iframe class="accordian_iframe" name="reviewqa_frame" id="reviewqa_frame" frameborder="0" src="javascript:'';" title="Ask a Question "></iframe>
        </div>
      <%}%>
     <%if(alAcordTabs.size()>0){ 
    	 // sidebar tabs
       	 for (TabListBean tab : alAcordTabs){ %>
       	 <%if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.QA.value()) && displayQA) {%>
       		  <h3  class="accordianiframeheader <%=tab.isOpen() ? "isopen" : ""%>" id="reviewqa"> <a href="#" class="qa_title" id="reviewqa_title" tabindex='0' aria-label='ask a question section'><%=tab.getTabTitle()%></a> </h3>
       		  <div class="accordian_div">
       		 	 <iframe class="accordian_iframe" name="reviewqa_frame" id="reviewqa_frame" frameborder="0" src="javascript:'';"></iframe>
       		  </div>
		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.RESOURCES.value())) {%> 
		      <h3 class="<%=tab.isOpen() ? "isopen" : Constants.EMPTY%> documentsheader" id="documentsheader"><a class="resources_title" href="#"><%=tab.getTabTitle()%></a></h3>
		      <div id="documentuploads"><ul></ul></div>
		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.CHAT.value())) {%> 
		      <h3 class="<%=tab.isOpen() ? "isopen" : Constants.EMPTY%>" id="chatheader"><a  class="chat_title" href="#"><%=tab.getTabTitle()%></a></h3>
			  <div id="chat">
		 		<iframe frameborder="0" scrolling="no" style="width:100%;height:100%" src="chat_tab.jsp?<%=Constants.RQEVENTID%>=<%=iEventId%>&<%=Constants.RQUSERID%>=<%=ui%>&<%=Constants.RQSESSIONID%>=<%=si%>&<%=Constants.RQEMAILADDRESS%>=<%=URLEncoder.encode(ea, "UTF-8")%>&fname=<%=URLEncoder.encode(fname, "UTF-8")%>&lname=<%=URLEncoder.encode(lname, "UTF-8")%>&sh0=<%=sh0%>&sh1=<%=sh1%><%=chatMessageString%>&location=<%=Constants.ChatLocation.VIEWER_LEFT_TAB.id()%>"></iframe>
			  </div>
		  <%} else if (Integer.valueOf(tab.getTabType()).equals(Constants.TabType.CHAPTERS.value()) && displayChaptersTab) {%> 
				<h3 class="<%=tab.isOpen() ? "isopen" : Constants.EMPTY%>" id="chaptersheader"><a class="chapters_title" href="#"><%=tab.getTabTitle()%></a></h3>
				<div id="jumppointdiv"></div>
		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.HTML.value())){%>
	       	 <h3 class="accordianiframeheader <%=tab.isOpen() ? "isopen" : Constants.EMPTY%>" id="<%=tab.getTabId()%>"> <a  class="html_title" href="#" ><%=tab.getTabTitle()%></a> </h3>
	       	 	<div class="accordian_div" <%if(isIOS){%> style="height:150px;-webkit-overflow-scrolling:touch; overflow:auto;"<%}%>>
	        		<iframe class="accordian_iframe" name="<%=tab.getTabId()%>_frame" id="<%=tab.getTabId()%>_frame" frameborder="0" src="javascript:'';"></iframe>
	      		</div>
      	 <%}%>
       	<%}
       }%>
    </div>
  
  </div>
   <div id="viewer_slide" class="left">
   
  	<%if(isOD && myEvent.isSpeechToTextFeatureEnabled(SpeechToTextConstants.Feature.TRANSCRIPT)){%>
	   	<div id="transcriptDiv" class="transcriptDiv">
			<span class="ui-state-default ui-corner-all right">
				<span id="transcript_close" class="transciprt_close ui-icon ui-icon-closethick" onkeypress="$('#transcript_close').click()" tabindex="0"></span>
			</span>
			<div class="fadeoutTop"></div>
			<section class="searchDefaultView">
				<div class="searchInputDiv">
						<input class="searchInput" type="text" placeholder="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tra_search"))%>" maxlength="40"/>
						<button id="searchInputBtn" class="searchInputBtn">
							<i class="searchInputBtnIcon fa fa-search"></i>
						</button>
					</div>
					<div class="header">Key Phrases:</div>
					<div id="suggestions" class="suggestions">
						<!-- <canvas id="suggestions_canvas" class="suggestions_canvas" width=700 height=500></canvas>  -->
					</div>
					<div class="fullTranscript hidden"></div>
					<div class="results">
						<div class="pagnation"></div>
				</div>
				<div class="transcriptBtns">
					<%if(myEvent.isShowSpeechToTextFeatureInViewer(SpeechToTextConstants.Feature.TRANSCRIPT)) {%>
						<button class="viewTranscriptBtn"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tra_full_tra"))%></button>
					<%}%>
					<%if(myEvent.isShowSpeechToTextFeatureInViewer(SpeechToTextConstants.Feature.KEY_PHRASES)) {%> 
						<button class="viewSuggestionsBtn"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tra_key_phrases"))%></button>
					<%}%>
					<%if(myEvent.isSpeechToTextDownloadInViewerEnabled()){ %>
						<button class="downloadFullText"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tra_download_tra"))%></button>
					<%}%>
				</div>
			</section>
			<div class="fadeout"></div>
	  	</div>  	
  	<%}%>
  	
  	  <!-- Verbit full text -->
   	<% if(myEvent.isLiveTranscriptionEnabled() && !isSimlive && !isOD){ %>
        <div id="transcriptDiv" class="transcriptDiv verbitTranscriptDiv"">
			<span class="ui-state-default ui-corner-all right">
				<span id="transcript_close" class="transciprt_close ui-icon ui-icon-closethick" tabindex="0"></span>
			</span>
			<section class="searchDefaultView">
				<div class="header">Captions:</div>
				<div id="fullTranscript" class="fullTranscript" style="display: block;"></div>
			</section>
		
	  	</div>  
    <%}%>
    
  	<div id="slide_overlay"></div>
	<iframe name="survey_frame" title="Survey" id="survey_frame" frameborder="0" src="javascript:'';" tabindex="0"></iframe>
	<iframe name="surveyresult_frame" title="Survey Results" id="surveyresult_frame" frameborder="0" src="javascript:'';" tabindex="0"></iframe>
 	<div id="viewer_slide_tabs" class="ui-corner-all ui-tabs ui-widget ui-widget-content">
   	  <ul class="ui-tabs-nav ui-helper-clearfix ui-widget-header ui-corner-all">
   	 	<%if(isSlides){ %>
       <li class="ui-state-default ui-corner-top" tabid="slide" id="slide_title"><a href="#"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("tab_slides"))%></a></li>
       <%} %>
       <%if(alTabs.size()>0){
    	   // primary tabs
       	 for (TabListBean tab : alTabs){%>
	       	  <%if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.QA.value()) && displayQA) {%>
	       	   <li class="ui-state-default ui-corner-top" tabid="<%=tab.getTabId()%>" id="<%=tab.getTabId()%>_title"><a class="qa_title" href="#"><%=tab.getTabTitle()%></a></li>
	  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.RESOURCES.value())) {%> 
	  		   <li class="ui-state-default ui-corner-top" tabid="<%=tab.getTabId()%>" id="<%=tab.getTabId()%>_title"><a class="resources_title" href="#"><%=tab.getTabTitle()%></a></li>
	  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.CHAT.value())) {%> 
		 	  <li class="ui-state-default ui-corner-top" tabid="<%=tab.getTabId()%>" id="<%=tab.getTabId()%>_title"><a class="chat_title" href="#"><%=tab.getTabTitle()%></a></li>  	
	  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.CHAPTERS.value()) && displayChaptersTab) {%> 
		 	  <li class="ui-state-default ui-corner-top" tabid="<%=tab.getTabId()%>" id="<%=tab.getTabId()%>_title"><a class="chapters_title" href="#"><%=tab.getTabTitle()%></a></li>
	  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.HTML.value())){%>
	  	 	   <li class="ui-state-default ui-corner-top" tabid="<%=tab.getTabId()%>" id="<%=tab.getTabId()%>_title"><a class="html_title" href="#"><%=tab.getTabTitle()%></a></li>
	          <%}%>
          <%}
       }%>
      </ul>
     <div id="tabs_content">
       	<div class="slidesOnlyPlayer">
			<div class="slidesOnlyPlayer__play">
				<i class="fa fa-play"></i>
			</div>
			<div class="slidesOnlyPlayer__pause">
				<i class="fa fa-pause"></i>
			</div>
			<div class="slidesOnlyPlayer__status"></div>
			<div class="slidesOnlyPlayer__volume-up">
				<i class="fa fa-volume-up"></i>
			</div>
			<div class="slidesOnlyPlayer__volume-down">
				<i class="fa fa-volume-off"></i>
			</div>
		</div>
      <div id="slide" class="tab_content tab_hide">
      	<div id="slidecontrols" style="display:none">
        <div id="slidecontrolbuttons" <%if (bUserControlSlides){ %> class="viewerControlledSlides" <%}%>>
         <ul>
      	   <li class="ui-state-default ui-corner-all">
      	   	<span class="ui-icon ui-icon-closethick" id="large_slide_close" style="display:none" title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("close"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("close"))%>"></span>
      	   	<span class="ui-icon ui-icon-arrow-4-diag" id="large_slide_open" title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_large_slide"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_large_slide"))%>"></span>
      	   </li>
      	   <%if (bUserControlSlides){ %>
	       <li title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_next_slide"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_next_slide"))%>" class="ui-state-default ui-corner-all" ><span class="ui-icon ui-icon-seek-next" id="next_slide"></span></li>
     	   <li title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_goto_slide"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_goto_slide"))%>"><span class="goToSlideSpan"><form onsubmit="return false;"><input type="text" size="3" maxlength="3" name="gotoslide" id="gotoslide" value="1"/> / <span id="slidecount"></span></form></span></li>
     	   <li title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_previous_slide"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_previous_slide"))%>" class="ui-state-default ui-corner-all" ><span class="ui-icon ui-icon-seek-prev" id="prev_slide"></span></li>
           <li title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_hide_slide_controls"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_hide_slide_controls"))%>" id="hideSlideControls" class="ui-state-default ui-corner-all"><span class="ui-icon ui-icon-triangle-2-e-w" id="hide_slide_icon"></span></li>
     	   <%}%>
      	 </ul>
      	 <div class="clear"></div>
      	 <div id="slidealert"></div>
      	</div>
       	 <ul id="slidecontrolclosed" style="display:none">
      	   <li title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_slide_controls"))%>" alt="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_slide_controls"))%>" class="ui-state-default ui-corner-all">
      	   	<span class="ui-icon ui-icon-triangle-2-e-w" id="slide_controls_close"></span>
      	   	</li>
      	</ul>
      	</div>
      	
       	<div class="clear"></div>
      	<span id="slideinfo"></span>
   	  </div>
      <%if(alTabs.size()>0){
    	  // primary tabs content
       	 for (TabListBean tab : alTabs){%>
       	  <%if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.QA.value()) && displayQA) {%>
       	  	<div id="<%=tab.getTabId()%>" class="tab_content tab_hide ui-corner-bottom isqa" <%if(isIOS){%> style="-webkit-overflow-scrolling:touch; overflow:auto;"<%}%>>
         	   <iframe class="accordian_iframe isqaright" name="reviewqa_frame" id="reviewqa_frame" frameborder="0" src="javascript:'';"></iframe>
  		  	</div>
  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.RESOURCES.value())) {%> 
  		      <div id="<%=tab.getTabId()%>" class="tab_content tab_hide ui-corner-bottom documentuploads" <%if(isIOS){%> style="-webkit-overflow-scrolling:touch; overflow:auto;"<%}%>>
  		      	<div id="documentuploads"><ul></ul></div>
  		      </div>
  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.CHAT.value())) {%> 
  		     	<div id="<%=tab.getTabId()%>" class="tab_content tab_hide ui-corner-bottom" <%if(isIOS){%> style="-webkit-overflow-scrolling:touch; overflow:auto;"<%}%>>
  				   <iframe frameborder="0" scrolling="no" style="width:100%;height:100%" src="chat_tab.jsp?<%=Constants.RQEVENTID%>=<%=iEventId%>&<%=Constants.RQUSERID%>=<%=ui%>&<%=Constants.RQSESSIONID%>=<%=si%>&<%=Constants.RQEMAILADDRESS%>=<%=URLEncoder.encode(ea, "UTF-8")%>&fname=<%=URLEncoder.encode(fname, "UTF-8")%>&lname=<%=URLEncoder.encode(lname, "UTF-8")%>&sh0=<%=sh0%>&sh1=<%=sh1%><%=chatMessageString%>&location=<%=Constants.ChatLocation.VIEWER_TOP_TAB.id()%>"></iframe>
  				</div>
  		  <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.HTML.value())){%>
  	       		<div id="<%=tab.getTabId()%>" class="tab_content tab_hide ui-corner-bottom"  <%if(isIOS){%> style="-webkit-overflow-scrolling:touch; overflow:auto;"<%}%>>
  	       			<iframe id="<%=tab.getTabId()%>_content" name="<%=tab.getTabId()%>_content" src="javascript:'';" allowtransparency="true" frameborder="0" scrolling="auto" allowfullscreen webkitallowfullscreen mozallowfullscreen width="100%" height="100%"></iframe>
  	       		</div>
          <%}else if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.CHAPTERS.value()) && displayChaptersTab){%>
  	       		<div id="<%=tab.getTabId()%>" class="tab_content tab_hide ui-corner-bottom"  <%if(isIOS){%> style="-webkit-overflow-scrolling:touch; overflow:auto;"<%}%>>
 					<div id="jumppointdiv"></div>
  	       		</div>
          <%}%>
       	 <%}
      }%>
      </div>   
	  <div id="qaUnderSlides" class="ui-accordion ui-widget" style="display:none;">	
		  <%if(alAcordTabs.size()>0){ 
	       	 for (TabListBean tab : alAcordTabs){ %>
	       	 <%if(Integer.valueOf(tab.getTabType()).equals(Constants.TabType.QA.value()) && displayQA) {%>
	       		  <h3  class="accordianiframeheader <%=tab.isOpen() ? "isopen" : ""%>" id="reviewqa"> <a href="#" class="qa_title" id="reviewqa_title" tabindex='0' aria-label='ask a question section'><%=tab.getTabTitle()%></a> </h3>
	       		  <div class="accordian_div">
	       		 	 <iframe class="accordian_iframe" name="reviewqa_frame" id="reviewqa_frame" frameborder="0" src="javascript:'';" title="Ask a Question"></iframe>
	       		  </div>
			  <%}%>
	       	<%}%>
	       <%}%>
	  </div>
  	</div>
  </div>

  <div id="sponsorlogo" role='img' aria-label='sponsor logo'></div>
  <div class="clear"></div>
  <%if(!Constants.EMPTY.equals(sFooter)){ %>
  <div id="disclaimer">
  	<%=sFooter%>
  </div>
  <%} %>
 </div>
 <div id="viewer_footer">
  <%if("1".equals(sShowWebcastBy)){ %>
	<%=globalConfig.get("viewerwebcastby")%>
	<div class="clear"></div>
  <%}%>
 </div>
<div id="overlay_content" role='dialog'>
  <table height="100%" width="100%" align="center" border="0">
    <tr>
      <td valign="middle">
	     <div class="ui-dialog ui-widget ui-widget-content ui-corner-all" id="lobby" style="display:none">
		   <div class="ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix">
		      <span id="ui-dialog-title-dialog" class="ui-dialog-title" tabindex="0"><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("wmsg_welcome_to_webcast"))%></span>
		   </div>
		   <div id='webcastInfo' style="height: auto; width: auto;margin:auto;" class="ui-dialog-content ui-widget-content" aria-label='webcast information'>
		     <h2 id="lobbyTitleModal" tabindex='0'><%=sTitle%></h2> <p id="lobbyDate" tabindex='0'><br/><strong><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("wmsg_not_started"))%></strong><br/>
				<span id="webcastInfoDate"><%=StringEscapeUtils.escapeHtml4(sDate)%></span><br/><br/></p>
                <p class="ui-corner-all" id="lobby_close" tabindex='0' aria-label='close webcast information dialog button'><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("close"))%></p>
		   </div>
	  	</div>
	     
		<div class="ui-dialog ui-widget ui-widget-content ui-corner-all" id="slideMsg" style="display:none;">
		   <div id="msgDiv" style="height: auto; width: auto;margin:auto;" class="ui-dialog-content ui-widget-content">
		     <h2 id="slideMsgTxt" tabindex="0"></h2> 
                <p class="ui-corner-all" id="btnCloseSlideMsg" tabindex="0">Close</p>
		   </div>
	  	</div> 
	  		
	  	<div class="ui-dialog ui-widget ui-widget-content ui-corner-all" id="odpausealert" style="display:none">
		   <div class="ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix">
		      <span id="ui-dialog-title-dialog" class="ui-dialog-title">Inactive Session</span>
		   </div>
		   <div style="height: auto; width: auto;margin:auto;" class="ui-dialog-content ui-widget-content" id="odpausealert_msg">
		     You will be logged out in <span id="odpausealert_cnt"></span> seconds<br/> unless you extend your session.<br/><br/>
                <p class="ui-corner-all" id="odpausealert_close">Extend Session</p>
		   </div>
	  	</div>
	  	<!-- No longer needed loadingbox as per ticket DKB-1782 description -->
	  	<%--
		<div id="loadingbox" class="ui-widget" aria-hidden="false">
      		<div id="alertBlock" class="ui-state-error ui-corner-all"></div>
        	<div id="alertInfo" class="ui-state-highlight ui-corner-all">Loading Player</div>
         	<img src="<%=sTemplatePath%>style/images/loading_text.gif" name="loadingtxt" id="loadingtxt" valign="middle" alt='Loading Page' tabindex='0' aria-label='loading page graphic'/>
    	</div> --%>
    	<iframe name="secondarymedia" id="secondarymedia" title="Overlay Video with additional information" allow="autoplay; fullscreen" frameborder="0" allowFullScreen="true" webkitAllowFullScreen="true" mozallowfullscreen="true" scrolling="no" src="javascript:'';"></iframe>
      </td>
    </tr>
  </table>
</div>
<div id="overlay_body"></div>
<form name="passThruForm" id="passThruForm" method="post" action="<%=sPassThruUrl%>">
   <input type="hidden" id="<%=Constants.PASSTHRU_USERID_ID%>" name="<%=Constants.PASSTHRU_USERID_NAME%>" value="<%=ui%>"/>
   <input type="hidden" id="<%=Constants.PASSTHRU_SESSIONID_ID%>" name="<%=Constants.PASSTHRU_SESSIONID_NAME%>" value="<%=si%>"/>
   <input type="hidden" id="ea" name="ea" value="<%=ea%>"/>
   <input type="hidden" id="fname" name="fname" value="<%=fname%>"/>
   <input type="hidden" id="lname" name="lname" value="<%=lname%>"/>
   <input type="hidden" id="company" name="company" value="<%=company%>"/>
   <input type="hidden" id="tp_land" name="tp_land" value="<%=isTp%>"/>
   <input type="hidden" id="act_type" name="act_type" value="exit"/>
   <input type="hidden" name="sh0" id="sh0" value="<%=sh0%>" />
   <input type="hidden" name="sh1" id="sh1" value="<%=sh1%>" />
   <input type="hidden" name="language" id="language" value="<%=sLanguage%>" />
 </form>

<jsp:include page="footerTop.jsp">
	<jsp:param name="piwik_enabled" value="<%=StringTools.n2b(myEvent.getProperty(EventProps.piwik_enabled))%>"/>
</jsp:include>

<% if (isHiveMulticast) { %>
	<script src="https://media-players.hivestreaming.com/plugins/html5/11.2.0/html5.java.hivejs.hive.min.js"></script>
	<script src="https://media-players.hivestreaming.com/common_libs/html5/bitmovin/hive-module.js"></script>
	<script> console.log('<!--%=myEvent.getStreamJWT()%-->'); </script>
<% } %>
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/bitmovin-player@8/bitmovinplayer.js" crossorigin></script>
<script type="text/javascript" src="https://unpkg.com/react@16/umd/react.development.js" crossorigin></script>
<script type="text/javascript" src="https://unpkg.com/react-dom@16/umd/react-dom.development.js" crossorigin></script>
<script type="text/javascript" src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js" crossorigin></script>
<script type="text/javascript" src="/include/bitmovin/index.js?<%=codetag%>" defer></script>

<script type="text/javascript" src="/viewer/include/json2.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerUploads.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerUtils.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerAccordion.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerSlide.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerSlideTab.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerAction.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerPlayer.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerControls.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerPlayerCallbacks.js?<%=codetag %>"></script>
<script type="text/javascript" src="/viewer/include/viewerLoader.js?<%=codetag %>"></script>
<% if(!bVideoJSOnly){ %>
	<% if(isKollectiveMulticast){%>
		<script src="https://cdn.kollective.app/sdk/ksdk-latest.min.js" defer></script>
	<% } %>
	<% if(/*isHiveMulticast ||*/ isKollectiveMulticast) {%>
		<script type="text/javascript" src="/js/multicastTools.js?<%=codetag %>"></script>
	<%}%>
<% } %>
<%if(isIOS ||isHLS){%>
<script type="text/javascript" src="/viewer/include/jquery.ui.touch-punch.js?<%=codetag%>"></script>
<%}%>
<%if(isOD){%>
	<script src="/js/highcharts/highcharts.src.js?<%=codetag %>"></script>
	<script src="/js/highcharts/wordcloud.js?<%=codetag %>"></script>
	<script src="/js/transcript.js?<%=codetag %>"></script>
<%}%>

	<script type="text/javascript">
	if (<%=analyticsActive%> === true) {
		//analyticsExclude(["param_eventCostCenter"]);
	    analyticsInit('<%=ui%>', {
			eventID: '<%=sEventId%>',
			clientID: '<%=sClientid%>'
	    });
	}

	var entityMap = {"&": "&amp;","<": "&lt;",">": "&gt;",'"': '&quot;',"'": '&#39;',"/": '&#x2F;'};
	function escapeHtml(string) {
		return String(string).replace(/[&<>"'\/]/g, function (s) {
			return entityMap[s];
		});
	}

	var BITMASK_OFF = {zoom:1,help:2,exit:4,noloading:8,bInRoomView:16,bNoInRoomView:32, embedVideoOnly:64};	
	var tp_special=0;	
	var bhidezoomwarning = false;
	var bnoloading = false;

	<%if(tp_special>0){%>
		tp_special = <%=tp_special%>;
		if(tp_special>0){
			bhidezoomwarning = ((tp_special & BITMASK_OFF.zoom)==BITMASK_OFF.zoom);
			bnoloading = ((tp_special & BITMASK_OFF.noloading)==BITMASK_OFF.noloading);
		 	if((tp_special & BITMASK_OFF.exit)==BITMASK_OFF.exit){
		 		if((tp_special & BITMASK_OFF.help)==BITMASK_OFF.help){
		 			$("#eventexit").hide();
		 		}else{
		 			$("#close").parent().parent().hide();
		 		}
		 		
		 	}else if((tp_special & BITMASK_OFF.help)==BITMASK_OFF.help){
		 		$("#help").parent().parent().hide();
	 		}
		 	
			if((tp_special & BITMASK_OFF.embedVideoOnly) == BITMASK_OFF.embedVideoOnly){
				if((!$.oViewerData.isSlides)&&($("#viewer_slide_tabs > .ui-tabs-nav >li").length < 1)){
					$('body').addClass('videoOnlyLayout').addClass('tp_special64');
				}
	 		}
		};
		
		<%if(bInRoomView){%>
			bnoloading=true;
		<%}%>
	<%}%>
	
	var tpPlayer=<%=tpPlayer%>;
	var mutePlayer = false;
	var autoPlayDisable = false;
	if(tpPlayer>0){
		var BITMASK_OFF_PLAYER = {mutePlayer:1,autoPlayDisable:2};
		mutePlayer = ((tpPlayer & BITMASK_OFF_PLAYER.mutePlayer)==BITMASK_OFF_PLAYER.mutePlayer);
		autoPlayDisable = ((tpPlayer & BITMASK_OFF_PLAYER.autoPlayDisable)==BITMASK_OFF_PLAYER.autoPlayDisable);
	}
	//document.domain="webcasts.com";
	var blocktxt="";
	var infotxt="";
	var v  =null;
	var cacheUrl = "<%=globalConfig.get(Constants.CACHE_BASE_URL)%>";
	var isStreamUserIDTracking = <%=isStreamUserIDTracking%>;	
	var playAlt = "<%=playAlt%>";
	var playAltMulticast = "<%=playAltMulticast%>";
	var Presentation = null;
	var presSettings=null;
	<%if(isKontikiMulticast){%>
	var kontikiServer = "<%=multicastConfig.get("kontiki_server")%>";	
	<%}%>
	<%if(isHiveMulticast){%>
	var hiveServer = "<%=multicastConfig.get("hive_test_host")%>";	
	<%}%>
	
	var sDate = '<%=StringEscapeUtils.escapeEcmaScript(sDate)%>';
	var postMsgJson = {"event_id":"<%=iEventId%>","event_status":"","stream_status":""};
	try{
	    var userLocalTZDisplayDate = '<%=userLocalTZDate%>';
	    if(userLocalTZDisplayDate && userLocalTZDisplayDate.length > 0){
		    sDate = sDate + " (" + userLocalTZDisplayDate + ")"; 
	    }
	}catch(e){}
	
	$(document).ready(function(){
		$.browser.msie = ((navigator.appName == 'Microsoft Internet Explorer') || ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null)));
 		$.oFlash = {"bStat":0,"version":{},"versionTxt":""};
		$.oViewerMsg = {"flashRequired":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_flash")).replace("_sFlashVersion_", sFlashVersionText)%>" + $.oFlash.versionTxt,"connFailed" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_conn_failed"))%>","enterQuestion" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("qna_please_enter"))%>","questionSubmitted" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("qna_submit_success"))%>","mediaDisconnect" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_disco"))%>","custom":"","noFlashUnicast":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_no_unicast"))%>", "bridgeSwitch" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("audience_number_change"))%>"};
		$.oViewerText = {"tab_evt_resources":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tab_evt_resources"))%>","wmsg_welcome_to_webcast":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("wmsg_welcome_to_webcast"))%>","wmsg_not_started":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("wmsg_not_started"))%>","wmsg_available_when":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("wmsg_available_when"))%>","wmsg_no_slides":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("wmsg_no_slides"))%>","wmsg_loading":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("wmsg_loading"))%>","sts_playing":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_playing"))%>","sts_connecting":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_connecting"))%>","sts_buffering":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_buffering"))%>","sts_failed":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_failed"))%>","sts_paused":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_paused"))%>","sts_live":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_live"))%>","sts_stopped":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_stopped"))%>","alt_play":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_play"))%>","alt_stop":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_stop"))%>","alt_pause":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_pause"))%>","alt_refresh":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_refresh"))%>","alt_volume":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_volume"))%>","alt_mute":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_mute"))%>","alt_unmute":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_unmute"))%>","alt_jump":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_jump"))%>","alt_video":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_video"))%>","alt_audio":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_audio"))%>","alt_flash":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_flash"))%>","alt_windows":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_windows"))%>","alt_captions": "<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("alt_captions"))%>","ios_click_play":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("ios_click_play"))%>","opt_pres_audio_file":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("opt_pres_audio_file"))%>","err_removed":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_removed"))%>","err_dynamic_slides":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_dynamic_slides"))%>","err_to_view_webcast":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_to_view_webcast"))%>","tab_slides":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tab_slides"))%>","sts_playing_multicast":"<%=playAltMulticast%>","player_abr_auto" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("player_abr_auto"))%>","player_abr_low" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("player_abr_low"))%>", "player_abr_high" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("player_abr_high"))%>", "player_abr_standard": "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("player_abr_standard"))%>", "slide_first_slide" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("slide_first_slide"))%>","sts_ready" : "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_ready"))%>","sts_seeking":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("sts_seeking"))%>","alt_fullscreen":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_fullscreen"))%>","alt_fullscreen_exit":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_fullscreen_exit"))%>","alt_settings_container":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_settings_container"))%>","alt_more_settings":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_more_settings"))%>","alt_abr_quality":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_abr_quality"))%>","alt_search_transcript":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("alt_search_transcript"))%>","tra_key_phrases":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tra_key_phrases"))%>","tra_search_warn":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tra_search_warn"))%>","tra_search_results":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tra_search_results"))%>","tra_search_no_results":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tra_search_no_results"))%>","tra_full_tra":"<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("tra_full_tra"))%>"};
		$.oViewerData = {"mutePlayer":mutePlayer,"autoPlayDisable":autoPlayDisable,"bIE11":<%=bIE11%>,"isTypeLiveOrSimlive" : <%=isModeLiveOrPrelive||isSimlive%>,"liveTranscriptEnabled":<%=myEvent.isLiveTranscriptionEnabled()%>,"showLiveCaptionsInViewerByDefault":<%=myEvent.isShowLiveCaptionsInViewerByDefaultEnabled()%>,"downloadTranscriptButtonEnabledInViewer":<%=myEvent.isSpeechToTextDownloadInViewerEnabled()%>,"transcript_viewer_display":<%=myEvent.isShowSpeechToTextFeatureInViewer(SpeechToTextConstants.Feature.TRANSCRIPT)%>,"keyPrases_viewer_display":<%=myEvent.isShowSpeechToTextFeatureInViewer(SpeechToTextConstants.Feature.KEY_PHRASES)%>,"captionsEnabled":<%=myEvent.isSpeechToTextFeatureEnabled(SpeechToTextConstants.Feature.KEY_PHRASES)%>,"captionsVisible":<%=myEvent.isOpenCaptionsInViewerEnabled()%>,"keyPhrasesVisible":<%=myEvent.isSpeechToTextFeatureEnabled(SpeechToTextConstants.Feature.KEY_PHRASES)%>,"transcriptEnabled":<%=myEvent.isSpeechToTextFeatureEnabled(SpeechToTextConstants.Feature.TRANSCRIPT)%>,"full_text":"<%=SpeechToTextConstants.FULL_TEXT_KEY%>","items":"<%=SpeechToTextConstants.ITEMS_KEY%>","transcriptViewerFileUrl":"<%=sTranscriptUrl%>","isStreamLive":false,"livestarttime":0,"sEventGUID" : "<%=sEventGUID%>","sClientid":"<%=sClientid%>","sEventId":"<%=sEventId%>","isAudio":<%=isAudio%>,"isPhoneDefault":<%=isPhoneDefault%>,"ea" :"<%=ea%>","ui" : "<%=ui%>","si" : "<%=si%>","sRatio":4/3,"isOD":<%=isOD%>,"isSimlive":<%=isSimlive%>,"simlivestarttime":<%=myEvent.getSimliveStartTime()%>,"isPreSimlive":<%=isPreSimlive%>,"sMode":"<%=sMode%>","isSlides":<%=isSlides%>,"sContentUrl":"<%=sContentUrl%>","sTemplatePath":"<%=sTemplatePath%>","QAModule" : "<%=QAModule%>","surveyModule" : "<%=surveyModule%>","trackerUrl":"<%=trackerUrl%>","trackerRefresh" : "<%=sTrackerRefresh%>","statusRefresh":"<%=sStatusRefresh%>","sStatusRefreshFactor":"<%=sStatusRefreshFactor%>","user_cnt":"<%=sUser_cnt%>","isIOS":<%=isIOS%>,"isHLS":<%=isHLS%>,"isHDS":<%=isHDS%>,"bUseQTiframe":<%=bUseQTiframe%>,"qa_email_address":"<%=qa_email_address%>","sTitle":"<%=sTitle%>","sDate":sDate,"sSlideType":"<%=sSlideType%>","isPreviewMode":<%=isPreviewMode%>,"playerType":"<%=sPlayerType%>","prevPlayerType":"","isHTML5Player":<%=ishtml5player%>,"regionid":"<%=myEvent.getProperty(EventProps.region_id)%>","ua":navigator.userAgent.toLowerCase(),"codetag":"<%=codetag%>","sPlayerSize":"<%=sPlayerSize%>","isWideScreen":<%=isWideScreen%>,"mp3download":<%=mp3download%>,"mp3_download_url":"<%=mp3_download_url%>","bUserControlSlides":<%=bUserControlSlides%>,"playerwidth":"<%=sVideoWidth%>","playerheight":"<%=sVideoHeight%>","currentstreamid":"<%=sStreamId%>","serverstreamid" : "<%=sStreamId%>","disable_od_seek":<%=disable_od_seek%>,"isWindowsVideo":<%=isWindowsVideo%>,"isWindowsAudio":<%=isWindowsAudio%>,"caption":<%=caption%>,"pageloadtime":<%=lCurrentDate%>,"sh1":"<%=sh1%>","sh0":"<%=sh0%>","simliveIndex":<%=lPlayIndex%>,"userAudioBackup":<%=isUserAudioBackup%>,"audiostreamid":"<%=sAudioStreamId%>","isLiveOverlayEnabled":<%=isLiveOverlayEnabled%>,"refreshRunning":false,"securedContentFolder":"<%=sSecuredContentFolder%>","isAdaptiveBitrate":<%=isAdaptiveBitrateEnabled%>,"primaryStreamId":"<%=sPrimaryStreamId%>",backupStreamId:"<%=sBackupStreamId%>","token":"","isStreamSecured":<%=isStreamSecured%>,"st":"<%=sSessionTypeOnLoad%>","odpausetimeout":<%=lOdpauseTimeout%>,"bInRoomView":<%=bInRoomView%>,"hasSMILFilesForCurrentVersion":<%=hasSMILFilesForCurrentVersion%>,"reportPlayerStat":false,"showQAAnswer" : <%=isQAAnswer%>,"showQA" : <%=displayQA%>, "qaTabTitle":"<%=QATabTitle%>","isViblastPDN": <%=isViblastPDN%>,"fname":"<%=fname%>", "lname" : "<%=lname%>","company":"<%=company%>","isTelAudioAdvanced":<%=isTelAudioAdvanced%>,"bridgePriority":<%=currentBridgePriority%>,"isBridgeCustom" : <%=isBridgeCustom%>, "isListenByPhone" : <%=bPhoneOption%>,"language":"<%=sLanguage%>","tp_key":"<%=sTpKey%>","clicktojoinurl":"<%=sClicktojoinurl%>","dialinurl":"<%=sDialinurl%>","sBridgeType":"<%=selectedBridgeType%>","isWebcam":<%=isWebcam%>,"sPostMsgApiTarget":"<%=sPostMsgApiTarget%>","sPrelive_player_layout":"<%=sPrelive_player_layout%>","tp_special": <%=tp_special%>,"sVTTUrl":"<%=sVTTUrl%>","vtt_caption":<%=vtt_caption%>,"bPlayerOnly":<%=bPlayerOnly%>};
		$.oMulticastData = <%=sMulticastConfJson%>;
		$.oFlashABRData = null;
		$.oVideoInfo = {"isEnableFastyCookie":<%=isEnableFastyCookie%>,"status":"Connecting","currentVolume":50,"muted":false,"currentPosition":0,"totalDuration":0,"sCurrentSlide":"<%=sCurrentSlide%>","sCurrentHeadShot":"<%=sCurrentHeadShot%>","sCurrentSurvey":"<%=sCurrentSurvey%>","sCurrentSurveyResult":"<%=sCurrentSurveyResult%>","connType":"rtmp://","odSliderOn":false,"broadcasting":"<%=sBroadcasting%>","playerMsgType":"","odSlider":{"status":0,"pos":0},"sCurrentSecondaryMedia":"","initJump":"<%=tp_jump%>","sCurrentLayout":"<%=sCurrentLayout%>"};
		$.oMulticast = {"isHiveMulticast":<%=isHiveMulticast%>,"isKontikiMulticast":<%=isKontikiMulticast%>,"isKollectiveMulticast":<%=isKollectiveMulticast%>,"isHiveFallback":<%=isHiveFallback%>,"isRampMulticast":<%=isRampMulticast%>,"isRampFallback":<%=myEvent.isRampMulticastFallback()%>,"isRampCache":<%=isRampCache%>,"useMulticastFallback":true,"multicastType":"<%=sMulticastType%>","isFlashMulticast":<%=isFlashMulticast%>,"isFlashmulticastfallback":<%=isFlashmulticastfallback%>,"isFlashMulticastRollBackToBackup":"<%=sFlashMulticastRollToBackupType%>","isWindowsmulticastfallback":<%=isWindowsmulticastfallback%>,"isRolledBackToBackupUnicast":false, "enableHiveJS" : <%=enableHiveJS%>, "kollectivePlugin" : undefined,"isKollectiveFallback":<%=myEvent.isKollectiveMulticastFallback()%>,"kollectiveToken" : "<%=StringEscapeUtils.escapeEcmaScript(kollective_contentToken)%>"};
		$.oBranding = {"sBackground_color":"<%=sBackground_color%>","sBranding_highlight":"<%=sBranding_highlight%>"};
		$.viewerSlide.oSlides = <%=sSlides%>;
		$.viewerUploads.oUpoloadsData =<%=sViewerUploads%>;
		$.viewerAction.arrCalls= <%=ODEvents%>;
		$.oSecondaryMedia= <%=oSecondaryMedia%>;
		<%if(bPhoneOption && !Constants.EMPTY.equals(audienceBridge)){%>
		$.oAudienceBridge = <%=audienceBridge%>;
		<%}%>
		<%if(bShowAddNumbers && !bShow_ia_aud_toll){%>
			$(".ia_toll_number").hide();
		<%}%>
		<%if(bShowAddNumbers && !bShow_ia_aud_tollfree){%>
			$(".ia_tollfree_number").hide();
		<%}%>
		<%if(!(isIOS && userAgent.indexOf("crios")!=-1)){ %>
			history.forward();
		<%}%>
		if (navigator.appName == 'Microsoft Internet Explorer'){
			blocktxt = "<%=StringEscapeUtils.escapeEcmaScript(hmAllPlayerText.get("err_browser_ver"))%>";
		}
			
		if(blocktxt==""){
			doloadViewer();		
		}else{
			$("#overlay_content").height($(window).height());
			$("#overlay_body").height($(window).height());
			blocktxt = blocktxt + "<form><input type=\"button\" value=\"Continue\" id=\"viewerErrorBtn\" onclick=\"doloadViewer();$('#alertBlock').hide()\" /></form>";
			$("#alertBlock").html(blocktxt)
			$("#alertBlock").show();
		}
		
		$("#webcastInfoDate").text(sDate);
		
		// accessbility functions
		try{
			// put focus on popup
			if($.oViewerData.sMode === "prelive"){
			    setTimeout(function(){
			        $('#overlay_content .ui-dialog-title').focus()
			    }, 3000);
				
				ariaHidden('#Logos', 'true');
				ariaHidden('#viewer', 'true');
				ariaHidden('#viewer_footer', 'true');
				ariaHidden('#passThruForm', 'true');
				ariaHidden('#viewer_banner', 'true');
				ariaHidden('#viewer_content', 'true');
				ariaHidden('#overlay_content', 'false');
				ariaHidden('#overlay_body', 'false');
			}else{
			    setTimeout(function(){
			        //parent.$('.vjs-play-control').focus();
			    }, 3000);	
			}
			
			//On last tab go back to first tab in this popup window
			tabNext($('#lobby_close'), $('#lobby .ui-dialog-title'));
			
			//tab to correct place since there are duplicate same numbers in background
			tabNext($('#lobbyTitleModal'), $('#lobbyDate'));
			tabNext($('#lobbyDate'), $('#lobby_close'));
			
			// tab next helper function
			function tabNext(current, next){
				current.on('keydown', function(e){
					if (e.keyCode == 9) {
					   e.preventDefault(); 
					   next.focus();
					}		
				});
			}
			
			// on enter close overlay
			$("#lobby_close").on('keyup', function(event){
			    if(event.keyCode == 13){
			    	try{
			     		parent.$('.vjs-play-control').focus();
			     		 $('#lobby_close').click();
			    	}catch(err){
			    		// no video player
			    	}
			    }
			});
			
			// Pressing esc will Close Popup for accessibility
			$(document).bind('keydown', function(event){ 
			    if (event.which == 27) {
			    	parent.$('.vjs-play-control').focus();
			        $('#lobby_close').click();
			    }
			});
			
			// Enter button access for help player button for accessibility
			$("#help").keyup(function(event){
			    if(event.keyCode == 13){
			        $("#help").click();
			    }
			});

			// Enter button access for close player button for accessibility
			$("#close").keyup(function(event){
			    if(event.keyCode == 13){
			        $("#close").click();
			    }
			});
			
			// add aria-hidden values
			function ariaHidden(elem, val){
				$(elem).attr('aria-hidden',val);
			}

			$('#lobby_close').on('click', function(){
				$('#headshot').focus(); 
				ariaHidden('#Logos', 'false');
				ariaHidden('#viewer', 'false');
				ariaHidden('#viewer_footer', 'false');
				ariaHidden('#passThruForm', 'false');
				ariaHidden('#viewer_banner', 'false');		
				ariaHidden('#viewer_content', 'false')
				ariaHidden('#overlay_content', 'true');;
				ariaHidden('#overlay_body', 'true');
			});
			
		}catch(err){
			console.log('accessbility functions failed');
		}
		function doloadViewer(){
			document.trackerform.submit();
			console.log(`doloadviewer: Ready state: ${document.readyState}`);
			if (document.readyState === "complete") {
				loadViewer();  // see viewerLoader.js
			} else {
				document.addEventListener("readystatechange", (e) => {
					console.log(e.target.readyState);
					if (e.target.readyState === "complete") {
						loadViewer();
					}
				});
			}
		}
		<% if (isOD && !isSimlive && ishtml5player){ %>
		var init_jump = "<%=tp_jump%>";
		if (init_jump!="") {
			setTimeout(function() {
				console.log(`calling tpjump`);
				tpjump();//Fast foward into the stream if tp_jump param is passed. See viewerLoader.js
			},300);
		}
		<%}%>
		
		if($.oViewerData.transcriptEnabled && !$.oViewerData.isSimlive && $.oViewerData.isOD) {
			if($.oViewerData.downloadTranscriptButtonEnabledInViewer || $.oViewerData.transcript_viewer_display || $.oViewerData.keyPrases_viewer_display || $.oViewerData.captionsVisible) {
				startTranscript();	
			}	
		}
		
		<% if(userAgent.contains("chrome/87")){ %>
		$("#survey_frame,#surveyresult_frame").on('load', function() {
		 	if($(this).attr("src").indexOf("index_viewer.php")>0){
		 	 	  setTimeout(() => {
		 	 	  try{
			      	$(this).height($(this).height() - 1);
			      }catch(err){}
			    }, 200);
		  	}
		});
		<%}%>
		
		// add class for extra padding on banners if there is a banner background color
		if("transparent" !== "<%=sBannerBackground_color%>"){
		    $('#viewer_banner').addClass('extraBannerPadding');
		}
	});	
	
	</script>
	<form name="trackerform" aria-hidden="true" id="trackerform"
		target="trackerframe" method="post"
		action="<%=trackerUrl%>?ei=<%=iEventId%>&ui=<%=ui%>&si=<%=si%>&iframe=1">
		<input type="hidden" name="ea" value="<%=ea%>" /> <input
			type="hidden" name="st" value="" /> <input type="hidden" name="ip"
			value="<%=StringTools.n2s(request.getRemoteAddr())%>" />
	</form>
	<iframe aria-hidden="true" style="position:absolute;left:0px;top:0px;width:0px;height:1px;" id="trackerframe" name="trackerframe" width="0" height="1" frameborder="0" scrolling="no"></iframe>
  	<img style="position:absolute;left:0px;top:0px;width:0px;height:1px;display:none" id="reporter" src="images/blank.gif?ei=<%=iEventId%>&ui=<%=ui%>&si=<%=si%>&t=start" hspace="0" vspace="0" border="0"/>
	<%if ("html5".equals(sSlideType)){%>
    	<iframe id="html5cacheframe" aria-hidden="true" name="html5cacheframe" width="0" height="1" frameborder="0" scrolling="no"></iframe>
  	<%}%>
   	<div id="iaNumbers"  style="display:none">
    	<div>
            <ul class="ui-widget ui-helper-clearfix" id="iaexit">
            <li title="<%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("close"))%>" class="ui-state-default ui-corner-all"> <a href="#" onclick="return false"><span class="ui-icon ui-icon-closethick" id="ia_close"></span></a> </li>
            </ul>
        </div>
        
		<div class="clear" id="bridgeList" style="display:none;">
		<span class="ia_country"><strong><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_country"))%></strong></span> <span class="ia_toll_number"><strong><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_toll_number"))%></strong></span> <span class="ia_tollfree_number"><strong><%=StringEscapeUtils.escapeHtml4(hmAllPlayerText.get("opt_toll_free"))%></strong></span>
      	</div>				
		<div id="audNumbers"></div>		
	</div>
  
   <%if (!Constants.EMPTY.equals(sAnalytics_code)) {
			out.println(sAnalytics_code);
	}%>
</body>
</html>

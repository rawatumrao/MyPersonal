<%@ page import="java.util.*"%>
<%@ page import="tcorej.*"%>
<%@ page import="tcorej.bean.*"%>

<%@ include file="/include/globalinclude.jsp"%>

<%

String jqueryVersion = Constants.JQUERY_2_2_4;

//configuration
Configurator conf = Configurator.getInstance(Constants.ConfigFile.GLOBAL);

String sCodeTag = conf.get("codetag");
// What's it called this week, Bob?
String sProductTitle = conf.get("dlitetitle");

// generate pfo and ufo
PFO pfo = new PFO(request);
UFO ufo = new UFO(request);

Logger logger = Logger.getInstance();

String sQueryString = Constants.EMPTY;
try {
	pfo.sMainNavType = "library";
	pfo.secure();
	pfo.setTitle("Folder Event Search");

	PageTools.cachePutPageFrag(pfo.sCacheID, pfo);
	PageTools.cachePutUserFrag(ufo.sCacheID, ufo);

	sQueryString = ufo.toQueryString();
%>

<jsp:include page="/admin/headertop.jsp">
    <jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
    <jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
    <jsp:param name="jqueryVersion" value="<%=jqueryVersion%>" />
</jsp:include>

<link href="/admin/css/jquery.replacefolders.css" rel="stylesheet" type="text/css" media="screen"/>
<%
AdminFolder adminfolder = new AdminFolder();
AdminUser au = AdminUser.getInstance(ufo.sUserID);
String userId = au.sUserID;
String userFolderId = au.sRootFolder;
String sSessionID = ufo.sSessionID;

String folderIdToExpandTo = au.sHomeFolder;
String action = request.getParameter("action");
boolean isLoadData = StringTools.n2b(request.getParameter("loadData"));
String sEventId = StringTools.n2s(request.getParameter("ei"));
boolean isPortalLinkedEvents = StringTools.n2b(request.getParameter("isportallink"));
String sRootFolder = StringTools.n2s(request.getParameter("fi"));
String temp = Constants.EMPTY;
if(isPortalLinkedEvents){
	temp = adminfolder.getInitialFolderListToDisplay(userId,sRootFolder,sRootFolder,
			"&nbsp;&nbsp;<img src=\"/admin/images/folder13x15.png\">&nbsp;&nbsp;",true,true);
	
}else{
	temp = adminfolder.getInitialFolderListToDisplay(userId,userFolderId,folderIdToExpandTo,
			"&nbsp;&nbsp;<img src=\"/admin/images/folder13x15.png\">&nbsp;&nbsp;",true,false);	
}



HashMap<Integer,FolderDetailsBean>  hmfolderPathList = new HashMap<Integer,FolderDetailsBean>();
if(sEventId!=null && !"".equalsIgnoreCase(sEventId))
{
	hmfolderPathList = adminfolder.getEventFolderList(sEventId);
	//temp = adminfolder.getInitialFolderListToDisplay(userId,userFolderId,folderIdToExpandTo,
			//"&nbsp;&nbsp;<img src=\"/admin/images/folder13x15.png\">&nbsp;&nbsp;",true,hmfolderPathList,sEventId);
}

//out.println("Load Data = " + isLoadData + "\nInitial List = " + temp);
%>
</head>
<body style="background-color:#fff">
<div>
    <!-- Dynamic Search Box in top-left corner -->
    <div style="margin-bottom:10px; padding:10px; border-bottom:1px solid #ddd;">
        <input type="text" id="folderSearchInput" autocomplete="off" placeholder="Search" readonly onfocus="this.removeAttribute('readonly');" 
               style="width:250px; padding:8px; border:1px solid #ccc; border-radius:4px; font-size:14px;" />
    </div>
	<div id ="folderTree"></div>
	<div class="divRow" style="clear:both; position: fixed; bottom: 0;" >
		<div class="centerThis">
			<a class="buttonSmall" id="cancelFolderSelect" href="#">Cancel</a> &nbsp;
            <a class="button buttonSave" id="useThisFolder" href="#">Select Events and Folders</a> 
		
			
		</div>
	</div>
</div>
<div id="reportAlertDialog" title="Alert"  style="display:none; clear:both; overflow:hidden; width:450px!important" >
	<div class="reportErrorMessageContainer" style="margin: 0 auto;text-align:left;padding:20px;">
            <div class="reportErrorMessageIcon" style="width:90px;float:left;"> <img src="/admin/images/icon_nosign.png" width="50" height="50" /></div>
		<div class="reportErrorMessageContent" style="float:left;width:72%;">
			<div id="reportErrorHeader" style="font-size:35px;color:#666;">This action is not permitted.</div>
			<br/>
			<div id="reportErrorText" style="font-size:18px;"></div>
		</div>
            <div class="clear"></div>
     </div>
</div>

<jsp:include page="/admin/footertop.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
	<jsp:param name="jqueryVersion" value="<%=jqueryVersion%>" />
	<jsp:param name="hidecopyright" value="1"/>
	<jsp:param name="hideconfidentiality" value="1"/>
</jsp:include>

<script type="text/javascript" src="/js/jquery/jstree/jstree.js?<%=sCodeTag%>"></script>
<script type="text/javascript" src="/js/jquery/jstree/jstree.types.js?<%=sCodeTag%>"></script>
<script type="text/javascript" src="/js/jquery/jstree/jstree.search.js?<%=sCodeTag%>"></script>
<script type="text/javascript" src="/js/Map.js"></script>

<style>
.errorMessageContainer {padding:10px}
.errorMessageIcon {float:left; width:65px}
.errorMessageContent {float:left; width:200px;}
.errorMessageContent span {font-size:18px; color:#666; font-weight:bold; padding-left:20px;width:325px; display:inline-block}
#loadingDialog, #alertDialog {overflow:hidden; width:475px!important; height:65px;}
.ui-dialog {width:500px!important}

.jstree-default .jstree-clicked {
    background: transparent;
    border-radius: 2px;
    box-shadow: none;
    color: inherit;
}

/* Highlight search results */
    .jstree-search {
        font-style: normal !important;
        color: inherit !important;
        font-weight: normal !important;
    }

/* Search input styling */
#folderSearchInput:focus {
    outline: none;
    border-color: #4CAF50;
    box-shadow: 0 0 5px rgba(76, 175, 80, 0.3);
}

</style>
<script type="text/javascript">

$(document).ready(function(){
    $.initdialog(); 
    var stat =[];
    var eventId = '<%=sEventId%>';
    var folderselected = false;
    stat =  <%=temp%>;
    var invalidfolder = "<%=Constants.TALKPOINT_ROOT_FOLDERID%>";
    var action = "<%=action%>";
    var selectedFolder = "<%=userFolderId%>";
    var selectedFolderName = "";
    <% if (!folderIdToExpandTo.equals("")){ %>
	 selectedFolder = "<%=folderIdToExpandTo%>";
    <%}%>
	var ui = "<%=userId%>";
        var si = "<%=sSessionID%>";
	var closeFunction = false;
	var selectedNodeMap = new Map();
	var openNodeArray = [stat.id];
	if(eventId!='')
	{
		openNodeArray = [];
<%
		for(int i=0; i<hmfolderPathList.size(); i++)
		{
			FolderDetailsBean folderDetBean = hmfolderPathList.get(i);			
%>
			openNodeArray[<%=i%>] = '<%=folderDetBean.getFolderid()%>';
				//}
<%
		}
%>
		selectedFolder = eventId;
	}
	else
	{
		selectedFolder = '' ; // by default do not select any folder/event
	} 
	var changeVar = false;
	var arrOpenFolder = new Array();
	var isRootSelected = false;
	var alertDialogOpts = {
			position: "center",
			resizable: false,
			draggable: false,
			autoOpen: false,
			modal: true,
			dialogClass : 'notitle', 
			position : {
			    my : "center",
			    at : "center",
			    of : window
			},			
			buttons: {
				Ok: function() {
					$(this).dialog('close');
				}
			},
			height: 175
/* 			dialogClass : 'notitle',
			overlay: {
				backgroundColor: '#FFFFFF',
				opacity: 1.0
			},
			buttons: {
				Ok: function() {
					$(this).dialog('close');
				}
			},
			width: "65%",
			height: "75px",
			position : {
			    my : "center",
			    at : "center",
			    of : window
			},
			buttons: [
			    {
			      text: "Close",
			      icons: {
			        primary: "ui-icon-heart"
			      },
			      click: function() {
			        $( this ).dialog( "close" );
			      }
			    }
			  ]		 */	
	};
	
	$("#reportAlertDialog").dialog(alertDialogOpts);
	
	    $("#folderTree").on("activate_node.jstree",function(e,data){
 				if (data.node.id ==  invalidfolder) {
	                  data.instance.deselect_node(data.node); 
	                  $("#reportAlertDialog").dialog("open");
	                  $("#reportErrorHeader").text("Attention!");
	                  $("#reportErrorText").text("Reports cannot be run from this folder");
	       
	                 // $("#alertDialog").dialog({width:'50%',height:'50%'});
	            	//  $.alert("Reports cannot be run from this folder.","Reports cannot be run from this folder.","icon_nosign.png");
	            } 
	    }).on("ready.jstree", function(e, data){
		   for(var i=0,len = openNodeArray.length;i<len;i++){
		       data.instance.open_node(openNodeArray[i]);
		   }
		   
	    }).jstree({
			'core' : {
			    'data' : function(node,cb){
					if(node.id === '#'){
					    return cb([stat]);
					}else{
					   $.ajax({
					      'url' : 'folder_functions.jsp',
					      "type": 'POST',
				          "dataType": 'JSON',
					      'data' : { 
					            'ui' : ui,
					            'si' : si,
					            'parentFolderId' : node.id,
					        	'action' : 'getFolderAndEvent',
					        	'selected' : 'false',
					        	'linksegment' : '<%=isPortalLinkedEvents%>'
					      },
					      "success" : function(nodes){
							//	console.log(nodes);
					      } 
					   }).done(function(d){
					       d = d ? d:[];
						   cb(d); 
					   });
					}
			    },
				"themes":{
				    "url":"/js/jquery/jstree/themes/default/style.css",
				    "dots":false
				},
				'check_callback' : true,
				'animation':50
			},
			'types' : {
 			  //need to define all types or changes type to 'default'
			    //only root / suproot can be children of #(jstree root)
			    '#':{
					'valid_children':['root','suproot']
			    },
			    //only root can be children of suproot
				"suproot":{
				 	'valid_children':['root']
				 },
				"root":{
				    
				 },
				 "event":{
				     icon:"/admin/images/eventIcon.gif"
				 },
				"default":{}  
			},
			'checkbox' :{},
			'search' : {
                "case_sensitive": false,
                "show_only_matches": true,
                "show_only_matches_children": true,
                "search_leaves_only": false
            },
			'plugins' : ['types','checkbox','search']
	    });  
	
	// Dynamic search functionality - searches as you type
    var searchTimeout;
    $("#folderSearchInput").on("input keyup", function() {
        var searchString = $(this).val().trim();
	        
        // Clear previous timeout
        clearTimeout(searchTimeout);
	        
        // Set a small delay to avoid too many searches while typing
        searchTimeout = setTimeout(function() {
            if(searchString.length > 0) {
                // Perform search with prefix matching
                $("#folderTree").jstree(true).search(searchString);
            } else {
                // Clear search if input is empty
                $("#folderTree").jstree(true).clear_search();
            }
        }, 300); // 300ms delay
    });

    // Clear search when ESC key is pressed
    $("#folderSearchInput").on("keydown", function(e) {
        if (e.which === 27) { // ESC key
            $(this).val('');
            $("#folderTree").jstree(true).clear_search();
        }
    });

    var getSelNodes = function() {
		getSelectedNodes();
	}
    $("#useThisFolder").click(getSelNodes);

	$("#cancelFolderSelect").click(function(){
		parent.hideIframe();
	});

	function getSelectedNodes()
	{	
		var selectedIDs = $('#folderTree').jstree("get_checked",null,true);

		var folderList = [];
		var eventList = [];
		loadData = false;
		
		for(var i=0,len = selectedIDs.length;i<len;i++){
		    if(selectedIDs[i] == invalidfolder){
				continue;
		    }
		    
			if(selectedIDs[i].length > 20)
			{
				folderList.push(selectedIDs[i]);
			}
			else
			{
				eventList.push(selectedIDs[i]);
			}
		}
		
		var selectedFolders = folderList.join("|");
		var selectedEvents = eventList.join("|");

		var url = 'proc_folderEventTree.jsp';
		var dataString = 'folderList='+selectedFolders+'&eventList='+selectedEvents;
		//For portal events when loading list dont pass folders as its loading all events 
		<%if(isPortalLinkedEvents){%>
			dataString = 'folderList=&eventList='+selectedEvents;
		<%}%>
		var load = loadFolderData('POST',url,dataString);
	}
	
	function loadFolderData(methodType,urlString,dataString)
	{		
		$.ajax({ type: methodType,
            url: urlString ,
            data: dataString,
            dataType: "json",
            success: getResult,
            error: function(a,b,c)
            {
            	//alert(a + " - " + b + " - " + c);
            }
        });
	}

	function getResult(jsonResult)
	{
		jsonResult = jsonResult[0];
        if (!jsonResult.success) {
        	 for(var i = 0; i < jsonResult.errors.length; i++)
             {
                 var curError = jsonResult.errors[i];
                 alert(curError.element + " - " + curError.message);	
             }
             return;
        }
        else
        {
			var selectedNodes = new Array();
			var selectedEvents = jsonResult.sel_events.EventTableBean;
			var selectedFolders = jsonResult.sel_folders.FolderDetailsBean;

			if(selectedEvents!=undefined)
			{
				for(var i=0; i<selectedEvents.length; i++)
				{
					selectedNodes.push(selectedEvents[i].EventId);
				}
			}

			if(selectedFolders!=undefined)
			{
				for(var i=0; i<selectedFolders.length; i++)
				{
					selectedNodes.push(selectedFolders[i].Folderid);
				}
			}
			
    		parent.selectedFolderEvent(selectedNodes);
    		//parent.selectedFolderEvent();
    		$("#loadingDialog").dialog("close");
    		parent.hideIframe();
        }
	}

});
</script>
<%
}catch(Exception e){
	//logger.log(logger.CRIT, "jsp", e.getMessage(), "blah");
	//out.print(ErrorHandler.getStackTrace(e));
	response.sendRedirect(ErrorHandler.handle(e, request));
}
%>
<jsp:include page="/admin/footerbottom.jsp">
    <jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
    <jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>

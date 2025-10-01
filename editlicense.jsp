<%@ page import="java.util.*"%>
<%@ page import="org.apache.commons.text.*"%>
<%@ page import="tcorej.adminlicense.*"%>
<%@ page import="tcorej.*"%>

<%@ include file="/include/globalinclude.jsp"%>


<%
//configuration
Configurator conf = Configurator.getInstance(Constants.ConfigFile.GLOBAL);
boolean analyticsActive = StringTools.n2b(conf.get(Constants.ANALYTICS_ACTIVE_CONFIG));

// generate pfo and ufo
PFO pfo = new PFO(request);
UFO ufo = new UFO(request);

// logging
Logger logger = Logger.getInstance(Constants.LogFile.ADMIN_USER);

// Profile page header title
String sPageTitle = "Manage License";
String sQueryString = Constants.EMPTY;

try {
	// check permissions
	AdminUser admin = AdminUser.getInstance(ufo.sUserID);
	if (admin == null) {
		throw new Exception(Constants.ExceptionTags.EGENERALEXCEPTION.display_code());
	}
	
	String sLicenseId = StringTools.n2s(request.getParameter(Constants.RQLICENSEID));
	boolean isCreate = StringTools.isNullOrEmpty(sLicenseId);
	AdminLicense license = null;
	
	if (isCreate) {
		sPageTitle = "Create License";
		sLicenseId = GUID.getInstance().getID();
	} else {
		license = AdminLicense.get(sLicenseId);
		
		if (license == null) {
			throw new Exception(Constants.ExceptionTags.EGENERALEXCEPTION.display_code());
		}
	}
	
	if (!admin.can(Perms.User.MANAGELICENSES) && (isCreate || !admin.sUserID.equals(license.getTeamManagerAdminId()))) {
		//Need manage licenses permission or be the client team manager and editing/viewing your own license.
		throw new Exception(Constants.ExceptionTags.ENOUSERAUTH.display_code());
	}
	
	boolean hasManageLicensePerm = admin.can(Perms.User.MANAGELICENSES);
	
	pfo.sMainNavType = "nohighlight";
	pfo.useAdminNavi();
	pfo.sSubNavType = "managelicenses";
	pfo.setTitle(sPageTitle);

	sQueryString = Constants.RQUSERID + "=" + ufo.sUserID + "&" + Constants.RQSESSIONID + "=" + ufo.sSessionID;

	PageTools.cachePutPageFrag(pfo.sCacheID, pfo);
	PageTools.cachePutUserFrag(ufo.sCacheID, ufo);
	String userId = admin.sUserID;
%>
<jsp:include page="/admin/headertop.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>
<link href="/admin/css/jquery.datepick.css" rel="stylesheet" type="text/css" media="screen"/>
<link href="/admin/css/jquery.replacefolders.css" rel="stylesheet" type="text/css" media="screen"/>
<link href="/admin/css/font-awesome.min.css" rel="stylesheet">
<style>
  .mainContainer{
    font-family: Roboto, Arial, Helvetica, sans-serif;
    font-weight: 300;
    padding: 0;
    margin: 0 auto;
    box-sizing: border-box;
    width: 1053px;
  }

  .border{
    border: 1px #ccc solid;
  }

  .flexbox{
    display: flex;
  }

  .flexboxColumn{
    display: flex;
    flex-direction: column;
  }

  .flexEnd{
    align-items: flex-end;
  }
  
  .flexCenter{
      align-items: center;
  }
  
  .flexGrow{
  	flex-grow: 1;
  }

  .flexboxColumnLeft{
    display: flex;
    flex-direction: column;
    flex-basis: 700px;
  }

  .flexboxCenter{
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .myTeamUsernameTd, .myTeamAssignedPackagesTd, .myTeamActionsTd, .myTeamUserCreateTd, .myTeamUserLastLoginTd{
    font-weight: bold;
    font-size: .9em;
  }

  .marginBtm5px{
    margin-bottom: 5px !important;
  }

  .marginBtm8px{
    margin-bottom: 8px !important;
  }
  
  .marginBtm15px{
  	margin-bottom: 15px !important;
  }

  .paddingTopBtm2px{
    padding: 2px 0px;
  }

  .marginRight20px{
    margin-right: 20px;
  }
  
  .marginRight15px{
  	margin-right: 15px;
  }
  
  .marginRight10px{
  	margin-right: 15px;
  }
  
  .marginLeft10px{
  	margin-left: 10px;
  }
  
  .marginLeftnRight8px{
  	margin: 0 8px;
  }
  
  button:hover{
    background-color: #333;
  }
  
  .biggerFont{
    font-size: 14px;
    font-weight: 500;
    color: #666;
  }
  
  .cursor{
  	cursor: pointer;
  }
  
  .highlight:hover{
  	background-color: #00aeec;
  	color: #fff;
  }
  
  .evenBgColor{
      background-color: #f1f3f4;
  }
  
  .displayNone{
  	display: none;
  }

  /***********************
       License Details
  ************************/
  .licenseDetails{
    margin: 20px 0;
  }

  .licenseDetailsHdr{
   	margin-bottom: 15px;
  }

  .licenseNameDiv, .licenseFolderDiv{
    margin-bottom: 10px;
  }

  .licenseNameSpn{
    margin-right: 10px;
  }

  .folderSpn{
    margin-right: 139px;
  }

  .clientTeamManagerSpn{
    margin-right: 15px;
  }

  .changeFolderBtn, .selectTeamManagerBtn{
    width: 102px;
  }
  
  .changeFolderBtn{
  	margin-right: 8px !important;
  }

  /******************************
    My Team N Features Packages
  *******************************/
  .assignedPackagesTd{
  	width: 350px;
  }
  
  .myTeams, .featurePackages{
    width: 90%;
    padding: 20px;
    margin-bottom: 20px;
  }

  .myTeamTbl, .featurePackageSec{
    width: 100%;
    margin-bottom: 15px;
    border-collapse: collapse;
  }
  
  .myTeamRowTitlesTr{
    border-bottom: #d0d0d0 dotted 1px;
    height: 35px;
  }

  .myTeamActionsTd{
    text-align: center;
  }
  
  .myTeamEditBtnTd{
    text-align: right;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .myTeamUserCreateTd, .myTeamUserLastLoginTd, .CreatedDateTd, .LastLoginDateTd {
    padding: 1px 5px;
    width: 75px;
  }
  
  .myTeamUser{
    height: 35px;
  }

  .deleteUser{
    width: 20px;
  }

  .deletePackage{
    width: 27px;
  }
 
  .packageActionsDiv{
  	text-align: right;
  	padding-right: 10px;
  }
  
  .featurePackageViewBtn{
  	margin-right: 8px !important;
  	vertical-align: bottom;
  }
  
  .circleBtns{
    padding: 11.5px;
    border: 0px;
    border-radius: 20px;
    background-size: 13px 13px;
    height: 19px;
    cursor: pointer;  
    margin: 1px 2px;
  }

  .permissionList {
  	display: flex;
  	flex-direction: column;
  	padding-left: 50px;
  }
  
  .permission{
  	margin: 5px 0;
  }
  
  .usernameTd, .assignedPackagesTd, .myTeamEditBtnTd, .permissionPackageDiv , .packageActionsDiv{
  	border-bottom: none !important
  }
  
  .usernameTd {
  	padding-left: 10px;
  }
  
  .myTeamEditBtnTd {
  	padding-right: 10px;
  }
  
  .packageNameDiv{
  	display: flex;
  	align-items: center;
  	flex-grow: 1;
  	height: 35px;
  	cursor: pointer;
  }
  
  .permissionPackageDiv{
  	display: flex;
  	align-items: center;
  }
  
  .arrowOpened, .arrowClosed{
    width: 10px;
    height: 16px;	
  }
  
  .fa-star{
  	color: #f3ac00;
  	margin-right: 10px; 
  }

  /***********************
        Save N Cancel
  ************************/
  .savecancelbtn_div{
  	margin: 15px 0px;
  }
  .cancelBtn{
    margin-right: 10px !important;
  }
</style>
<jsp:include page="/admin/headerbottom.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>
<div class="pageContent">
	<h1 id="pagetitle"><%=sPageTitle%> </h1>
	<div id="mainContainer" class="mainContainer">

		<section id="mainFlexboxContainer" class="flexbox">
			<div id="leftContainer" class="flexboxColumnLeft">
				<div id="licenseDetails" class="licenseDetails">
					<h2 id="licenseDetailsHdr" class="licenseDetailsHdr"> License Details </h2>
				
					<div id="licenseDetailsInfoDiv" class="flexboxColumn">
						<div class="flexbox flexCenter marginBtm8px">
							<span id="licenseLabelNameSpn" class="licenseNameSpn marginBtm8px biggerFont">License Name: </span>
							<input id="licenseNameTxt" class="marginBtm5px" type="text" <%=(hasManageLicensePerm ? Constants.EMPTY : "disabled")%>/>
						</div>
						<div class="flexbox flexCenter marginBtm8px">
							<span id="folderLabelSpn" class="marginBtm8px marginRight10px biggerFont">Folder: </span>
							<span id="folderSpn" class="marginBtm8px marginRight15px">(Select Folder)</span>
							<% if (hasManageLicensePerm) { %>
								<button id="changeFolderBtn" class="button changeFolderBtn marginBtm5px" type="button" name="changeFolderBtn">Change Folder »</button>
							<% } %>
							<span id="clientLabelSpn" class="marginBtm8px marginRight10px biggerFont">Client: </span>
							<span id="clientSpn" class="marginBtm8px marginRight15px"></span>
							<span id="pgiClientIdLabelSpn" class="marginBtm8px marginRight10px biggerFont" style="display:none;">Client ID: </span>
							<input id="pgiClientIdTxt" class="marginBtm5px" type="hidden" <%=(hasManageLicensePerm ? Constants.EMPTY : "disabled")%>/>
						</div>
						<div id="clientTeamManagerDiv" class="flexbox flexCenter">
							<span id="clientTeamManagerLabelSpn" class="clientTeamManagerSpn marginBtm8px biggerFont">Client Team Manager: </span>
							<span id="clientTeamManagerSpn" class="clientTeamManagerSpn marginBtm8px"></span>
							<% if (hasManageLicensePerm) { %>
								<button id="selectTeamManagerBtn" class="button selectTeamManagerBtn marginBtm5px" type="button" name="selectTeamManagerBtn">Select Admin »</button>
							<% } %>
						</div>
					</div>
				</div>
	
				<div id="myTeams" class="myTeams border">
					<h2 id="myTeamHeader"> My Team &nbsp;<img src="/admin/images/help.png" class="helpIcon" title="Help with My Team" alt="Help with My Team" name="help" onClick="$.help('my_team','Help with My Team');"/>&nbsp;</h2>
					
					<table id="myTeamTbl" class="myTeamTbl">
						<thead>
							<tr class="myTeamRowTitlesTr">
								<th class="myTeamUsernameTd">Username</th>
								<th class="myTeamUserCreateTd">Created</th>
								<th class="myTeamUserLastLoginTd">Last Login</th>
								<th class="myTeamAssignedPackagesTd">Assigned Packages</th>
								<th class="myTeamActionsTd" class="myTeamActionsTd">Actions</th>
							</tr>
						</thead>
					</table>
					
					<button id="newAdminBtn" class="greenBtn" type="button" name="newAdmin">+ Create New Administrator</button>
					<% if (hasManageLicensePerm) { %>
						<button id="addExistingAdminBtn" class="greenBtn" type="button" name="addExistingAdmin">+ Add Existing Administrator Account</button>
					<% } %>
				</div>
				
				<div id="featurePackages" class="featurePackages border">
					<h2 id="featurePackageHdr" class="marginBtm15px"> My Feature Packages &nbsp;<img src="/admin/images/help.png" class="helpIcon" title="Help with My Feature Packages" alt="Help with My Feature Packages" name="help" onClick="$.help('my_feature_packages','Help with My Feature Packages');"/>&nbsp;</h2>
					
					<section id="featurePackageSec" class="featurePackageSec flexboxColumn"></section>
					<% if (hasManageLicensePerm) { %>
						<button id="addPackageBtn" class="greenBtn" type="button" name="addPackage">+ Add Package to this License</button>
					<% } %>
				</div>
			</div>
			<div id="rightContainer" style="height: 100%;">
				<jsp:include page="/admin/management/licenselimits_jspfrag.jsp">
					<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
					<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
					<jsp:param name="li" value="<%=sLicenseId%>"/>
					<jsp:param name="editable" value="true"/>
				</jsp:include>
			</div>
		</section>
	<% if (hasManageLicensePerm) { %>
		<section id="savecancelbtn_div" class="flexboxCenter savecancelbtn_div">
			<input id="cancelBtn" class="buttonSmall cancelBtn" type="button" value="« Return to License List" class="buttonSmall">
			<input id="saveBtn"  class="buttonLarge" type="button" value="Save Changes »">
		</section>
	<% } %>
	</div>
</div>
<jsp:include page="/admin/footertop.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>
<script type="text/javascript" src="/js/basicUtils.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.datepick.min.js"></script>
<script type="text/javascript" src="/js/analytics.js"></script>
	<script type="text/javascript">
		if (<%=analyticsActive%> === true) {
		    //analyticsExclude(["param_eventCostCenter"]);
			analyticsInit('<%=userId%>', null);	
		}
		//Moment format string that matches default format for datepicker plugin
		var DATEPICKER_MOMENT_FORMAT = 'MM/DD/YYYY';
		
		var TIMEZONE_ID = '<%=StringEscapeUtils.escapeEcmaScript(admin.sTimeZoneName)%>';
		var isCreate = <%=isCreate%>;
		
		$(document).ready(function() {
			 $.initdialog();
			 
			//programmatically disable autocomplete on form fields
			$('#pageWrapper').find('input[name], select[name]').not('#totalSimultaneousEventsTxt').prop('autocomplete','new-password');
			//Keep totalSimultaneousEventsTxt with specific autocomplete setting  
			$('#totalSimultaneousEventsTxt').prop('autocomplete','off');
			if (!isCreate) {
				loadLicenseData();
			} else {
				licenseLimits.toggleAcquisitionTypeChkBxs(false);
			}
			
			$('#newAdminBtn').click(function() {
				location.href = '/admin/management/createuser.jsp?<%=sQueryString%>&<%=Constants.RQLICENSEID%>=<%=sLicenseId%>';
			});
			
			if (<%=hasManageLicensePerm%>) {
				$('#saveBtn').click(function() {
					validateLicenseSettings();
				});

				$('#cancelBtn').click(function() {
					location.href = '/admin/management/managelicenses.jsp?<%=sQueryString%>'; 
				});
				
				if (isCreate) {	    			
					$('#changeFolderBtn').fancybox({
						beforeLoad     :   function() {
							this.href= '/admin/foldertree.jsp?<%=sQueryString%>&action=clientfolder&findfolder=' + $('#folderSpn').data('fi');
		 			    },
						'width'				: 600,
						'height'			: '95%',
				        'autoScale'     	: false,
				        'transitionIn'		: 'none',
						'transitionOut'		: 'none',
						'type'				: 'iframe',
						"hideOnOverlayClick": false,
				        'autoSize'			: false,
						'openSpeed'			: 0,
						'closeSpeed'        : 'fast',
						'closeClick'  		: false,
						helpers    : { 
							        'overlay' : {'closeClick': false}
						},
					    beforeShow : function() {
					        	$('.fancybox-overlay').css({
					        		'background-color' :'rgba(119, 119, 119, 0.7)'
					        	});
					        },
					    iframe: { preload: false }
					});
					
					$('#clientTeamManagerDiv').hide();
					$('#myTeams').hide();
					$('#featurePackages').hide();
					$('#clientLabelSpn').addClass('displayNone');
				} else {
	    			$('#changeFolderBtn').hide();
	    			$('#clientLabelSpn').removeClass('displayNone');
					
					$('#selectTeamManagerBtn').fancybox({
						beforeLoad     :   function() {
							this.href= '/admin/management/userchooser.jsp?<%=sQueryString%>&action=selectteammanager&callback_func=teamManagerSelectCallback&<%=Constants.RQLICENSEID%>=<%=sLicenseId%>';
		 			    },				
						'width'				: 900,
						'height'			: '95%',
				        'autoScale'     	: false,
				        'transitionIn'		: 'none',
						'transitionOut'		: 'none',
						'type'				: 'iframe',
						"hideOnOverlayClick": false,
				        'autoSize'			: false,
						'openSpeed'			: 0,
						'closeSpeed'        : 'fast',
						'closeClick'  		: false,
						helpers    : { 
							        'overlay' : {'closeClick': false}
						},
					    beforeShow : function() {
					        	$('.fancybox-overlay').css({
					        		'background-color' :'rgba(119, 119, 119, 0.7)'
					        	});
					        },
					    iframe: { preload: false }
					});
	    			
	    			$('#addExistingAdminBtn').fancybox({
						beforeLoad     :   function() {
							this.href= '/admin/management/userchooser.jsp?<%=sQueryString%>&action=addtolicense&callback_func=addAdminCallback&<%=Constants.RQFOLDERID%>=<%=license == null ? Constants.EMPTY : license.getFolderId()%>';
		 			    },				
						'width'				: 900,
						'height'			: '95%',
				        'autoScale'     	: false,
				        'transitionIn'		: 'none',
						'transitionOut'		: 'none',
						'type'				: 'iframe',
						"hideOnOverlayClick": false,
				        'autoSize'			: false,
						'openSpeed'			: 0,
						'closeSpeed'        : 'fast',
						'closeClick'  		: false,
						helpers    : { 
							        'overlay' : {'closeClick': false}
						},
					    beforeShow : function() {
					        	$('.fancybox-overlay').css({
					        		'background-color' :'rgba(119, 119, 119, 0.7)'
					        	});
					        },
					    iframe: { preload: false }
					});
	    			
	    			$('#addPackageBtn').fancybox({
						beforeLoad     :   function() {
							this.href= '/admin/management/packagechooser.jsp?<%=sQueryString%>&callback_func=editLicensePackagesCallback&<%=Constants.RQLICENSEID%>=<%=sLicenseId%>';
		 			    },				
						'width'				: 600,
						'height'			: '95%',
				        'autoScale'     	: false,
				        'transitionIn'		: 'none',
						'transitionOut'		: 'none',
						'type'				: 'iframe',
						"hideOnOverlayClick": false,
				        'autoSize'			: false,
						'openSpeed'			: 0,
						'closeSpeed'        : 'fast',
						'closeClick'  		: false,
						helpers    : { 
							        'overlay' : {'closeClick': false}
						},
					    beforeShow : function() {
					        	$('.fancybox-overlay').css({
					        		'background-color' :'rgba(119, 119, 119, 0.7)'
					        	});
					        },
					    iframe: { preload: false }
					});
				}
			} else {
				$('#changeFolderBtn').hide();
			}

		});
		
		function loadLicenseData() {
			loadData({
				action: 'load'
			});
		}
		
		function validateLicenseSettings() {
			var hasErrors = false;
			
			if (basicUtils.isEmpty($('#licenseNameTxt').val())) {
				hasErrors = true;
				if ($('#licenseNameTxt').hasClass('error') === true) {
					$('#licenseNameTxt').removeClass('error').next().remove();
				}
				
				$('#licenseNameTxt').addClass('error').after('<span class="small-error-text marginLeft10px">Required</span>');				
			} else if ($('#licenseNameTxt').val().length > 255) {
				hasErrors = true;
				if ($('#licenseNameTxt').hasClass('error') === true) {
					$('#licenseNameTxt').removeClass('error').next().remove();
				}
				
				$('#licenseNameTxt').addClass('error').after('<span class="small-error-text marginLeft10px">License Name cannot be longer than 255 characters.</span>');
			} else {
				if ($('#licenseNameTxt').hasClass('error')) {
					$('#folderSpn').removeClass('error').next().remove();
				}
			}
			
			if (basicUtils.isEmpty($('#folderSpn').data('fi'))) {
				hasErrors = true;
				if ($('#folderSpn').hasClass('error') === false) {
					$('#folderSpn').addClass('error').after('<span class="small-error-text marginLeft10px marginRight15px">Required</span>');
				}
			} else {
				if ($('#folderSpn').hasClass('error')) {
					$('#folderSpn').removeClass('error').next().remove();					
				}
			}
			
			if ($('#pgiClientIdTxt').val().length > 200) {
				hasErrors = true;
				if ($('#pgiClientIdTxt').hasClass('error') === true) {
					$('#pgiClientIdTxt').removeClass('error').next().remove();
				}
			
				$('#pgiClientIdTxt').addClass('error').after('<span class="small-error-text marginLeft10px">PGi Client ID cannot be longer than 200 characters.</span>');
			}
			 
			var licenseData = licenseLimits.getLicenseData();
			
			if (!basicUtils.isNum(licenseData.rulevalues.<%=LicenseRule.MAX_AUDIENCE_SIZE%>) || licenseData.rulevalues.<%=LicenseRule.MAX_AUDIENCE_SIZE%> === '-1') {
				hasErrors = true;
				licenseLimits.setRequiredMsg('<%=LicenseRule.MAX_AUDIENCE_SIZE%>');
			} else {
				licenseLimits.clearErrorMsg('<%=LicenseRule.MAX_AUDIENCE_SIZE%>');
			}
			
			if (!basicUtils.isNum(licenseData.rulevalues.<%=LicenseRule.MAX_EVENT_DURATION%>) || licenseData.rulevalues.<%=LicenseRule.MAX_EVENT_DURATION%> === '-1') {
				hasErrors = true;
				licenseLimits.setRequiredMsg('<%=LicenseRule.MAX_EVENT_DURATION%>');
			} else {
				licenseLimits.clearErrorMsg('<%=LicenseRule.MAX_EVENT_DURATION%>');
			}
			
			if (!basicUtils.isNum(licenseData.rulevalues.<%=LicenseRule.MAX_EVENT_EXPIRATION%>) || licenseData.rulevalues.<%=LicenseRule.MAX_EVENT_EXPIRATION%> === '-1') {
				hasErrors = true;
				licenseLimits.setRequiredMsg('<%=LicenseRule.MAX_EVENT_EXPIRATION%>');
			} else {
				licenseLimits.clearErrorMsg('<%=LicenseRule.MAX_EVENT_EXPIRATION%>');
			}
			
			if (!basicUtils.isNum(licenseData.expirationdate)) {
				hasErrors = true;
				licenseLimits.setRequiredMsg('expirationdate');
			} else {
				licenseLimits.clearErrorMsg('expirationdate');
			}
			
			if (!licenseLimits.validateHelper('<%=LicenseRule.OVERALL_SIMULTANEOUS_EVENT_LIMIT_KEY%>', 10000)) {
				hasErrors = true;
			} else {
				if (licenseLimits.isSimultaneousEventsByResourceType()) {
					if (!licenseLimits.validateHelper('<%=Constants.ResourceType.WEBCAM_ADVANCED%>', 10000, 0) || !licenseLimits.validateHelper('<%=Constants.ResourceType.VCU%>', 10000, 0) 
							|| !licenseLimits.validateHelper('<%=Constants.ResourceType.ENCODER%>', 10000, 0) || !licenseLimits.validateHelper('<%=Constants.ResourceType.TELEPHONY_AUDIO%>', 10000, 0) 
							|| !licenseLimits.validateHelper('<%=Constants.ResourceType.PEXIP_BRIDGE%>', 10000, 0) || !licenseLimits.validateHelper('<%=Constants.ResourceType.SIMLIVE%>', 10000, 0)) {
						hasErrors = true;
					}
					
					if (!licenseLimits.validateSimultaneousEventsByResourceTypeTotals()) {
						hasErrors = true;
					}
	            }
			}
			
			if (!hasErrors) {
				if (isCreate) {
					saveLicense();
				} else {
					checkPassword(saveLicense);
				}
			}
		}
		
		function saveLicense() {			
			var licenseData = {
    			description: $('#licenseNameTxt').val(),
    			folderid: $('#folderSpn').data('fi'),
    			licenseteammanager: $('#clientTeamManagerSpn').data('adminid'),
    			pgiclientid: $('#pgiClientIdTxt').val()
    		};
            
            licenseData = $.extend(licenseData, licenseLimits.getLicenseData());
			
            var params = {
    			action: isCreate ? 'create' : 'save',
    			licensedata: JSON.stringify(licenseData)
    		};
            
			loadData(params, saveLicenseSuccess);
		}
		
		function loadData(postParams, callback) {
			var params = $.extend({}, postParams);
			params.<%=Constants.RQUSERID%> = '<%=StringTools.n2s(request.getParameter(Constants.RQUSERID))%>';
			params.<%=Constants.RQSESSIONID%> = '<%=StringTools.n2s(request.getParameter(Constants.RQSESSIONID))%>';
			params.<%=Constants.RQLICENSEID%> = '<%=sLicenseId%>';
			params.password = $('#password').val();
			$('#password').val('');
			
			$.ajax({
				type: 'POST',
				url: 'proc_editlicense.jsp',
				data: params,
				dataType: 'json',
				success: function(result) {
					if (result.success) {
						if (isCreate) {
							$.success('License created.', '', 'icon_check.png');
							setTimeout('location.href = "/admin/management/editlicense.jsp?<%=sQueryString%>&<%=Constants.RQLICENSEID%>=<%=sLicenseId%>"', 2000);
							return;
						}
						
						if (typeof callback === 'function') {
							callback(result);
						}
						populateLicenseData(result);
					} else {
						if (result.errormsg) {
							$.alert('Hmm. Something isn\'t right.', result.errormsg, 'icon_alert.png');
						} else {
							$.alert('Oops! Something went wrong.', 'Error occurred.', 'icon_error.png');
						}
					}
				},
				error: function(xmlHttpRequest, status, errorThrown) {
					$.alert('Oops! Something went wrong.', 'error:' + errorThrown, 'icon_error.png');
	            }
	        });
		}

		function populateLicenseData(result) {
			var licenseData = result.licenseData;
			
			$('#licenseNameTxt').val(licenseData.description);
			$('#folderSpn').text(licenseData.foldername);
			$('#folderSpn').data('fi', licenseData.folderid);
			$('#clientSpn').text(licenseData.clientname);
			$('#clientTeamManagerSpn').text(licenseData.teammanagername);
			$('#clientTeamManagerSpn').data('adminid', licenseData.licenseteammanager);
			$('#pgiClientIdTxt').val(licenseData.pgiclientid);
			
			licenseLimits.loadLicenseData(licenseData);

			$('#featurePackageSec').children().remove();
			
			var docFrag = document.createDocumentFragment();
			
			licenseData.permissionpackages.sort(function(a, b) {
				var nullA = !basicUtils.isDefined(a) || !basicUtils.isDefined(licenseData.permissionpackagedata[a]) || !basicUtils.isDefined(licenseData.permissionpackagedata[a].description);
				var nullB = !basicUtils.isDefined(b) || !basicUtils.isDefined(licenseData.permissionpackagedata[b]) || !basicUtils.isDefined(licenseData.permissionpackagedata[b].description);
				if (nullA) {
					return nullB ? 0 : 1;
				} else if (nullB) {
					return -1;
				}					
				
				var descA = licenseData.permissionpackagedata[a].description.toLowerCase();
				var descB = licenseData.permissionpackagedata[b].description.toLowerCase();
				
				return descA < descB ? -1 : descA > descB ? 1 : 0;
			});
			
			for (var index in licenseData.permissionpackages) {
				if (licenseData.permissionpackages.hasOwnProperty(index)) {
					var permissionpackageData = licenseData.permissionpackagedata[licenseData.permissionpackages[index]];
							
					var additionalRowClass = '';
					if (index % 2 === 0) {
						additionalRowClass = ' evenBgColor';
					}
					
					var permissionPackageDiv = basicUtils.generateElement('div', '', 'permissionPackageDiv ' + additionalRowClass);
					permissionPackageDiv.setAttribute('data-permissionpackageid', permissionpackageData.packageid);
					permissionPackageDiv.setAttribute('data-permissionpackagedesc', permissionpackageData.description);
					
					var packageNameDiv = basicUtils.generateElement('div', permissionpackageData.description, 'packageNameDiv');
					
					var arrow = basicUtils.generateElement('span', '', 'arrowClosed');
					
					permissionPackageDiv.appendChild(arrow);
				    permissionPackageDiv.appendChild(packageNameDiv);
										
					packageActionsDiv = basicUtils.generateElement('div', '', 'packageActionsDiv');
					<% if (hasManageLicensePerm) { %>
						var btn = basicUtils.generateElement('button', '', 'unlinkBtn circleBtns');
						btn.setAttribute('alt', 'Unlink');
						btn.setAttribute('title', 'Unlink');
						packageActionsDiv.appendChild(btn);
					<% } %>
					permissionPackageDiv.appendChild(packageActionsDiv);
					
					docFrag.appendChild(permissionPackageDiv);
					
					permissionListDiv = basicUtils.generateElement('div', '', 'permissionList ' + additionalRowClass);
					permissionListDiv.id = 'permissionlist_' + permissionpackageData.packageid;
					permissionListDiv.style.display = 'none';
					
					for (var permissionIndex in permissionpackageData.permissions) {
						if (permissionpackageData.permissions.hasOwnProperty(permissionIndex)) {
							var permissionSpan = basicUtils.generateElement('span', permissionpackageData.permissions[permissionIndex], 'permission');
							permissionListDiv.appendChild(permissionSpan);
						}
					}
					
					docFrag.appendChild(permissionListDiv);
				}
			}
			$('#featurePackageSec').append(docFrag);
			
			<% if (hasManageLicensePerm) { %>
				$('#featurePackageSec .unlinkBtn').click(function() {
					checkPassword(removePermissionPackage, [$(this).closest('.permissionPackageDiv').data('permissionpackageid'), $(this).closest('.permissionPackageDiv').data('permissionpackagedesc')], 'Are you sure you want to remove this package?');
				});
			<% } %>
			
			$('.packageNameDiv, .arrowOpened, .arrowClosed').click(function() {
				if ($(this).hasClass('open') === true) {
					if ($(this).hasClass('arrowOpened')) {
						$(this).removeClass('arrowOpened').addClass('arrowClosed');
					} else {
						$(this).prev().removeClass('arrowOpened').addClass('arrowClosed');
					}
					
					$(this).removeClass('open').parent().next().slideUp();
				} else {
					if ($(this).hasClass('arrowClosed')) {
						$(this).removeClass('arrowClosed').addClass('arrowOpened');
					} else {
						$(this).prev().removeClass('arrowClosed').addClass('arrowOpened');
					}
					
					$(this).addClass('open').parent().next().slideDown();
				}
			});
			
			
			$('#myTeamTbl tbody').remove();
			var tbody = document.createElement('tbody');
			
			var adminCount = 0;
			
			for (var index in licenseData.admins) {
				if (licenseData.admins.hasOwnProperty(index)) {
					adminCount++;
				
					var adminData = licenseData.admins[index];
					
					if (index % 2 === 0) {
						var tr = basicUtils.generateElement('tr', '', 'myTeamUser odd');	
					} else {
						var tr = basicUtils.generateElement('tr', '', 'myTeamUser');
					}
					
					if (licenseData.licenseteammanager === adminData.userid) {
						tr.classList.add('teammanagerHighlight');
					}
					
					tr.setAttribute('data-adminid', adminData.userid);
	
					tr.appendChild(basicUtils.generateElement('td', adminData.username, 'usernameTd'));
					
					tr.appendChild(basicUtils.generateElement('td', adminData.userCreateDate, 'CreatedDateTd'));
					tr.appendChild(basicUtils.generateElement('td', adminData.lastLoginDate, 'LastLoginDateTd'));		
					
					var packageNameArray = [];
					for (var packageIndex in adminData.packages) {
						if (adminData.packages.hasOwnProperty(packageIndex)) {
							packageNameArray.push(licenseData.permissionpackagedata[adminData.packages[packageIndex]].description);
						}
					}
					var packageNameList = packageNameArray.sort().join(', ') + (adminData.custompermissions == true ? (packageNameArray.length > 0 ? ', ' : '') + 'Custom' : '');
					
					tr.appendChild(basicUtils.generateElement('td', packageNameList, 'assignedPackagesTd'));
					
					var td = basicUtils.generateElement('td', '', 'myTeamEditBtnTd');
					var btn = basicUtils.generateElement('button', '', 'myTeamEditBtn circleBtns');
					btn.setAttribute('alt', 'Edit');
					btn.setAttribute('title', 'Edit');
					td.appendChild(btn);
					<% if (hasManageLicensePerm) { %>
						btn = basicUtils.generateElement('button', '', 'unlinkBtn circleBtns marginLeftnRight8px');
						btn.setAttribute('alt', 'Unlink');
						btn.setAttribute('title', 'Unlink');						
						td.appendChild(btn);
					<% } %>
					btn = basicUtils.generateElement('button', '', 'redCloseBtn circleBtns');
					btn.setAttribute('alt', 'Delete');
					btn.setAttribute('title', 'Delete');
					td.appendChild(btn);
					tr.appendChild(td);

					tbody.appendChild(tr);
				}
			}
			$('#myTeamTbl').append(tbody);
			
			if (adminCount >= licenseData.adminaccountlimit) {
				$('#newAdminBtn').hide();
			} else {
				$('#newAdminBtn').show();
			}
			
			if($('.teammanagerHighlight').length){
				$('<i class="fa fa-star" aria-hidden="true"></i>').prependTo('.teammanagerHighlight .usernameTd');	
			}
			
			$('#myTeamTbl .myTeamEditBtn').click(function() {
				location.href = '/admin/management/userprofile.jsp?<%=sQueryString%>&ai=' + $(this).closest('.myTeamUser').data('adminid') + '&returnpage=editlicense';
			});
			
			$('#myTeamTbl .redCloseBtn').click(function() {
				checkPassword(deleteUser, [$(this).closest('.myTeamUser').data('adminid')], 'Are you sure you want to delete ' + $(this).parent().siblings('.usernameTd').text() + '?');
			});
			
			<% if (hasManageLicensePerm) { %>
				$('#myTeamTbl .unlinkBtn').click(function() {
					removeUser($(this).closest('.myTeamUser').data('adminid'), $(this).parent().siblings('.usernameTd').text());
				});
			<% } %>
		}
		
		function saveLicenseSuccess(result) {
			$.alert('Success!', 'Saved license data.', 'icon_check.png');
		}
		
		function folderTreeCallback(selectedFolder, folderName) {
			$('#folderSpn').text(folderName);
			$('#folderSpn').data('fi', selectedFolder);
			$('#clientSpn').text('');
		}

		function teamManagerSelectCallback(selectedUser, selectedName) {
			if (selectedUser == '' || !basicUtils.isDefined(selectedUser)) {
				$('#clientTeamManagerSpn').html('');
			} else {
				$('#clientTeamManagerSpn').html(selectedName + ' (' + $('tr[data-adminid="' + selectedUser + '"] > .usernameTd').text() + ')');
			}
			
			$('#clientTeamManagerSpn').data('adminid', selectedUser);
		}
		
		function addAdminCallback(selectedUser, selectedName) {
			addExistingAdmin(selectedUser, selectedName);
		}
		
		function editLicensePackagesCallback(selectedPackages) {
			editLicensePackages(selectedPackages);
		}
		
		function checkPassword(callback, callbackParams, customMsg){
			$('#password').val('');
			$('#name').val('');
			var objButton = {'Cancel': function(){$('#authForm').dialog('close');},'Authenticate':function(){callback(callbackParams);$('#authForm').dialog('close');}};
			if (basicUtils.isDefined(customMsg)) {
				$.confirmPassword(customMsg,'Please enter your password for authentication.',objButton,'');
			} else {
				$.confirmPassword('Please enter your password for authentication.',' ',objButton,'');
			}	
		}
		
		function deleteUser(args) {
			loadData({
				deleteui: args[0],
				action: 'deleteAdmin'
			}, deleteUserSuccess);
		}
		
		function deleteUserSuccess(result) {
			$.alert('Success!', 'Deleted ' + result.deletedusername + '.', 'icon_check.png');
		}
		
		function removeUser(userId, userName) {
			var objButton = {'No': function(){$("#alertDialog").dialog("close");},'Yes':function(){loadData({
				removeui: userId,
				action: 'removeAdmin'
			}, 
			removeUserSuccess);$("#alertDialog").dialog("close");}};
					
			$.confirm('Are you sure you want to unlink ' + userName + ' from this license?',' ',objButton,'');
		}
		
		function removeUserSuccess(result) {
			$.alert('Success!', 'Removed ' + result.removedusername + '.', 'icon_check.png');
		}
		
		function addExistingAdmin(userId) {
			loadData({
				addui: userId,
				action: 'addAdmin'
			}, addUserSuccess);
		}
		
		function addUserSuccess(result) {
			$.alert('Success!', 'Added ' + result.addedusername + '.', 'icon_check.png');
		}
		
		function removePermissionPackage(args) {
			loadData({
				packageid: args[0],
				action: 'removePackage'
			}, removePackageSuccess);
		}
		
		function removePackageSuccess(result) {
			$.alert('Success!', 'Removed ' + result.removedpackagename + '.', 'icon_check.png');
		}
		
		function editLicensePackages(packages) {
			loadData({
				packagelist: JSON.stringify(packages),
				action: 'editPackages'
			}, editLicensePackagesSuccess);
		}
		
		function editLicensePackagesSuccess() {
			$.alert('Success!', 'Packages Saved.', 'icon_check.png');
		}
	</script>
<%
} catch(Exception e) {
	logger.log(Logger.CRIT, "editlicense.jsp", e.getMessage());
	logger.log(Logger.INFO, "editlicense.jsp", ErrorHandler.getStackTrace(e));
	response.sendRedirect(ErrorHandler.handle(e, request));
}
%>
<jsp:include page="/admin/footerbottom.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>

<%@ page import="java.util.*"%>
<%@ page import="org.apache.commons.lang3.*"%>
<%@ page import="tcorej.adminlicense.*"%>
<%@ page import="tcorej.*"%>
<%
//get pfo and ufo
String sPFOID = StringTools.n2s(request.getParameter(Constants.RQPFOID));
PFO pfo = PageTools.cacheGetPageFrag(sPFOID);
String sUFOID = StringTools.n2s(request.getParameter(Constants.RQUFOID));
UFO ufo = PageTools.cacheGetUserFrag(sUFOID);

AdminUser admin = AdminUser.getInstance(ufo.sUserID);

String sLicenseId = StringTools.n2s(request.getParameter(Constants.RQLICENSEID));
AdminLicense license = AdminLicense.get(sLicenseId);

if (license != null && !admin.canAccessLicense(sLicenseId)) {
	throw new Exception(Constants.ExceptionTags.EGENERALEXCEPTION.display_code());
}

boolean isEditable = StringTools.n2b(request.getParameter("editable"));

boolean hasManageLicensePerm = admin.can(Perms.User.MANAGELICENSES);
%>
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
  	margin-right: 10px;
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
  
  .licenseLimits{
    padding: 10px 25px 20px 25px;
    margin-top: 20px;
  }

  .header {
    margin-bottom: 15px;
  }
  
  .licenseLimits select{
	width: 108px;	
	flex-basis: 108px;
    padding: 2px 0px;
  }

  .licenseLimits input{
    width: 96px;
  }

  .customizeAcquisitionTypeChx{
    width: 40px !important;
  }

  .customizeAcquisitionTypeSpn{
    position: relative;
    top: -2px;
    margin-left: -15px;
  }

  .licenseLimitsBtmContainer{
    margin-top: 5px;
  }

  .licenseLimitsLeftColumnBtm{
    margin-left: 37px;
  }

  .licenseLimitsRightColumnBtm{
    flex-grow: 1;
    align-items: flex-end;
  }
  
  .webcamSpn{
  	width: 117px
  }
  
  .errorDiv{
    justify-content: center;
    margin-right: 30px;
    margin-bottom: 5px
  }
  
  .twoStepVerifyDiv{
    display: flex;
    align-items: center;
    justify-content: flex-start;
    margin-bottom: 5px;
  }
  
  .twoStepVerifyDiv input{
  	top: 0;
  	margin: 0;
  	width: auto !important;
  }
  
  .twoStepVerifyDiv .customizeAcquisitionTypeSpn{
  	margin-left: 5px;
  }
  
  .expiresOnDiv{
  	width: 262px;
  	margin-bottom: 10px;
  }
</style>
<div id="licenseLimitsDiv" class="border licenseLimits">
	<h2 id="licenseLimitsHdr" class="header"> License Limits &nbsp;<img id="licenseLimitsHelpImg" src="/admin/images/help.png" class="helpIcon" title="Help with License Limits" alt="Help with License Limits" name="help" onClick="$.help('license_limits','Help with License Limits');"/>&nbsp;</h2>
	
	<div id="licenseLimitsTopContainer" class="flexbox flexCenter">
		<div id="licenseLimitsLeftColumnTop" class="flexboxColumn">
			<div id="maxAudienceDiv" class="flexbox flexCenter">
				<span id="maxAudienceSpn" class="paddingTopBtm2px flexGrow"> Max Audience Size </span>
				<select id="maxAudienceSlt" class="maxAudienceSlt marginBtm5px" name="maxAudienceSlt" data-ruleid="<%=LicenseRule.MAX_AUDIENCE_SIZE%>">
				<option value="-1" selected>-</option>
<%
					Integer iAdminAudienceSize = StringTools.n2I(admin.getProperty(AdminProps.adminaudiencesize), 1000);
	
					if (admin.hasLicense()) {
						iAdminAudienceSize = (Integer) admin.getLicense().getRuleValue(LicenseRule.MAX_AUDIENCE_SIZE);
					}
	
					String sPricingGridFolderId = new PricingGrid().getPricingGridFolder(admin.sHomeFolder);
					for (HashMap<String,String> userBracketMap : PricingGridTools.getUserBracketsFromPricingGridForFolder(sPricingGridFolderId)) {
						if (admin.can(Perms.User.SUPERUSER) || StringTools.n2i(userBracketMap.get("value")) <= iAdminAudienceSize) {
							%><option value="<%=userBracketMap.get("value")%>"><%=StringEscapeUtils.escapeHtml4(userBracketMap.get("display"))%></option><%
						}
					} 
%>
				</select>
			</div>
			
			<div id="maxEventDurationDiv" class="flexbox flexCenter">
				<span id="maxEventDurationSpn" class="paddingTopBtm2px flexGrow"> Max Event Duration </span>
				<select id="maxEventDurationSlt" class="maxEventDurationSlt marginBtm5px" name="maxEventDurationSlt" data-ruleid="<%=LicenseRule.MAX_EVENT_DURATION%>">
					<option value="-1">-</option>
<%				
					int iAdminMaxEventDuration = StringTools.n2i(admin.getProperty(AdminProps.admineventduration), 480);
					
					if (admin.hasLicense()) {
						iAdminMaxEventDuration = (Integer) admin.getLicense().getRuleValue(LicenseRule.MAX_EVENT_DURATION);
					}
					
					String sSelectedDurationDisplpay;
					for (HashMap<String,String> timeBracketMap : PricingGridTools.getTimeBracketsFromPricingGridForFolder(sPricingGridFolderId)) {
						if (admin.can(Perms.User.SUPERUSER) || StringTools.n2i(timeBracketMap.get("value")) <= iAdminMaxEventDuration) { 
							%><option value="<%=timeBracketMap.get("value")%>"><%=StringEscapeUtils.escapeHtml4(timeBracketMap.get("display"))%></option><%
						}
					}
%>
				</select>
			</div>
			
			<div id="maxArchiveLengthDiv" class="flexbox flexCenter">
				<span id="maxArchiveLengthSpn" class="paddingTopBtm2px flexGrow"> Max Archive Length </span>
				<select id="maxArchiveLengthSlt" class="maxArchiveLengthSlt marginBtm5px" name="maxArchiveLengthSlt" data-ruleid="<%=LicenseRule.MAX_EVENT_EXPIRATION%>">
					<option value="-1">-</option>
<%				
					int iAdminMaxExpirationMonths = StringTools.n2i(admin.getProperty(AdminProps.admineventexpiration), Constants.MAX_EXPIRATION_MONTHS);
					
					if (admin.hasLicense()) {
						iAdminMaxExpirationMonths = (Integer) admin.getLicense().getRuleValue(LicenseRule.MAX_EVENT_EXPIRATION);
					}
	
					for (final Constants.EventArchiveDurationOption option : EnumSet.allOf(Constants.EventArchiveDurationOption.class)) {
						if (admin.can(Perms.User.SUPERUSER) || option.value() <= iAdminMaxExpirationMonths) {
							%><option value="<%=option.value()%>"><%=StringEscapeUtils.escapeHtml4(option.display())%></option><%
						}
					}
%>
				</select>
			</div>
			
			<div id="totalSimEventsDiv" class="flexbox flexCenter">
				<span id="totalSimEventsSpn" class="paddingTopBtm2px flexGrow marginRight15px"> Total Simultaneous Events </span>
				<div style="position: relative; display: inline-block;">
					<input id="totalSimultaneousEventsTxt_fake" name="fake_field_name" autocomplete="nope" style="position: absolute; left: -9999px; opacity: 0;" type="text" tabindex="-1">
					<input id="totalSimultaneousEventsTxt" name="sim_events_limit" autocomplete="nope" readonly onfocus="this.removeAttribute('readonly'); this.select();" class="totalSimultaneousEventsTxt marginBtm5px" type="text" data-ruleid="<%=LicenseRule.SIMULTANEOUS_EVENTS%>" data-resourcetypeid="<%=LicenseRule.OVERALL_SIMULTANEOUS_EVENT_LIMIT_KEY%>" spellcheck="false" data-form-type="other">
				</div>
			</div>
			
		</div>
	</div>
	
	<input id="customizeAcquisitionTypeChx" class="marginBtm5px customizeAcquisitionTypeChx" type="checkbox">
	<span id="customizeAcquisitionTypeSpn" class="customizeAcquisitionTypeSpn"> Customize by Acquisition Type </span>
	
	<div id="licenseLimitsBtmContainer" class="flexbox licenseLimitsBtmContainer">
		<div id="licenseLimitsLeftColumnBtm" class="flexboxColumn licenseLimitsLeftColumnBtm">
		
			<div id="maxEventDurationDiv" class="flexbox flexCenter">
				<span id="webcamSpn" class="webcamSpn paddingTopBtm2px flexGrow"> Webcam </span>
				<input id="webcamTxt" class="marginBtm5px" type="text" data-resourcetypeid="<%=Constants.ResourceType.WEBCAM_ADVANCED%>">
			</div>
			
			<div id="vcuDiv" class="flexbox flexCenter">
				<span id="vcuSpn" class="paddingTopBtm2px flexGrow"> VCU </span>
				<input id="vcuTxt" class="marginBtm5px" type="text" data-resourcetypeid="<%=Constants.ResourceType.VCU%>">
			</div>
			<div id="vcuDiv" class="flexbox flexCenter">
				<span id="encoderSpn" class="paddingTopBtm2px flexGrow"> Your Encoder </span>
				<input id="encoderTxt" class="marginBtm5px" type="text" data-resourcetypeid="<%=Constants.ResourceType.ENCODER%>">
			</div>
			<div id="vcuDiv" class="flexbox flexCenter">
				<span id="telephoneSpn" class="paddingTopBtm2px flexGrow"> Telephone </span>
				<input id="telephoneTxt" class="marginBtm5px" type="text" data-resourcetypeid="<%=Constants.ResourceType.TELEPHONY_AUDIO%>">
			</div>
			<div id="vcuDiv" class="flexbox flexCenter">
				<span id="videoBridgeSpn" class="paddingTopBtm2px flexGrow"> Video Bridge </span>
				<input id="videoBridgeTxt" class="marginBtm5px" type="text" data-resourcetypeid="<%=Constants.ResourceType.PEXIP_BRIDGE%>">
			</div>
			<div id="vcuDiv" class="flexbox flexCenter">
				<span id="simLiveSpn" class="paddingTopBtm2px flexGrow"> Sim Live </span>
				<input id="simLiveTxt" class="marginBtm5px" type="text" data-resourcetypeid="<%=Constants.ResourceType.SIMLIVE%>">
			</div>
		</div>
	</div>
</div>
<div id="licenseSecurityDiv" class="border licenseLimits">
	<h2 id="licenseSecurityHdr" class="header"> Security Settings &nbsp;<img id="licenseSecuritySettingsHelpImg" src="/admin/images/help.png" class="helpIcon" title="Help with License Security Settings" alt="Help with License Security Settings" name="help" onClick="$.help('license_security_settings','Help with License Security Settings');"/>&nbsp;</h2>

	<div id="expiresOnDiv" class="flexbox flexCenter expiresOnDiv">
		<span id="expiresOnSpn" class="paddingTopBtm2px flexGrow"> Expires On </span>
		<input id="expiresOnDateTxt" class="expiresOnDateTxt marginBtm5px" name="expiresOnDateTxt" type="text" size="10" readonly value="" autocomplete="off" class="hasDatepick">
	</div>

	<div class="twoStepVerifyDiv">
		<input id="licenseRequireTwoStepVerificationChx" class="marginBtm5px customizeAcquisitionTypeChx" type="checkbox">
		<span id="licenseRequireTwoStepVerificationSpn" class="customizeAcquisitionTypeSpn"> Require 2-Step Verification for all Accounts </span>
	</div>

<!-- 	<div id="accountRequireTwoStepVerificationDiv" class="flexbox flexCenter" style="display:none;">
		<input id="accountRequireTwoStepVerificationChx" class="marginBtm5px customizeAcquisitionTypeChx" type="checkbox">
		<span id="accountRequireTwoStepVerificationSpn" class="customizeAcquisitionTypeSpn"> Enable 2-Step Verification </span>
	</div> -->
</div>
<script src="/min/admin_jq364.concat.js?<%=Configurator.getInstance(Constants.ConfigFile.GLOBAL).get("codetag")%>"></script>
<script type="text/javascript" src="/js/moment/moment.min.js"></script>
<script type="text/javascript" src="/js/moment/moment-timezone-with-data.min.js"></script>
<script type="text/javascript" src="/js/jquery/jquery.datepick.min.js"></script>
<script type="text/javascript">
	//Moment format string that matches default format for datepicker plugin
	var DATEPICKER_MOMENT_FORMAT = 'MM/DD/YYYY';
	
	var TIMEZONE_ID = '<%=StringEscapeUtils.escapeEcmaScript(admin.sTimeZoneName)%>';
	
	(function(context) {
		//Private Properties
		var REQUIRED_MESSAGE = 'Required';
		var ACQUISITION_TYPE_ITEMS = ['<%=Constants.ResourceType.WEBCAM_ADVANCED%>','<%=Constants.ResourceType.VCU%>','<%=Constants.ResourceType.ENCODER%>',
			'<%=Constants.ResourceType.TELEPHONY_AUDIO%>','<%=Constants.ResourceType.PEXIP_BRIDGE%>','<%=Constants.ResourceType.SIMLIVE%>'];
		
	    //Public Properties

	    //Public Methods
	    licenseLimits.loadLicenseData = function(licenseData) {
	    	for (var ruleId in licenseData.rulevalues) {
	    		if (licenseData.rulevalues.hasOwnProperty(ruleId)) {
	    			if (ruleId == '<%=LicenseRule.SIMULTANEOUS_EVENTS%>') {
	    				var ruleValue = licenseData.rulevalues[ruleId];
	    				
	    				for (var resourceTypeId in ruleValue) {
	    					if (ruleValue.hasOwnProperty(resourceTypeId)) {
	    						$('input[data-resourcetypeid="' + resourceTypeId + '"]').val(ruleValue[resourceTypeId]);
	    					}
	    				}
	    				
	    				$('#customizeAcquisitionTypeChx').prop('checked', Object.keys(ruleValue).length > 1);
	    				licenseLimits.toggleAcquisitionTypeChkBxs(Object.keys(ruleValue).length > 1);
	    			} else {
	    				$('select[data-ruleid="' + ruleId + '"]').val(licenseData.rulevalues[ruleId]);
	    			}
	    		}
	    	}
			
	    	$('#expiresOnDateTxt').val(moment.tz(licenseData.expirationdate, 'UTC').format(DATEPICKER_MOMENT_FORMAT));
			$('#licenseRequireTwoStepVerificationChx').prop('checked', (licenseData.twosteprequired == true));
	    };
	    
	    licenseLimits.getLicenseData = function() {
			var ruleValues = {};
			
			ruleValues[$('#maxAudienceSlt').data('ruleid')] = $('#maxAudienceSlt').val();
			ruleValues[$('#maxEventDurationSlt').data('ruleid')] = $('#maxEventDurationSlt').val();
			ruleValues[$('#maxArchiveLengthSlt').data('ruleid')] = $('#maxArchiveLengthSlt').val();			

            var simultaneousEventsValues = {};
            simultaneousEventsValues[$('#totalSimultaneousEventsTxt').data('resourcetypeid')] = $('#totalSimultaneousEventsTxt').val();
            if ($('#licenseLimitsBtmContainer').is(':visible')) {
	            simultaneousEventsValues[$('#webcamTxt').data('resourcetypeid')] = $('#webcamTxt').val();
	            simultaneousEventsValues[$('#vcuTxt').data('resourcetypeid')] = $('#vcuTxt').val();
	            simultaneousEventsValues[$('#encoderTxt').data('resourcetypeid')] = $('#encoderTxt').val();
	            simultaneousEventsValues[$('#telephoneTxt').data('resourcetypeid')] = $('#telephoneTxt').val();
	            simultaneousEventsValues[$('#videoBridgeTxt').data('resourcetypeid')] = $('#videoBridgeTxt').val();
	            simultaneousEventsValues[$('#simLiveTxt').data('resourcetypeid')] = $('#simLiveTxt').val();
            }
            ruleValues[$('#totalSimultaneousEventsTxt').data('ruleid')] = simultaneousEventsValues;
            
            return {
            	expirationdate: moment.tz($('#expiresOnDateTxt').val(), DATEPICKER_MOMENT_FORMAT, 'UTC').startOf('day').valueOf(),
    			requiretwostep: $('#licenseRequireTwoStepVerificationChx').is(':checked'),
    			rulevalues: ruleValues
            }
	    };
	    
	    licenseLimits.setRequiredMsg = function(item) {
	    	errorMsg(getIdByItem(item), REQUIRED_MESSAGE);
	    };
	    
	    licenseLimits.setErrorMsg = function(item, message) {
	    	errorMsg(getIdByItem(item), message);
	    };
	    
	    licenseLimits.clearErrorMsg = function(item) {
	    	clearErrorMsg(getIdByItem(item));
	    };
	    
	    licenseLimits.validateHelper = function(item, maxValue, defaultValue) {
	    	var id = getIdByItem(item);
	    	
			if (!basicUtils.isNum($('#' + id).val()) || (basicUtils.isNum(maxValue) && $('#' + id).val() > maxValue)) {
				if (basicUtils.isDefined(defaultValue)) {
					$('#' + id).val(defaultValue);
				} else {
					errorMsg(id, 'Total Simultaneous Events must be a number less than 10000.');
					return false;
				}
			}
			
			clearErrorMsg(id);
			
			return true;
		};
		
		licenseLimits.validateSimultaneousEventsByResourceTypeTotals = function() {
			if (!licenseLimits.isSimultaneousEventsByResourceType()) {
				return true;
			}
			
			var totalLimit = parseInt($('#' + getIdByItem('<%=LicenseRule.OVERALL_SIMULTANEOUS_EVENT_LIMIT_KEY%>')).val());
			if (!basicUtils.isNum(totalLimit)) {
				return false;
			}
			
			var hasError = false;
			
			var totalOfAllAcqTypes = 0;
			for (var index in ACQUISITION_TYPE_ITEMS) {
				var acqTypeLimit = parseInt($('#' + getIdByItem(ACQUISITION_TYPE_ITEMS[index])).val());
				if (!basicUtils.isNum(acqTypeLimit)) {
					continue;
				}
				
				totalOfAllAcqTypes += acqTypeLimit;
				
				if (acqTypeLimit > totalLimit) {
					errorMsg(getIdByItem(ACQUISITION_TYPE_ITEMS[index]), 'Must not exceed Total Simultaneous Events.');
					hasError = true;
				} else {
					clearErrorMsg(getIdByItem(ACQUISITION_TYPE_ITEMS[index]));
				}
			}
			
			if (totalLimit > totalOfAllAcqTypes) {
				errorMsg(getIdByItem('<%=LicenseRule.OVERALL_SIMULTANEOUS_EVENT_LIMIT_KEY%>'), 'Must not exceed sum of individual acquisition type limits.');
				hasError = true;
			} else {
				clearErrorMsg(getIdByItem('<%=LicenseRule.OVERALL_SIMULTANEOUS_EVENT_LIMIT_KEY%>'));
			}
			
			return !hasError;
		}
		
		licenseLimits.isSimultaneousEventsByResourceType = function() {
	    	return $('#licenseLimitsBtmContainer').is(':visible');
		};
		
		licenseLimits.toggleAcquisitionTypeChkBxs = function(enable) {
			$('#licenseLimitsRightColumnBtm').children().prop('disabled', !enable);
			if (enable) {
				if (!$('#licenseLimitsBtmContainer').is(':visible')) {
					$('#licenseLimitsBtmContainer').slideDown();
				}
			} else {
				if ($('#licenseLimitsBtmContainer').is(':visible')) {
					$('#licenseLimitsBtmContainer').slideUp();
				}
			}
		}
		
	  	//Private Methods
		function generateErrorDiv(message) {
			var errorDiv = basicUtils.generateElement('div', '', 'flexbox errorDiv')
			errorDiv.appendChild(basicUtils.generateElement('div', '', 'flexGrow'))
			errorDiv.appendChild(basicUtils.generateElement('span', message, 'small-error-text'));
			
			return errorDiv;
		}
		
		function errorMsg(id, message) {
			if ($('#' + id).hasClass('error') === false) {
				$('#' + id).addClass('error').parent().after(generateErrorDiv(message));
			}
		}
			
		function clearErrorMsg(id) {
			if ($('#' + id).parent().next().hasClass('errorDiv')) {
				$('#' + id).removeClass('error').parent().next().remove();
			}
		}
		
		function getIdByItem(item) {
			switch (item) {
	    	case '<%=LicenseRule.MAX_AUDIENCE_SIZE%>':
	    		return 'maxAudienceSlt';
	    		break;
	    	case '<%=LicenseRule.MAX_EVENT_DURATION%>':
	    		return 'maxEventDurationSlt';
	    		break;
	    	case '<%=LicenseRule.MAX_EVENT_EXPIRATION%>':
	    		return 'maxArchiveLengthSlt';
	    		break;
	    	case 'expirationdate':
	    		return 'expiresOnDateTxt';
	    		break;
	    	case '<%=LicenseRule.OVERALL_SIMULTANEOUS_EVENT_LIMIT_KEY%>':
	    		return 'totalSimultaneousEventsTxt';
	    		break;
	    	case '<%=Constants.ResourceType.WEBCAM_ADVANCED%>':
	    		return 'webcamTxt';
	    		break;
	    	case '<%=Constants.ResourceType.VCU%>':
	    		return 'vcuTxt';
	    		break;
	    	case '<%=Constants.ResourceType.ENCODER%>':
	    		return 'encoderTxt';
	    		break;
	    	case '<%=Constants.ResourceType.TELEPHONY_AUDIO%>':
	    		return 'telephoneTxt';
	    		break;
	    	case '<%=Constants.ResourceType.PEXIP_BRIDGE%>':
	    		return 'videoBridgeTxt';
	    		break;
	    	case '<%=Constants.ResourceType.SIMLIVE%>':
	    		return 'simLiveTxt';
	    		break;
	    	}
		}
	}(window.licenseLimits = window.licenseLimits || {}));
	
	$(document).ready(function() {
		 $.initdialog();
		 
		//programmatically disable autocomplete on form fields
		$('#pageWrapper').find('input[name], select[name]').not('#totalSimultaneousEventsTxt, #expiresOnDateTxt').prop('autocomplete','new-password');
		//Specifically override autocomplete for license expires date field expiresOnDateTxt
		$("input[name='expiresOnDateTxt']").prop('autocomplete','off');
		
		//Ultra-aggressive protection for totalSimultaneousEventsTxt
		var protectedField = $('#totalSimultaneousEventsTxt');
		var storedValue = '';
		var isUserInput = false;
		
		protectedField
			.attr('autocomplete','nope')
			.prop('autocomplete','nope')
			.removeAttr('name')
			.on('input keyup paste', function(e) {
				isUserInput = true;
				storedValue = $(this).val();
				setTimeout(function() { isUserInput = false; }, 100);
			})
			.on('focus', function(e) {
				storedValue = $(this).val();
				$(this).removeAttr('readonly');
			})
			.on('blur', function(e) {
				storedValue = $(this).val();
			});
		
		// Aggressive value protection with mutation observer
		var observer = new MutationObserver(function(mutations) {
			mutations.forEach(function(mutation) {
				if (mutation.type === 'attributes' && mutation.attributeName === 'value') {
					var currentVal = protectedField.val();
					if (!isUserInput && storedValue && currentVal !== storedValue && (currentVal.includes('@') || currentVal.includes('http'))) {
						protectedField.val(storedValue);
					}
				}
			});
		});
		
		if (protectedField.length > 0) {
			observer.observe(protectedField[0], { attributes: true, attributeFilter: ['value'] });
		}
		
		// Additional protection via intervals
		setInterval(function() {
			if (!isUserInput && protectedField.length > 0) {
				var currentVal = protectedField.val();
				if (storedValue && currentVal !== storedValue && (currentVal.includes('@') || currentVal.includes('http') || currentVal.toLowerCase().includes('user'))) {
					protectedField.val(storedValue);
				}
			}
		}, 500);
		if (<%=hasManageLicensePerm && isEditable%>) { 	
	    	$('#customizeAcquisitionTypeChx').change(function() {
	    		// Store the current value before toggling with stronger protection
	    		var currentSimEventsValue = $('#totalSimultaneousEventsTxt').val();
	    		isUserInput = true; // Set global flag
	    		
	    		licenseLimits.toggleAcquisitionTypeChkBxs(this.checked);
	    		$('#licenseLimitsBtmContainer .error').each(function(){
	    			clearErrorMsg($(this));
	    		});
	    		
	    		// Restore the value multiple times to ensure it sticks
	    		setTimeout(function() {
	    			if (currentSimEventsValue && $('#totalSimultaneousEventsTxt').val() !== currentSimEventsValue) {
	    				$('#totalSimultaneousEventsTxt').val(currentSimEventsValue);
	    				storedValue = currentSimEventsValue;
	    			}
	    			isUserInput = false;
	    		}, 50);
	    		
	    		setTimeout(function() {
	    			if (currentSimEventsValue && $('#totalSimultaneousEventsTxt').val() !== currentSimEventsValue) {
	    				$('#totalSimultaneousEventsTxt').val(currentSimEventsValue);
	    				storedValue = currentSimEventsValue;
	    			}
	    		}, 200);
	    	});
	    	
	    	$('#expiresOnDateTxt').datepick({
	    		beforeShow: function() {
	    			// Store value before date picker opens
	    			storedValue = $('#totalSimultaneousEventsTxt').val();
	    		},
	    		onClose: function() {
	    			// Restore value after date picker closes
	    			var currentVal = $('#totalSimultaneousEventsTxt').val();
	    			if (storedValue && currentVal !== storedValue && (currentVal.includes('@') || currentVal.includes('http'))) {
	    				$('#totalSimultaneousEventsTxt').val(storedValue);
	    			}
	    		},
	    		onSelect: function() {
	    			// Additional protection during selection
	    			setTimeout(function() {
	    				var currentVal = $('#totalSimultaneousEventsTxt').val();
	    				if (storedValue && currentVal !== storedValue && (currentVal.includes('@') || currentVal.includes('http'))) {
	    					$('#totalSimultaneousEventsTxt').val(storedValue);
	    				}
	    			}, 10);
	    		}
	    	});
		} else {
			$('#licenseLimitsDiv *').attr('disabled', true);
			$('#licenseSecurityDiv *').attr('disabled', true);
			$('#customizeAcquisitionTypeChx').hide();
			$('#customizeAcquisitionTypeSpn').hide();
			$('#licenseLimitsHelpImg').hide();
			$('#licenseSecuritySettingsHelpImg').hide();
		}
	});
</script>

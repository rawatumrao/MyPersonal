<%@ page import="tcorej.*"%>
<%@include file="/include/globalinclude.jsp"%>
<%
//generate pfo and ufo
PFO pfo = new PFO(request);
UFO ufo = new UFO(request);

AdminUser admin = AdminUser.getInstance(ufo.sUserID);
Event event = Event.getInstance(pfo.iEventID);

pfo.sMainNavType = "secureonly";
pfo.secure();
pfo.setTitle("Save Template");

PageTools.cachePutPageFrag(pfo.sCacheID, pfo);
PageTools.cachePutUserFrag(ufo.sCacheID, ufo);

String pageName = StringTools.n2s(request.getParameter("page"));
%>
<jsp:include page="/admin/headertop.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>
<style>
    .pageContent{
        width: auto !important;
        height: auto !important;
        top: 20px !important;
        bottom: 20px !important;
    }
    
	.main{
	    display: flex;
	    justify-content: flex-start;
	    align-items: center;
	    flex-direction: column;
	    margin: 15px 0 0 0;
	    height: 485px;
	    overflow: auto;
	}
	
	.templatesHdr{
	    text-align: left;
	    width: 92%;
	}
	
	.buttons{
	    display: flex;
        width: 95%;
    	justify-content: center;
 	    margin: 20px 0 0 0;
	}
	
	.cancelBtn,
	.saveBtn{
	    margin: 0 5px !important;;
	}
	
	.header{
		margin: 0 0 15px;
    	width: 93%;
    }
    
    .templateItems{
        display: none;
        width: 93%;
        cursor: pointer;
        margin-left: 45px;
    }
    
    .templateItems__item{
    	display: flex;
    	align-items: center;
    }
    
    .templateItems__radioBtn{
   		margin: 5px;
    }
    
    .templateItems__title{
        cursor: pointer;
    }
    
    .redBtn{
        background-color: red !important;
    }
    
    .redBtn:hover{
    	opacity: .7;
    }
    
	.saveMain{
	    display: flex;
	    justify-content: center;
	    align-items: center;
	    flex-direction: column;
	    margin: 15px 0 0 0;
	}
	
	.title{
	    width: 90%;
	    margin: 0 0 10px 0;
	}
    
    .radioBtns{
        width: 95%;
    }
    
    .manage{
    	height: 530px;
    }
    
    .manage .templateItems__item{
	    padding: 5px 0px;
	    border-bottom: 1px dotted #ccc;
    }
    
    .manage .templateItems__title,
    .manage .templateItems__editTxtBx{
    	width: 565px;
    	margin-right: 5px;
    }
    
    .manage .myTeamEditBtn{
    	margin: 0 10px;
    }
    
    .manage .templateItems__updateTemplateBtn{
        margin: 0 5px
    }
    
    .manage .templateItems__tableHdr{
    	width: 565px;
    	margin-right: 10px;
	}
	
	.manage .templateItems__editTxtBx,
	.manage .templateItems__updateTemplateBtn,
	.manage .buttons,
	.templateItems__cancelTemplateBtn{
	    display: none;
	}
	
	.manage .circleBtns{
	    cursor: pointer;
	}
	
	.hideOpacity{
	    opacity: 0%;
	}
	
	.displayNone{
	    display: none;
	}
	
	.greyBG{
	    background-color: #666 !important;
	}
	
	.zeroMyTemplates,
	.zeroSharedTemplates{
		display: none;
	    margin-left: 15px;
	    width: 93%;
    	cursor: pointer;
	}
	
	.zeroMyTemplates_text,
	.zeroSharedTemplates_text{
	    display: flex; 
	    justify-content: center;
	}
</style>
<jsp:include page="/admin/headerbottom.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>

<%if(pageName.equals("view") || pageName.equals("manage")){%>
	<section class="main">
		<h1 class="header">Report Templates</h1>
	    <h3 id="myTemplates" class="templatesHdr">
	    	<span class="arrowClosed">
	    		My Templates
	    	</span>
	    </h3>
	    <div id="templateItems" class="templateItems">
	    	<div id="zeroMyTemplates" class="zeroMyTemplates">
  		    	<h3 class="zeroMyTemplates_text">
	    			No private reporting templates have been created.
	    		</h3>
	    	</div>
	    </div>
	    <h3 id="sharedTemplates" class="templatesHdr sharedTemplatesHdr displayNone">
	    	<span class="arrowClosed">
	    		Team Templates
	    	</span>
	    </h3>
	    <div id="sharedTemplateItems" class="templateItems">
	    	<div id="zeroSharedTemplates" class="zeroSharedTemplates">
  		    	<h3 class="zeroSharedTemplates_text">
	    			No reporting templates have been shared by your team.
	    		</h3>
	    	</div>
		</div>
	</section>
<%}else{%>
	<section class="saveMain">
		<%if(pageName.equals("newSave")){%>
			<h1 class="header">Save as New Template</h1>
		<%}else{%>
			<h1 class="header">Save Changes</h1>
		<%}%>
		<input id="title" class="title" type="text" placeholder="Title" maxlength="90"></input>
		<div id="radioBtns" class="radioBtns hideOpacity">
			<input id="privateRadioBtn" class="privateRadioBtn" type="radio" name="sharedOrPrivate">Private</input>
			<input id="sharedRadioBtn" class="sharedRadioBtn" type="radio" name="sharedOrPrivate">Shared</input>
		</div>
	</section>
<%}%>

<%if(!pageName.equals("manage")){%>
 <div class="buttons">
 	<button id="cancelBtn" class="cancelBtn button">Cancel</button>
 	<%if(pageName.equals("view")){%>
 		<button id="appplyBtn" class="saveBtn button hideMe buttonLarge buttonCreate">Load Selected Template</button>
 	<%}else{%>
 		<button id="saveBtn" class="saveBtn button buttonSave hideMe">Save</button>
 	<%}%>
 </div>
<%}%>

<jsp:include page="/admin/footertop.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
	<jsp:param name="hidecopyright" value="1"/>
	<jsp:param name="hideconfidentiality" value="1"/>
</jsp:include>
<script type="text/javascript">
	$(document).ready(function() {
		var pageName = "<%=pageName%>";
		
		$('#cancelBtn').on('click', function(){
			parent.$('.fancybox-close').click();
		});
		
		if(pageName === "view"){
			$('#appplyBtn, #deleteBtn').on('click', function(){
				if($('input[name=template]:checked', '.main').length > 0){
					var templateID = $('input[name=template]:checked')[0].getAttribute('data-template-id');
					parent.getReportTemplate(templateID);
				 	parent.$('.fancybox-close').click();
				}else{
					parent.$.alert('No Template Selected.', '', 'icon_alert.png');
				}	
			});
			
			if(parent.isGuestPresenter === true){
				$('#myTemplates').hide();
			}else{
				appendReportTemplates('templateItems', parent.getReportTemplateSelectionsData.reportTemplates);	
			}
			
			if( (parent.adminHasLicense === true && parent.adminIsSuperUser === false) || parent.isGuestPresenter === true) {
				console.log("Append shared report templates; shared template count=" + parent.getReportTemplateSelectionsData.sharedTemplates.length);
				$('#sharedTemplates').removeClass('displayNone');
				appendReportTemplates('sharedTemplateItems', parent.getReportTemplateSelectionsData.sharedTemplates);
			}
			
			$('#myTemplates').on('click', function(){
			    $("#templateItems").toggle();	
			    $('#myTemplates span.arrowClosed').toggleClass('arrowOpened');
			});
			
			$('#sharedTemplates').on('click', function(){
			    $("#sharedTemplateItems").toggle();	
			    $('#sharedTemplates span.arrowClosed').toggleClass('arrowOpened');
			});
			
			$('#myTemplates').click();
		}else{
			document.getElementById('privateRadioBtn').checked = true;
			
			if(parent.adminHasLicense === true){
				$('.radioBtns').removeClass('hideOpacity');
			}else{
				document.getElementById("privateRadioBtn").disabled = true;
				document.getElementById("sharedRadioBtn").disabled = true;
			}
			
			$('#saveBtn').on('click', function(){
				var title = document.getElementById('title').value;
				
				var isSharedBoolean = ($('#sharedRadioBtn').prop('checked')) ? true : false;
				
				if(title.length > 0){
					var templateName = title;
					parent.saveReportTemplate(templateName, isSharedBoolean);
					
					if(parent.document.getElementById('view_report_template_button').disabled === true){
						parent.document.getElementById('view_report_template_button').disabled = false;
						parent.$('#view_report_template_button').removeClass('disabledButton');
					}
					
					parent.loadedTemplateInfo = {
							"templateId" : "",
							"description" : title,
							"isShared" : isSharedBoolean,
							"adminId" : parent.sUserID
					}
					
					parent.enableSaveChangesBtn();
					parent.getNewlyCreatedTemplateID();
					parent.$('.fancybox-close').click();		
				}else{
					$('#title').addClass("error");
				}
			});
		}
	});
	
	function appendReportTemplates(appendDiv, report){
		if(report.length === 0){
			if(appendDiv === 'templateItems'){
				$('#zeroMyTemplates').show();
			}else if(appendDiv === 'sharedTemplateItems'){
				$('#zeroSharedTemplates').show();
			}else{
				consoel.log('Error in appendReportTemplates function');
			}			
			
			$('.main').addClass('manage');
		}else{
			for(var x = 0; x < report.length; x++){
		    	var div = document.createElement("div");  
		    	div.className = "templateItems__item " + report[x].templateId + "";
				
		    	if(appendDiv === 'templateItems'){
			    	if(parent.adminHasLicense === true && parent.adminIsSuperUser === false) { // && parent.isGuestPresenter === false){
			    		div.innerHTML = '<input id="input_' + report[x].templateId + '" class="templateItems__radioBtn" type="radio" name="template" data-template-id="' + report[x].templateId + '"><label id="templateItems__title" class="templateItems__title" for="input_' + report[x].templateId + '">' + report[x].description + '</label><input type="text" class="templateItems__editTxtBx" maxlength="90" value="' + report[x].description + '"><button id="cancelTemplateBtn" class="templateItems__cancelTemplateBtn circleBtns redCloseBtn greyBG" title="Cancel Editing Template" onclick="cancelEdit(\'' + report[x].templateId + '\')"></button><div class="toggle toggle-light" data-toggle-on="' + report[x].isShared + '"  onClick="updateTemplateOnToggleChange(\'' + report[x].templateId + '\')"></div><button id="templateItems__editTemplateBtn" class="circleBtns myTeamEditBtn templateItems__editTemplateBtn" title="Edit Template Name" onClick="editTemplateBtn(\'' + report[x].templateId + '\')""></button><button id="templateItems__updateTemplateBtn" class="button templateItems__updateTemplateBtn" onclick="updateTemplate(\'' + report[x].templateId + '\')">Save</button><button id="deleteTemplateBtn" class="deleteBtn circleBtns redCloseBtn" title="Delete Template" onClick="deleteTemplateBtn(\'' + report[x].templateId + '\',\'' + report[x].description + '\')"></button>';
			    	}else{
			    		div.innerHTML = '<input id="input_' + report[x].templateId + '" class="templateItems__radioBtn" type="radio" name="template" data-template-id="' + report[x].templateId + '"><label id="templateItems__title" class="templateItems__title" for="input_' + report[x].templateId + '">' + report[x].description + '</label><input type="text" class="templateItems__editTxtBx" maxlength="90" value="' + report[x].description + '"><button id="cancelTemplateBtn" class="templateItems__cancelTemplateBtn circleBtns redCloseBtn greyBG" title="Cancel Editing Template" onclick="cancelEdit(\'' + report[x].templateId + '\')"></button><div class="toggle toggle-light hideOpacity" data-toggle-on="' + report[x].isShared + '"></div><button id="templateItems__editTemplateBtn" class="circleBtns myTeamEditBtn templateItems__editTemplateBtn" title="Edit Template Name" onClick="editTemplateBtn(\'' + report[x].templateId + '\')""></button><button id="templateItems__updateTemplateBtn" class="button templateItems__updateTemplateBtn" onclick="updateTemplate(\'' + report[x].templateId + '\')">Save</button><button id="deleteTemplateBtn" class="deleteBtn circleBtns redCloseBtn" title="Delete Template" onClick="deleteTemplateBtn(\'' + report[x].templateId + '\',\'' + report[x].description + '\')"></button>';
			    	}
				}else{
			    	div.innerHTML = '<input id="input_' + report[x].templateId + '" class="templateItems__radioBtn" type="radio" name="template" data-template-id="' + report[x].templateId + '"><label id="templateItems__title" class="templateItems__title" for="input_' + report[x].templateId + '">' + report[x].description + '</label>';	
				}

				document.getElementById(appendDiv).appendChild(div);  	

		    	$('.toggle').toggles({
	    		  text: {
	    		    on: 'SHARED', // text for the ON position
	    		    off: 'PRIVATE' // and off
	    		  },
	    		  width: 75, // width used if not set in css
	    		  height: 20, // height if not set in css
	    		});
		    	
		    	$('.main').addClass('manage');
			}		
		}
	}
	
	function updateTemplateOnToggleChange(templateId){
		var templateName = $('.' + templateId +' .templateItems__editTxtBx')[0].value;
		
		setTimeout(function(){
			var isSharedBoolean = $('.' + templateId +' .toggle').data('toggles').active? "1":"0";
			
			if(parent.loadedTemplateInfo.templateId === templateId){
				parent.loadedTemplateInfo.isShared = isSharedBoolean;
			}
			
			parent.updateReportTemplate(templateId, templateName, parseInt(isSharedBoolean), false);
		}, 1000);
	}
	
	function updateTemplate(templateId){
		var templateName = $('.' + templateId +' .templateItems__editTxtBx')[0].value;
		var isSharedBoolean = $('.' + templateId +' .toggle').data('toggles').active? "1":"0";
		
		if(parent.loadedTemplateInfo.templateId === templateId){
			parent.loadedTemplateInfo.description = templateName;
			parent.document.getElementById('loadedTemplate').innerHTML = '<span style="font-weight: 800;">Loaded Template:</span> ' + templateName + '';
		}
		
		setTimeout(function(){
			parent.updateReportTemplate(templateId, templateName, parseInt(isSharedBoolean), false);
		}, 1000);
		
		$('.' + templateId + ' .templateItems__title').show();
		$('.' + templateId + ' .templateItems__editTxtBx').hide();
		$('.' + templateId + ' .templateItems__editTemplateBtn').show();
		$('.' + templateId + ' .templateItems__updateTemplateBtn').hide();
		$('.' + templateId + ' .templateItems__title')[0].innerText = templateName;
		$('.' + templateId + ' .deleteBtn').show();
		$('.' + templateId + ' .templateItems__cancelTemplateBtn').hide();
	}
	
	function editTemplateBtn(templateId){
		$('.' + templateId + ' .templateItems__title').hide();
		$('.' + templateId + ' .templateItems__editTxtBx').show();
		$('.' + templateId + ' .templateItems__editTemplateBtn').hide();
		$('.' + templateId + ' .templateItems__updateTemplateBtn').show();
		$('.' + templateId + ' .deleteBtn').hide();
		$('.' + templateId + ' .templateItems__cancelTemplateBtn').show();
	}
	
	function cancelEdit(templateId){
		$('.' + templateId + ' .templateItems__title').show();
		$('.' + templateId + ' .templateItems__editTxtBx').hide();
		$('.' + templateId + ' .templateItems__editTemplateBtn').show();
		$('.' + templateId + ' .templateItems__updateTemplateBtn').hide();
		$('.' + templateId + ' .deleteBtn').show();
		$('.' + templateId + ' .templateItems__cancelTemplateBtn').hide();
	}
	
	function deleteTemplateBtn(templateId, templateName){
		var objButton = {
			"No": function(){
				parent.$("#alertDialog").dialog("close");
			},
			"Yes":function(){
				parent.deleteReportTemplates(templateId);
				parent.disabledDeletedLoadedTempalate(templateId);
				
				// disable load template button if no templates exist after deleting 
				if(parent.getReportTemplateSelectionsData.reportTemplates.length === 1 && 
				   templateId === parent.getReportTemplateSelectionsData.reportTemplates[0].templateId &&
				   parent.getReportTemplateSelectionsData.sharedTemplates.length === 0){
						parent.getReportTemplateSelectionsData = "";
						parent.enableLoadTemplateBtn();
						$('#zeroMyTemplates').show();
				}
				
				templateId = "." + templateId;			
				parent.$('.fancybox-iframe').contents().find(templateId).remove()
			}
		};
		
		parent.$.confirm("Are you sure you want to delete " + templateName + " template?","",objButton,"");
				
	}
</script>
<jsp:include page="/admin/footerbottom.jsp">
	<jsp:param name="pfi" value="<%=pfo.sCacheID%>"/>
	<jsp:param name="ufi" value="<%=ufo.sCacheID%>"/>
</jsp:include>

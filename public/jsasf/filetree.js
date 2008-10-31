// vim: sw=4:ts=4:nu:nospell:fdc=4
/**
 * An Application
 *
 * @author    Ing. Jozef Sakáloš
 * @copyright (c) 2008, by Ing. Jozef Sakáloš
 * @date      2. April 2008
 * @version   $Id: filetree.js 37 2008-04-25 17:14:56Z jozo $
 *
 * @license application.js is licensed under the terms of the Open Source
 * LGPL 3.0 license. Commercial use is permitted to the extent that the 
 * code/component(s) do NOT become part of another Open Source or Commercially
 * licensed development library or toolkit without explicit permission.
 * 
 * License details: http://www.gnu.org/licenses/lgpl.html
 */
 
/*global Ext, WebPage, window */

Ext.BLANK_IMAGE_URL = './ext/resources/images/default/s.gif';
Ext.ns('Application');
Ext.state.Manager.setProvider(new Ext.state.CookieProvider);

Ext.onReady(function() {
    Ext.QuickTips.init();

    Ext.form.Field.prototype.msgTarget = 'side';
	// page.langCombo.on('select', function() {document.cookie = 'locale=' + this.getValue();});
	// document.cookie = 'locale=' + page.langCombo.getValue();


	var filepanel = new Ext.ux.FileTreePanel({
		// height:500
		autoWidth:true
		,id:'ftp'
		,title:'FileBrowser'
		// ,renderTo:'treepanel'
		,rootPath:'A'
		,topMenu:false
		,autoScroll:true
		,enableProgress:false
		//	,baseParams:{additional:'haha'}
		//	,singleUpload:true
	
		//user specific
		,enableOpen:true
		,enableUpload:true
		,rootVisible:true
		,url:'tree/getls'		
	});

// var tabpanel = new Ext.TabPanel({
//     region:'center'
//     ,deferredRender:false
//     ,activeTab:0
//     items:[{
//         contentEl:'center',
//         title: 'Center Panel',
//         autoScroll:true
//     }]
// })
Application.FilePanel = Ext.extend(Ext.ux.FileTreePanel, {
     border:false
    ,initComponent:function() {
        Ext.apply(this, {
			// height:500
			autoWidth:true
			,id:'ftp'
			,title:'FileBrowser'
			// ,renderTo:'treepanel'
			,rootPath:'A'
			,topMenu:false
			,autoScroll:true
			,enableProgress:false
			//	,baseParams:{additional:'haha'}
			//	,singleUpload:true

			//user specific
			,enableOpen:true
			,enableUpload:true
			,rootVisible:true
			,url:'tree/getls'
        });
 
        Application.FilePanel.superclass.initComponent.apply(this, arguments);
    } // eo function initComponent
 
    ,onRender:function() {
     	Application.PersonnelGrid.superclass.onRender.apply(this, arguments);
     } // eo function onRender
});
 

Ext.reg('filepanel', Application.FilePanel);


var viewport = new Ext.Viewport({
	layout:'border',
	defaults: {
    	collapsible: true,
    	split: true,
		bodyStyle: 'padding:15px'
	},
	items:[
		// {
		// 	xtype:'filepanel'
		// 	,region:'west'
		// 	,width:200
		// 	,minSize: 100
		// 	,maxSize: 250
		// 	,collapsible:true
		// 	,collapseMode:'mini'
		// 	,split:true
		// // },
		{
		title: 'Navigation',
		region:'west',
		margins: '5 0 0 0',
		cmargins: '5 5 0 0',
		width: 175,
		minSize: 100,
		maxSize: 250,
		layout: 'fit',
		items: filepanel
		},{
		title: 'Main Content',
		collapsible: false,
		region:'center',
		margins: '5 0 0 0'
		}]
	});


});
// eof

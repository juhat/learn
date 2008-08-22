Ext.BLANK_IMAGE_URL = '../ext/resources/images/default/s.gif';
Ext.ns('Learn');

Ext.onReady(function() {
	Ext.QuickTips.init();
 
	
	// var viewport = new Learn.App();
	// viewport.show();
	
	var vp = new Ext.Viewport({
		layout:'border'
		,items:[
			new Ext.BoxComponent({
			region:'north'
			,el: 'lesson_info'
			,cls: 'app-header'
			,height:60
		}),{
			region:'center'
			,xtype:'tabpanel'
			,frame:true
			// ,defaults:{autoHeight: true}
		    ,activeTab: 0
			// ,border:10
		    ,items: [{
		        title: 'File Editor'
			    // ,layout: 'fit'
			 	,xtype: 'editor'
		    },{
		        title: 'Terminal'
				,tabTip:'Unix command shell.'
			 	,xtype: 'terminal'
				// ,layout:'fit'
		    },{
		        title: 'SQL console'
		        ,html: 'Another one'
		    },{
		        title: 'IRB ruby'
		        ,html: 'Another one'
		    },{
		        title: 'script/console'
			 	,xtype: 'terminal'
				,url:'../tree/railsconsole'
		    }]			
		}]
	});
	vp.show();
});
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
			})
			,{
			region:'east'
			,xtype:'panel'
			,width:250
			,frame:true
		 	,autoLoad:{url:'learn/autotest'}
			}
			,{
				region:'center'
				,xtype:'tabpanel'
				,frame:true
			    ,activeTab: 0
			    ,items: [{
			        title: 'File Editor'
				 	,xtype: 'editor'
			    },{
			        title: 'Terminal'
					,tabTip:'Unix command shell.'
				 	,xtype: 'terminal'
			    }
				,{
			        title: 'script/console'
				 	,xtype: 'terminal'
					,url:'learn/console'
		    }]			
		}]
	});
	vp.show();
});
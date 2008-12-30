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
			,width:'30%'
			,split:true
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
			    }
				,{
			        title: 'Linux terminal'
					,tabTip:'Linux command shell'
				 	,xtype: 'terminal'
					,url:'learn/terminal'
			    }
				,{
			        title: 'Rails script/console'
					,tabTip:'The Rails application console'
				 	,xtype:'terminal'
					,url:'learn/console'
		    	}
				,{
			        title: 'Database script/dbconsole'
					,tabTip:'DB SQL console'
				 	,xtype: 'terminal'
					,url:'learn/db'
			    }
			]			
		}]
	});
	vp.show();
});
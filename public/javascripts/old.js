Example.Window = Ext.extend(Ext.Window, { 
	// configurables
	// anything what is here can be configured from outside
	layout:'border'
 	,opened_files:[]
	,initComponent:function() {
		Ext.apply(this, {
			items:[{
					xtype:'linkspanel'
					,region:'west'
					,width:450
					,collapsible:true
					,collapseMode:'mini'
					,split:true
				},{
					xtype:'tabpanel'
					,region:'center'
					,border:false
					,activeItem:0
				}]
		});
		Example.Window.superclass.initComponent.apply(this, arguments);
 
		this.linksPanel = this.items.itemAt(0);
		this.tabPanel = this.items.itemAt(1);	
		
		this.linksPanel.on({
			scope:this
			,render:function() {
				this.linksPanel.body.on({
					scope:this
					,click:this.onLinkClick
					,delegate:'a.examplelink'
					,stopEvent:true
				});
			}
		});
	} 
	,afterRender:function() { 
		// call parent
		Example.Window.superclass.afterRender.apply(this, arguments);
	} 
	,onLinkClick:function(e, t) {
		var title = t.innerHTML;
		var tab = this.opened_files.find(function(s) {
			return s === 'filename: '+title;
	 	});
		if(!tab) {
			tab = this.tabPanel.add({
				title:title
				,layout:'fit'
				,activate:true
				,closable: true
				,tabTip:'filename: '+title
				,listeners: {
					'destroy' : {
						scope:this
						,fn:this.onTabDestroy
					}
				}
			});
			this.opened_files.push('filename: '+title);
		}
		this.tabPanel.setActiveTab(tab);
	}
	,onTabDestroy:function(e,t){
		this.opened_files.remove('filename: '+e.title);
		console.log(this.opened_files);
	}
}); 
Ext.reg('examplewindow', Example.Window);
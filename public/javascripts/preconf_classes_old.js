Learn.LinksPanel = Ext.extend(Ext.Panel, {
	// configurables
	border:false
	,cls:'link-panel'
	,links:[{
		text:'Link 1'
		,href:'#'
		},{
		text:'Link 2'
		,href:'#'
		},{
		text:'Link 3'
		,href:'#'
	}]
	,layout:'fit'
	,tpl:new Ext.XTemplate('<tpl for="links"><a class="examplelink" href="{href}">{text}</a></tpl>') 
	,afterRender:function() {
	Learn.LinksPanel.superclass.afterRender.apply(this, arguments);
	this.tpl.overwrite(this.body, {links:this.links});
	}	 
});
Ext.reg('linkspanel', Learn.LinksPanel);

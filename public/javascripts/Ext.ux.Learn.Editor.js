Ext.ns('Learn');

Learn.FilePanel = Ext.extend(Ext.ux.FileTreePanel, {
    border:false
	,url:'learn/filepanel'
	,rootPath:'testproject'
	,rootText:'Website'

    ,initComponent:function() {
        Ext.apply(this, {
			title:'File Browser'
			,topMenu:false
			,autoScroll:true
			,enableProgress:false
			,enableUpload:false
        });
        Learn.FilePanel.superclass.initComponent.apply(this, arguments);
    }
});
Ext.reg('filepanel', Learn.FilePanel);

Learn.EditorForm = Ext.extend(Ext.form.FormPanel, {
	url:'learn/file'
	,file:''
	
    ,initComponent:function() {
        Ext.apply(this, {
		    border:false
			,frame:true
			,items:[{
				xtype:'textarea'
				,name:'note'
				,fieldLabel:'Note'
				,hideLabel:true
				,height:'100%'
				,anchor:'100% 100%'
			}]
			,buttons:[{
				 text:'I am ready! Let\'s SAVE the file!'
				,formBind:true
				,scope:this
				,handler:this.onSubmit
			}]
        });
        Learn.EditorForm.superclass.initComponent.apply(this, arguments);
		
		Ext.Ajax.request({
			url: this.url
			,scope: this
			,params: { 
				cmd: 'load'
				,path: this.file
			}
			,success: function(a,b){
				this.items.itemAt(0).setValue(a.responseText);
			}
		    ,failure: function(){
				alert('File not found!')
			}
		});
    }
    ,onRender:function() {
	    Learn.EditorForm.superclass.onRender.apply(this, arguments);
		// this.getForm().waitMsgTarget = this.getEl();
    }
	,onSubmit:function() {
		this.getForm().submit({
			 url:this.url
			,scope:this
			,success:this.findParentByType('viewport').items.itemAt(1).getUpdater().refresh()
			,failure:function(){alert('File cant saved!');}
			,params:{
				cmd:'save'
				,path: this.file
			}
			,waitMsg:'Saving...'
		});
	}
}); 
Ext.reg('editorform', Learn.EditorForm);

Learn.Editor = Ext.extend(Ext.Panel, {
	initComponent:function() {
		Ext.apply(this, {
			layout:'border'
		 	,opened_files:[]
			,items:[{
					xtype:'filepanel'
					,region:'west'
					,width:200
					// ,collapsible:true
					// ,collapseMode:'mini'
					,split:true
				},{
					xtype:'tabpanel'
					,region:'center'
					,border:false
					,activeTab:0
					,items:[{
						title:'Read me'
						,closable:false
						,autoLoad:'learn/readme'
					}]
				}]	
		});
		Learn.Editor.superclass.initComponent.apply(this, arguments);
		
		this.filePanel = this.items.itemAt(0);
		this.tabPanel = this.items.itemAt(1);
		
		this.filePanel.on({
			'beforeopen':{
				scope:this
				,fn:this.onFileOpen
			}
		});
	}
	,afterRender:function() { 
		Learn.Editor.superclass.afterRender.apply(this, arguments);
	} 
	,onFileOpen:function(obj,title,path){
        if (path.match(/([^\/\\]+)\.(gif|jpg|png|avi|pdf)$/i) ){
			alert('This is an image! It cant opened here.')
			return false;
		}
		
		// console.log(obj);
		// console.log(title);
		// console.log(path);
	
		var tab = this.opened_files.find(function(s) {
			return s === path;
	 	});
		if(!tab) {
			tab = this.tabPanel.add({
				title:title
				,layout:'fit'
				,activate:true
				,closable: true
				,tabTip:path
				,listeners: {
					'destroy' : {
						scope:this
						,fn:this.onTabDestroy
					}
				}
				,items:[{
			            xtype: 'editorform'
						,layout:'fit'
						,file:path
				}]
			});
			this.opened_files.push(path);
		}
		this.tabPanel.setActiveTab(tab);
		return false;
	}
	,onTabDestroy:function(e,t){
		this.opened_files.remove(e.tabTip);
	}
});
Ext.reg('editor', Learn.Editor);
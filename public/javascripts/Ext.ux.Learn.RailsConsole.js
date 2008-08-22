Ext.ns('Learn');

Learn.RailsConsole = Ext.extend(Ext.Panel, {
	url:'../tree/railsconsole'

    ,initComponent:function() {
        Ext.apply(this, {
		    border:false
					,xtype:'form'
					// ,border:false
					// ,frame:true
					,items:[{
						xtype:'textarea'
						,name:'railsconsole-output'
						,hideLabel:true
						,width:'100%'
						,height:'80%'
						,disabled:true
					},{
						xtype:'textfield'
						,name:'rcommand'
						// ,fieldLabel:'terminal'
						,hideLabel:true
						,width:'100%'
						
						// ,height:'22'
						// ,anchor:'100% 80%'
					}]
					,buttonAlign:'left'
					,buttons:[{
						text:'Go go go!'
						,formBind:true
						,scope:this
						,handler:this.onSubmit
					}]
        });
        Learn.RailsConsole.superclass.initComponent.apply(this, arguments);
    }
	,onSubmit:function() {
		console.log(this.items.itemAt(1).getValue());

		Ext.Ajax.request({
			url: this.url
			,scope: this
			,params:{
				command: this.items.itemAt(1).getValue()
			}
			,success: function(a,b){
				var text = this.items.itemAt(0).getValue();
				this.items.itemAt(0).setValue(a.responseText + "\n\n" +text);
			}
		    ,failure: function(){
				alert('Problem with terminal functionaliti.')
			}
		});
	}
});
Ext.reg('railsconsole', Learn.RailsConsole);

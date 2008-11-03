Ext.ns('Learn');

Learn.Terminal = Ext.extend(Ext.FormPanel, {
	url:'../tree/terminal'

    ,initComponent:function() {
        Ext.apply(this, {
		    border:false

			,labelWidth:70
			,bodyStyle:'padding:15px'
			,frame:true
			,items:[{
				 xtype:'textarea'
				,fieldLabel:'Output'
				,readOnly:true
				// ,name:'f_message'
				,anchor:'-15 85%'
			},{
				 xtype:'textfield'
				,fieldLabel:'Command'
				// ,name:'f_to'
				// ,value:''
				,anchor:'-15'

			}]
			,buttonAlign:'left'
			,buttons:[{
				text:'Go go go!'
				,formBind:true
				,scope:this
				,handler:this.onSubmit
			}]
        });
        Learn.Terminal.superclass.initComponent.apply(this, arguments);
    }
	,onSubmit:function() {
		console.log(this.items.itemAt(1).getValue());

		Ext.Ajax.request({
			url: this.url
			,scope: this
			,params:{
				command: this.items.itemAt(1).getValue()
				,user_token: 'retek'
			}
			,success: function(a,b){
				var text = this.items.itemAt(0).getValue();
				this.items.itemAt(0).setValue(a.responseText + "\n" + text);
				this.findParentByType('viewport').items.itemAt(1).getUpdater().refresh()
			}
		    ,failure: function(){
				alert('Problem with terminal functionaliti.')
			}
		});
	}
});
Ext.reg('terminal', Learn.Terminal);

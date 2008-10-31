// vim: ts=4:sw=4:nu:fdc=4:nospell
/**
 * Ext.ux.tree.ArrayTree - Tree with nodes from array
 *
 * @author    Ing. Jozef Sakáloš
 * @copyright (c) 2008, by Ing. Jozef Sakáloš
 * @date      10. April 2008
 * @version   $Id: Ext.ux.tree.ArrayTree.js 178 2008-04-14 12:21:08Z jozo $
 *
 * @license Ext.ux.tree.ArrayTree.js is licensed under the terms of the Open Source
 * LGPL 3.0 license. Commercial use is permitted to the extent that the 
 * code/component(s) do NOT become part of another Open Source or Commercially
 * licensed development library or toolkit without explicit permission.
 * 
 * License details: http://www.gnu.org/licenses/lgpl.html
 */
 
/*global Ext */

Ext.ns('Ext.ux.tree');
 
/**
 * @class Ext.ux.tree.ArrayTree
 * @extends Ext.tree.TreePanel
 */
Ext.ux.tree.ArrayTree = Ext.extend(Ext.tree.TreePanel, {

	// {{{
    // configurables
	collapseAllText:'Collapse All'
	
	/**
	 * @cfg {Object} defaultRootConfig Default configuration of root node 
	 * @private
	 */
    ,defaultRootConfig:{
		 loaded:true
		,expanded:true
		,leaf:false
		,id:Ext.id()
	}

	/**
	 * @cfg {Boolean} defaultTools true to create Expand All/Collapse All tools
	 */
	,defaultTools:true

	,expandAllText:'Expand All'

	/**
	 * @cfg {Object} expandedNodes keeps currently expanded nodes paths for state keeping
	 * @private
	 */
	,expandedNodes:{}

	/**
	 * @cfg {Object} rootConfig Configuration for the root node
	 */ 

	/**
	 * @cfg {Object} stateEvents allows us to keep expanded state
	 * @private
	 */
	,stateEvents:['expandnode', 'collapsenode']
	// }}}
	// {{{
	/**
	 * initialize component
	 * @private
	 */
    ,initComponent:function() {
        
		// create root config
		var cfg = Ext.apply(this.defaultRootConfig, this.rootConfig, {children:this.children});

		// configure ourselves
        Ext.apply(this, {
			 root:new Ext.tree.AsyncTreeNode(cfg)
			,loader: new Ext.tree.TreeLoader({preloadChildren:true, clearOnLoad:false})
			,sorter:this.sort ? new Ext.tree.TreeSorter(this) : undefined
        }); // e/o apply

		if(this.defaultTools) {
			Ext.apply(this, {
				tools:[{
					 id:'minus'
					,qtip:this.collapseAllText
					,scope:this
					,handler:this.collapseAll
				},{
					 id:'plus'
					,qtip:this.expandAllText
					,scope:this
					,handler:this.expandAll
				}]
			});
		}
        
        // call parent
        Ext.ux.tree.ArrayTree.superclass.initComponent.apply(this, arguments);

		// handle expanded/collapsed state for state keeping
		if(false !== this.stateful) {
			this.on({
				 scope:this
				,beforeexpandnode:this.beforeExpandNode
				,beforecollapsenode:this.beforeCollapseNode
			});
		}
 
    } // e/o function initComponent
	// }}}
	// {{{
	/**
	 * restores tree state (expands nodes)
	 * @private
	 */
	,afterRender:function() {
		// call parent
		Ext.ux.tree.ArrayTree.superclass.afterRender.apply(this, arguments);

		// restore tree state
		for(var id in this.expandedNodes) {
			if(this.expandedNodes.hasOwnProperty(id)) {
				this.expandPath(this.expandedNodes[id]);
			}
		}
	} // eo function onRender
	// }}}
	// {{{
	/**
	 * saves path of the node
	 * @private
	 */
	,beforeExpandNode:function(n) {
		if(n.id) {
			this.expandedNodes[n.id] = n.getPath();
		}
	} // eo function beforeExpandNode
	// }}}
	// {{{
	/**
	 * deletes expanded state
	 */
	,beforeCollapseNode:function(n) {
		if(n.id) {
			delete(this.expandedNodes[n.id]);
			n.cascade(function(child) {
				if(child.id) {
					delete(this.expandedNodes[child.id]);
				}
			}, this);
		}
	} // eo function beforeCollapseNode
	 // }}}
	// {{{
	/**
	 * returns the expandedNodes hash
	 * @private
	 */
	,getState:function() {
		return {expandedNodes:this.expandedNodes};
	} // eo function getState
	// }}}

}); // eo extend
 
// register xtype
Ext.reg('arraytree', Ext.ux.tree.ArrayTree); 
 
// eof

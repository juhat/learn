
ExtScaffold.Post = Ext.extend(Ext.Panel, {
  //
  // static text properties (override for i18n)
  //
  labels: {
     'id': '#'
    ,'post[title]': 'Title'
    ,'post[body]': 'Body'
    ,'post[published]': 'Published'
  },
  title: 'Posts',
  newButtonLabel: 'New...',
  newButtonTooltip: 'Create new Post',
  editButtonLabel: 'Edit...',
  editButtonTooltip: 'Edit selected Post',
  selectRowText: 'Please select a row first.',
  deleteButtonLabel: 'Delete...',
  formToggleButtonLabel: 'Details',
  formToggleButtonTooltip: 'Show / Hide Details',
  deleteButtonTooltip: 'Delete selected Post...',
  deleteConfirmationText: 'Really delete?',
  deleteFailedText: 'Delete operation failed. The record might have been deleted by someone else.',
  paginationStatusTemplate: 'Record {0} - {1} of {2}',
  paginationNoRecordsText: 'No records found',
  savingMessage: 'Saving...',
  saveFailedText: 'Save operation failed. The record might have been deleted by someone else.',

  //
  // custom properties
  //
  url: '#',
  baseParams: {},
  recordsPerPage: 50,

  //
  // private properties
  //
  formPanelWasCollapsed: true,
  selectedRecordId: undefined,

  // defaults for (superclass) config
  layout: 'border',
  border: false,
  cls:    'ext-scaffold',
  
  //
  // public instance methods
  //
  activateGrid: function() {
    var gp = this.getGridPanel();
    var gv = gp.getView();
    var ds = this.getStore();
    
    gp.enable();

    if (this.formPanelWasCollapsed) this.getFormPanel().collapse();

    // give focus to the grid to enable up/down keys
    if (ds.getCount() > 0) {
      if (this.selectedRecordId) {
        var matchingRecords = ds.query('id', this.selectedRecordId);
        if (matchingRecords) {
          gv.focusRow(ds.indexOf(matchingRecords.first())); // focus selected row
        } else {
          gv.focusRow(0); // no matching selection -> focus first row
        }
      } else {
        gv.focusRow(0); // no selection at all -> focus first row
      }
    }
  },
  
  activateForm: function(mode) {
    var fp = this.getFormPanel();

    fp.setFormMode(mode);

    this.formPanelWasCollapsed = fp.collapsed;
    if (fp.collapsed) fp.expand();

    fp.setWidth(fp.initialConfig.width, true);
    this.doLayout(); // re-render border layout to reflect current form width

    if(mode == 'new' || mode == 'edit') {
      this.getGridPanel().disable(); // make new and edit modal by disabling the gridPanel
       // focus first form field -- we need a delay here to allow processing of expand()
      fp.getForm().findField('post[title]').focus(true, 400);
    }
  },
  
  getGridPanel: function() {
    return Ext.getCmp('post-grid');
  },
  
  getFormPanel: function() {
    return Ext.getCmp('post-form');
  },
  
  getStore: function() {
    return this.getGridPanel().getStore();
  },
  
  resetForm: function(activateGrid) {
    var fp = this.getFormPanel();
    fp.getForm().reset();
    fp.setFormMode('show');
    if (activateGrid) this.activateGrid();
  },
  
  reloadStore: function(resetForm) {
    this.getStore().reload();
    if (resetForm) this.resetForm(true);
  },
  
  refreshFormToggle: function() {
    Ext.getCmp('post-form-toggle').toggle(!this.getFormPanel().collapsed);
  },
  
  //
  // initComponent
  //
  initComponent: function() {
    var scaffoldPanel = this; // save scope for later reference

    var ds = new Ext.data.Store({
      proxy: new Ext.data.HttpProxy({
                 url: scaffoldPanel.url + '?format=ext_json',
                 method: 'GET'
             }),
      reader: new Ext.data.JsonReader({
                  root: 'posts',
                  id: 'id',
                  totalProperty: 'results'
              },[
                { name: 'id', mapping: 'post.id' }
                ,{ name: 'post[title]', mapping: 'post.title' }
                ,{ name: 'post[body]', mapping: 'post.body' }
                ,{ name: 'post[published]', mapping: 'post.published', type: 'boolean' }
              ]),
        remoteSort: true, // turn on server-side sorting
        sortInfo: {field: 'id', direction: 'ASC'}
    });

    var cm = new Ext.grid.ColumnModel([
       {id: 'id', header: scaffoldPanel.labels['id'], width: 40, dataIndex: 'id'}
      ,{ header: scaffoldPanel.labels['post[title]'], dataIndex: 'post[title]' }
      ,{ header: scaffoldPanel.labels['post[body]'], dataIndex: 'post[body]' }
      ,{ header: scaffoldPanel.labels['post[published]'], dataIndex: 'post[published]' }
    ]);

    cm.defaultSortable = true; // all fields are sortable by default
    
    // button handlers
    
    function addButtonHandler() {
      scaffoldPanel.selectedRecordId = undefined;
      scaffoldPanel.activateForm('new');
      scaffoldPanel.getFormPanel().getTopToolbar().hide();
    }

    function editButtonHandler() {
      var selected = scaffoldPanel.getGridPanel().getSelectionModel().getSelected();
      if(selected) {
        scaffoldPanel.activateForm('edit');
      } else { 
        alert(scaffoldPanel.selectRowText);
      }
    }
    
    function deleteButtonHandler() {
      var selected = scaffoldPanel.getGridPanel().getSelectionModel().getSelected();
      if(selected) {
        if(confirm(scaffoldPanel.deleteConfirmationText)) {
           var conn = new Ext.data.Connection({
             extraParams: scaffoldPanel.baseParams
           });
           conn.request({
               url: scaffoldPanel.url + '/' + selected.data.id,
               method: 'POST',
               params: { _method: 'DELETE' },
               success: function(response, options) {
                 scaffoldPanel.reloadStore(true);
               },
               failure: function(response, options) {
                 // the delete probably failed because the record is already gone, so let's reload the store
                 scaffoldPanel.reloadStore(true);
                 alert(scaffoldPanel.deleteFailedText);
               }
           });
        }
      } else { 
        alert(scaffoldPanel.selectRowText);
      }
    }
    
    Ext.apply(this, {
      items: [{
        // add the grid panel to center region
        region: 'center',
        xtype: 'grid',
        id: 'post-grid',
        ds: ds,
        cm: cm,
        sm: new Ext.grid.RowSelectionModel({
          singleSelect:true,
          listeners: {
            // populate form fields when a row is selected
            'rowselect': function(sm, row, rec) {
              scaffoldPanel.selectedRecordId = rec.data.id;
              scaffoldPanel.getFormPanel().getForm().loadRecord(rec);
            }
          }
        }),
        stripeRows: true,

        // inline toolbars
        tbar: [
          {
              text:    scaffoldPanel.newButtonLabel,
              tooltip: scaffoldPanel.newButtonTooltip,
              handler: addButtonHandler,
              iconCls: 'add'
          },{
              text:    scaffoldPanel.editButtonLabel,
              tooltip: scaffoldPanel.editButtonTooltip,
              handler: editButtonHandler,
              iconCls: 'edit'
          },{
              text:    scaffoldPanel.deleteButtonLabel,
              tooltip: scaffoldPanel.deleteButtonTooltip,
              handler: deleteButtonHandler,
              iconCls: 'remove'
          }, '->', {
            id: 'post-form-toggle',
            iconCls: 'details',
            text:    scaffoldPanel.formToggleButtonLabel,
            tooltip: scaffoldPanel.formToggleButtonTooltip,
            enableToggle: true,
            handler: function() {
              scaffoldPanel.getFormPanel().toggleCollapse();
            }
          }, '->'
        ],
        bbar: new Ext.PagingToolbar({
                  pageSize: scaffoldPanel.recordsPerPage,
                  store: ds,
                  displayInfo: true,
                  displayMsg: scaffoldPanel.paginationStatusTemplate,
                  emptyMsg:   scaffoldPanel.paginationNoRecordsText
        }),
        plugins:[new Ext.ux.grid.Search({
                    position:'top'
                })],
        listeners: {
          // show form with record on double-click
          'rowdblclick': function(grid, row, e) { scaffoldPanel.activateForm('show'); }
        }

      },{

        // add the form to east region
        region: 'east',
        xtype: 'extscaffoldform',
        id: 'post-form',
        width: 340,
        collapseMode: 'mini',
        collapsed: true,
        collapsible: true,
        titleCollapse: false,
        hideCollapseTool: true,
        border: false,
        frame: true,
        listeners: {
          // update form-toggle button with new pressed/depressed state
          'expand':   function() { scaffoldPanel.refreshFormToggle(); },
          'collapse': function() { scaffoldPanel.refreshFormToggle(); },

          // prevent collapse when grid is disabled
          'beforecollapse': function() { return !scaffoldPanel.getGridPanel().disabled; }
        },

        tbar: new Ext.Toolbar({
          hideMode: 'visibility',
          items: ['->',
            {
              tooltip: scaffoldPanel.editButtonTooltip,
              handler: editButtonHandler,
              iconCls:'edit'
            },{
              tooltip: scaffoldPanel.deleteButtonTooltip,
              handler: deleteButtonHandler,
              iconCls:'remove'
            }
          ]
        }),

        baseParams: scaffoldPanel.baseParams,
        items: [
        { fieldLabel: scaffoldPanel.labels['post[title]'], name: 'post[title]', xtype: 'textfield' },
        { fieldLabel: scaffoldPanel.labels['post[body]'], name: 'post[body]', xtype: 'textarea' },
        { fieldLabel: scaffoldPanel.labels['post[published]'], name: 'post[published]', xtype: 'checkbox', inputValue: '1' }, { xtype: 'hidden', name: 'post[published]', value: '0' }
        ],

        onOk: function() {
          var selected = scaffoldPanel.getGridPanel().getSelectionModel().getSelected();

          var submitOptions = {
            url: scaffoldPanel.url,
            waitMsg: scaffoldPanel.savingMessage,
            params: { format: 'ext_json' },
            success: function(form, action) {
              // remember assigned record id (relevant when creating new records,
              // will match the known record id otherwise)
              scaffoldPanel.selectedRecordId = action.result.data['post[id]'];
              scaffoldPanel.reloadStore(true);
            },
            failure: function(form, action) {
              switch (action.failureType) {
                case Ext.form.Action.CLIENT_INVALID:
                case Ext.form.Action.SERVER_INVALID:
                  // validation errors are handled by the form, so we ignore them here
                  break;
                case Ext.form.Action.CONNECT_FAILURE:
                case Ext.form.Action.LOAD_FAILURE:
                  // these might be 404 Not Found or some 5xx Server Error
                  alert(scaffoldPanel.saveFailedText);
                  break;
              }
            }
          };

          scaffoldPanel.getFormPanel().getTopToolbar().show();

          if (scaffoldPanel.getFormPanel().currentMode == 'edit') {
            // set up request for Rails create action
            submitOptions.params._method = 'PUT';
            submitOptions.url = submitOptions.url + '/' + selected.data.id;
          }
          scaffoldPanel.getFormPanel().getForm().submit(submitOptions);
        },

        onCancel: function() {
          var sm = scaffoldPanel.getGridPanel().getSelectionModel();
          var fp = scaffoldPanel.getFormPanel();

          scaffoldPanel.getFormPanel().getTopToolbar().show();
          scaffoldPanel.activateGrid();
          
          // cancel from show mode should always collapse the form-panel (button label: Close)
          if (fp.currentMode == 'show') fp.collapse();
          
          fp.setFormMode('show');
          if (sm.hasSelection()) {
            fp.getForm().loadRecord(sm.getSelected()); // reload previous record version
          } else {
            fp.getForm().reset();
          }
        }
      }]
    });
    
    // try to re-establish selection after datastore load
    ds.on('load', function() {
      if (this.selectedRecordId) {
        var matchingRecords = ds.query('id', this.selectedRecordId);
        if (matchingRecords && matchingRecords.length > 0) {
          this.getGridPanel().getSelectionModel().selectRecords([matchingRecords.first()]);
        } else {
          this.selectedRecordId = undefined; 
          this.resetForm(false);
        }
      }
    }, this);
    
    // make sure form toggle reflects form collapsed state even on initial load
    ds.on('load', function() {
      this.refreshFormToggle();
      this.resetForm(true);
    }, this, { single:true });

    ExtScaffold.Post.superclass.initComponent.apply(this, arguments);
  },
  
  onRender: function() {
    ExtScaffold.Post.superclass.onRender.apply(this, arguments);

    // reset form and trigger initial data load
    this.getStore().load({params: {start: 0, limit: this.recordsPerPage} });
  }
});


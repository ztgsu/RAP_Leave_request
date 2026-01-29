@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request attachements view'
@UI: { 
headerInfo: {
typeName: 'Attachment',
typeNamePlural: 'Attachment',
title:       { type: #STANDARD, value: 'ReqId' },
description: { type: #STANDARD, value: 'ReqId' } 
            }
            ,
         presentationVariant: [{
         sortOrder: [{ by: 'LastChangedAt', direction: #ASC }],
         visualizations: [{type: #AS_LINEITEM}] 
         }] 
      }
define view entity ZC_leave_req_att 
  as projection on zi_leave_req_att
{
@UI.facet: [    {
                 label: 'General Information',
                 id: 'GeneralInfo',
                 type: #COLLECTION,
                 position: 10
                 },
                      { id:            'ReqId',
                     purpose:       #STANDARD,
                     type:          #IDENTIFICATION_REFERENCE,
                     label:         'Request Id',
                     parentId: 'GeneralInfo',
                     position:      10 },
                   {
                       id: 'Upload',
                       purpose: #STANDARD,
                       type: #FIELDGROUP_REFERENCE,
                       parentId: 'GeneralInfo',
                       label: 'Upload Attachment',
                       position: 20,
                       targetQualifier: 'Upload'
                   } ]

     @UI.hidden: true
    key ReqId,
    @UI.hidden: true
    key PersId,
    @UI.lineItem: [{ position: 10, label: 'Attachmenn Id' }]
    @UI.identification: [{ position: 10, label: 'Attachment Id' }]
    key AttachId,
    @UI.lineItem: [{ position: 30, label: 'Attachment Text' }]
    @UI.fieldGroup: [{ position: 20, label: 'Text',qualifier: 'Upload' }]
    @UI.multiLineText: true
    AttText, 
    @UI.fieldGroup: [{ position: 10, label: 'File',qualifier: 'Upload' }]
    @UI.lineItem: [{ position: 20, label: 'File Name',importance: #HIGH  }]
    Attachment,
    @UI.hidden: true
    Mimetype,
    @UI.hidden: true
    Filename,
    @Semantics.systemDateTime.lastChangedAt: true
    LastChangedAt,
    /* Associations */
    _LeaveRequest: redirected to parent ZC_leave_req
}

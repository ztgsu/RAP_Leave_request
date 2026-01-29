@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_leave_req
  provider contract transactional_query
  as projection on zi_leave_req

{
  key     ReqId,
  key     Persid,
          Begda,
          Endda,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CALC_LEAVE_DAYS'
virtual   TotalDays : abap.int4,
          @Search.defaultSearchElement: true
          @Consumption.valueHelpDefinition: [{ entity:{name: 'ZC_LEAVE_REQ_TYPE_F4',element: 'Value'  } } ]
          @ObjectModel.text.element: ['TypeDesc']
          ReqType,
          _ReqType.Description as TypeDesc,
          Text,
          @Consumption.valueHelpDefinition: [{ entity:{name: 'ZC_LEAVE_REQ_app',element: 'Approver'  } } ]
          Approver,
          @Search.defaultSearchElement: true
          @Consumption.valueHelpDefinition: [{ entity:{name: 'ZC_LEAVE_REQ_STAT_F4',element: 'Value'  } } ]
          @ObjectModel.text.element: ['StatDesc']
          Status,
          _ReqStat.Description as StatDesc,
           QuotaTotal,
           QuotaRem,
          Createby,
          Createddatetime,
          /* Associations */
          _ReqAttachments : redirected to composition child ZC_leave_req_att,
          _ReqStat,
          _ReqType,
          _ReqApp,
          _LeaveQuota
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request status projection view'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define  view entity Zc_LEAVE_REQ_STAT_F4 as select from zi_leave_req_stat_f4
{
  @UI.hidden: true
  key domain_name,
  @UI.hidden: true
  key value_position,
  @ObjectModel.text.element: ['Description']
     Value,
     @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Search.ranking: #HIGH
      @EndUserText.label: 'Status'
      @Semantics.text: true
      @Semantics.name.fullName: true
      @UI.identification: [{ position: 10, label: 'Status' }]
     Description
}

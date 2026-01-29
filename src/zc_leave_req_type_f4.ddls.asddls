@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request status projection view'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define  view entity ZC_LEAVE_REQ_type_F4 as select from ZI_LEAVE_REQ_Type_F4
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
      @EndUserText.label: 'Request type'
      @Semantics.text: true
      @Semantics.name.fullName: true
      @UI.identification: [{ position: 10, label: 'Request type' }]
     Description
}

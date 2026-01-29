@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request apprever projection view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_LEAVE_REQ_app as select from ZI_leave_req_app
{  
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Search.ranking: #HIGH
      @EndUserText.label: 'Approver'
      @Semantics.text: true
      @Semantics.name.fullName: true
      @UI.identification: [{ position: 10, label: 'Approver' }]
    key Approver
}

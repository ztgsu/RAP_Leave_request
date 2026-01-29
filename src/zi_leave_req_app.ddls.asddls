@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request apprever base view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_leave_req_app as select from ztab_req_app
{
    key approver as Approver
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request status base view'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_leave_req_stat_f4 as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDM_REQ_STAT' )
{
  @UI.hidden: true
  key domain_name,
  key value_position,
      @Semantics.language: true
  key language,
      @EndUserText.label: 'Value'
      value_low as Value,
      @Semantics.text: true
      @EndUserText.label: 'Description'
      text      as Description
}

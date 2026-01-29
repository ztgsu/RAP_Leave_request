@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave quotas'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_LEAVE_QUOTA as select from ztab_req_quota
{
    key pernr as Pernr,
    key req_type as ReqType,
    quota_total as QuotaTotal,
    quota_rem as QuotaRem
    
}

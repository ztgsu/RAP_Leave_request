@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request basic view'
@Metadata.ignorePropagatedAnnotations: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity zi_leave_req as select from ztab_leave_req

composition[*] of zi_leave_req_att as _ReqAttachments
//              on $projection.ReqId = _ReqAttachments.ReqId

association[1] to zi_leave_req_stat_f4 as _ReqStat
              on $projection.Status = _ReqStat.Value
association[1] to ZI_LEAVE_REQ_Type_F4 as _ReqType
              on $projection.ReqType = _ReqType.Value
association[1] to ZI_leave_req_app as _ReqApp
              on $projection.Approver = _ReqApp.Approver
association[1] to ZI_LEAVE_QUOTA as _LeaveQuota
              on $projection.Persid = _LeaveQuota.Pernr
             and $projection.ReqType = _LeaveQuota.ReqType  
              
{
    key req_id as ReqId,
    key persid as Persid,
    begda as Begda,
    endda as Endda,
    req_type as ReqType,
    text as Text,
    approver as Approver,
    status as Status,
    _LeaveQuota.QuotaRem as QuotaRem,
    _LeaveQuota.QuotaTotal as QuotaTotal,
    @Semantics.user.createdBy: true
    createby as Createby,
    @Semantics.systemDateTime.createdAt: true
    createddatetime as Createddatetime,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as Lastchangeat,
    @Semantics.user.lastChangedBy: true
    locallastchangedby as Lastchangeby,
    _ReqAttachments,
    _ReqStat,
    _ReqType,
    _ReqApp,
    _LeaveQuota
}

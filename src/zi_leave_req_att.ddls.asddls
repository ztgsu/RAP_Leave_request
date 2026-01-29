
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave request attachements basic view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define  view entity zi_leave_req_att as select from ztab_req_att

association to parent zi_leave_req as _LeaveRequest 
    on $projection.ReqId = _LeaveRequest.ReqId and $projection.PersId = _LeaveRequest.Persid
                   

{
    key req_id as ReqId,
    key persid as PersId,
    key attach_id as AttachId,
    att_text as AttText,
     @Semantics.largeObject:
          { mimeType: 'Mimetype',
          fileName: 'Filename',
          contentDispositionPreference: #INLINE }
    attachment as Attachment,
    @Semantics.mimeType: true
    mimetype as Mimetype,
    filename as Filename,
    last_changed_at as LastChangedAt,
    _LeaveRequest
}

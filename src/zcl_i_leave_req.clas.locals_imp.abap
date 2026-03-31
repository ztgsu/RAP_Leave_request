CLASS lhc_LeaveRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR LeaveRequest RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR LeaveRequest RESULT result.


    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE LeaveRequest.
    METHODS earlynumbering_att FOR NUMBERING
      IMPORTING entities FOR CREATE LeaveRequest\_ReqAttachments.
    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LeaveRequest~SetInitialStatus.

 METHODS CopyLeaveRequest FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~CopyLeaveRequest RESULT result.
    METHODS SendToApproval FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~SendToApproval RESULT result.
    METHODS WithdrawApproval FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~WithdrawApproval RESULT result.



ENDCLASS.

CLASS lhc_LeaveRequest IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  " Control which actions/fields are enabled based on current status

  " Read the current status of all selected requests
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave_requests).

  " Set feature control for each request
  result = VALUE #( FOR ls_req IN lt_leave_requests (
    %tky = ls_req-%tky

    " Control SendToApproval action
    %action-SendToApproval = COND #(
      WHEN ls_req-Status = 'NEW'
        THEN if_abap_behv=>fc-o-enabled      " ✅ Enable when NEW
        ELSE if_abap_behv=>fc-o-disabled     " ❌ Disable otherwise
    )

    " Control WithdrawApproval action
    %action-WithdrawApproval = COND #(
      WHEN ls_req-Status = 'WFA'             " STA = Submitted/Sent to Approval
        THEN if_abap_behv=>fc-o-enabled      " ✅ Enable when STA
        ELSE if_abap_behv=>fc-o-disabled     " ❌ Disable otherwise
    )

    " Optional: Make Status field readonly after submission
    %field-Status = COND #(
      WHEN ls_req-Status = 'NEW'
        THEN if_abap_behv=>fc-f-unrestricted " Editable when NEW
        ELSE if_abap_behv=>fc-f-read_only    " Readonly after submission
    )

    " Optional: Make date fields readonly after submission
    %field-Begda = COND #(
      WHEN ls_req-Status = 'NEW'
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only
    )

    %field-Endda = COND #(
      WHEN ls_req-Status = 'NEW'
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only
    )
    %field-ReqType = COND #(
      WHEN ls_req-Status = 'NEW'
        THEN if_abap_behv=>fc-f-unrestricted
        ELSE if_abap_behv=>fc-f-read_only
    )
  ) ).

ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: lv_max_no TYPE c LENGTH 10.
    SELECT MAX( req_id )
      FROM ztab_leave_req
      INTO @lv_max_no.

    DATA(lt_entities) = entities.

    LOOP AT lt_entities INTO DATA(ls_entity).
      lv_max_no = lv_max_no + 1.
      ls_entity-ReqId = |{ lv_max_no ALPHA = IN }|.
      ls_entity-Persid = sy-uname.

      APPEND VALUE #(   %cid = ls_entity-%cid
                        %is_draft = ls_entity-%is_draft
                        ReqId = ls_entity-ReqId
                        persid = ls_entity-Persid )
                         TO mapped-leaverequest.

    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_att.

    DATA(lt_final_keys) = entities.


    LOOP AT lt_final_keys INTO DATA(ls_final_key) .


      LOOP AT ls_final_key-%target INTO DATA(ls_item).

        IF ls_final_key-%is_draft = 01.
          DATA(lv_attach_id) = cl_system_uuid=>create_uuid_x16_static( ).
        ELSE.
          lv_attach_id = ls_item-attachId.
        ENDIF.
        ls_item-attachId =  lv_attach_id .
        APPEND VALUE #( %cid = ls_item-%cid
                        %is_draft = ls_item-%is_draft
                        %key = ls_item-%key
                        attachid = lv_attach_id ) TO mapped-attachments.
      ENDLOOP.


    ENDLOOP.

  ENDMETHOD.

  METHOD SetInitialStatus.
    " Read the instances being created
    " 1. Read the records that were just created
    READ ENTITIES OF zi_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    " 2. Filter out records that already have a status (to avoid overwriting)
    DELETE lt_requests WHERE Status IS NOT INITIAL.
    CHECK lt_requests IS NOT INITIAL.

    " 3. Set your default values
    MODIFY ENTITIES OF zi_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR req IN lt_requests (
                        %tky   = req-%tky
                        Status = 'NEW'
                     ) )
    REPORTED DATA(lt_reported).

    " 4. Pass back any messages (optional)
    reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD SendToApproval.
  " Send to Approval action
  " Changes status from NEW to STA (Submitted)

  " Read the leave requests
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave_requests).

  " Prepare updates
  DATA lt_update TYPE TABLE FOR UPDATE zi_leave_req.

  LOOP AT lt_leave_requests INTO DATA(ls_leave_request).

    " Validate status is NEW
    IF ls_leave_request-Status = 'NEW'.

      " OK - Update to STA (Submitted)
      APPEND VALUE #(
        %tky = ls_leave_request-%tky
        Status = 'WFA'  " STA = Submitted/Sent to Approval
        %control-Status = if_abap_behv=>mk-on
      ) TO lt_update.

    ELSE.

      " Error - Status is not NEW
      APPEND VALUE #(
        %tky = ls_leave_request-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text = |Cannot send to approval. Status must be 'NEW' but is '{ ls_leave_request-Status }'.|
               )
        %element-Status = if_abap_behv=>mk-on
      ) TO reported-leaverequest.

      APPEND VALUE #( %tky = ls_leave_request-%tky ) TO failed-leaverequest.

    ENDIF.

  ENDLOOP.

  " Update status
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
        UPDATE FIELDS ( Status )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    " Success message
    LOOP AT lt_update INTO DATA(ls_update).
      APPEND VALUE #(
        %tky = ls_update-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-success
                 text = |Request sent to approval successfully|
               )
      ) TO reported-leaverequest.
    ENDLOOP.

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDIF.

  " Return result
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #( FOR <req> IN lt_result
                    INDEX INTO idx (
    %tky   = keys[ idx ]-%tky
    %param = <req>
  ) ).

ENDMETHOD.
METHOD WithdrawApproval.
  " Withdraw Approval action
  " Changes status from STA back to NEW

  " Read the leave requests
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave_requests).

  " Prepare updates
  DATA lt_update TYPE TABLE FOR UPDATE zi_leave_req.

  LOOP AT lt_leave_requests INTO DATA(ls_leave_request).

    " Validate status is STA
    IF ls_leave_request-Status = 'WFA'.

      " OK - Change back to NEW
      APPEND VALUE #(
        %tky = ls_leave_request-%tky
        Status = 'NEW'  " Change back to NEW
        %control-Status = if_abap_behv=>mk-on
      ) TO lt_update.

    ELSE.

      " Error - Status is not STA
      APPEND VALUE #(
        %tky = ls_leave_request-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text = |Cannot withdraw. Request must be submitted (status 'WFA') but is '{ ls_leave_request-Status }'.|
               )
        %element-Status = if_abap_behv=>mk-on
      ) TO reported-leaverequest.

      APPEND VALUE #( %tky = ls_leave_request-%tky ) TO failed-leaverequest.

    ENDIF.

  ENDLOOP.

  " Update status
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
        UPDATE FIELDS ( Status )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    " Success message
    LOOP AT lt_update INTO DATA(ls_update).
      APPEND VALUE #(
        %tky = ls_update-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-success
                 text = |Approval withdrawn. Request returned to NEW status.|
               )
      ) TO reported-leaverequest.
    ENDLOOP.

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDIF.

  " Return result
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #( FOR <req> IN lt_result
                    INDEX INTO idx (
    %tky   = keys[ idx ]-%tky
    %param = <req>
  ) ).

ENDMETHOD.
METHOD CopyLeaveRequest.
  " Read the leave request to be copied
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave_requests).

  " Also read attachments if you want to copy them
  READ ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest BY \_ReqAttachments
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_attachments).

  " Prepare new leave request data
  DATA lt_create TYPE TABLE FOR CREATE zi_leave_req.
  DATA lt_create_att TYPE TABLE FOR CREATE zi_leave_req\_ReqAttachments.

  LOOP AT lt_leave_requests INTO DATA(ls_leave_request).

      DATA(lv_parent_cid) = |COPY_{ sy-tabix }|.

    " Generate new request ID (will be handled by early numbering)
    " Create new leave request with copied data
    APPEND VALUE #(
      %cid = |COPY_{ lv_parent_cid }|
      %is_draft = '01'  " Create as draft
      " Copy all fields EXCEPT the key and readonly fields
      Begda = ls_leave_request-Begda
      Endda = ls_leave_request-Endda
      ReqType = ls_leave_request-ReqType
      Text = |Copy of: { ls_leave_request-Text }|  " Prefix to indicate it's a copy
      Approver = ls_leave_request-Approver
      " Status will be set by SetInitialStatus determination
      " ReqId and Persid will be set by early numbering
    ) TO lt_create.

    " Copy attachments if any exist
    LOOP AT lt_attachments INTO DATA(ls_attachment)
      WHERE ReqId = ls_leave_request-ReqId
        AND Persid = ls_leave_request-Persid.

      APPEND VALUE #(
        %cid_ref = |COPY_{ lv_parent_cid }|
        %is_draft = '01'
        %target = VALUE #( (
          %cid = |ATT_{ sy-tabix }|
          %is_draft = '01'
          Attachment = ls_attachment-Attachment
          AttText = ls_attachment-AttText
          Filename = ls_attachment-Filename
          Mimetype = ls_attachment-Mimetype
        ) )
      ) TO lt_create_att.

    ENDLOOP.

  ENDLOOP.

  " Create the new leave request
  MODIFY ENTITIES OF zi_leave_req IN LOCAL MODE
    ENTITY LeaveRequest
      CREATE FIELDS ( Begda Endda ReqType Text Approver )
      WITH lt_create
    CREATE BY \_ReqAttachments
      FIELDS ( Attachment AttText Filename Mimetype )
      WITH lt_create_att
    MAPPED DATA(ls_mapped)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

  " Map the result back
 " CORRECT: Map result for action
result = VALUE #( FOR <create> IN lt_create
                  INDEX INTO idx (
  %tky   = keys[ idx ]-%tky                                      " Original key
  %param = CORRESPONDING #( ls_mapped-leaverequest[ %cid = <create>-%cid ] )  " New data
) ).

  " Report any messages
  reported = CORRESPONDING #( DEEP ls_reported ).
  failed = CORRESPONDING #( DEEP ls_failed ).

ENDMETHOD.


ENDCLASS.

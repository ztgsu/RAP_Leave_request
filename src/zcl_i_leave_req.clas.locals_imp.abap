CLASS lhc_LeaveRequest DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR LeaveRequest RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE LeaveRequest.
    METHODS earlynumbering_att FOR NUMBERING
      IMPORTING entities FOR CREATE LeaveRequest\_ReqAttachments.
    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LeaveRequest~SetInitialStatus.
    METHODS CalculateQuota FOR DETERMINE ON SAVE
      IMPORTING keys FOR LeaveRequest~CalculateQuota.


ENDCLASS.

CLASS lhc_LeaveRequest IMPLEMENTATION.

  METHOD get_instance_authorizations.
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


  METHOD CalculateQuota.
    " Read the instances being created
    " 1. Read the records that were just created
    READ ENTITIES OF zi_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
        FIELDS ( QuotaTotal Begda Endda ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).


    DATA lt_update TYPE TABLE FOR UPDATE zi_leave_req.

    lt_update = VALUE #( FOR request IN lt_requests (
      %tky       = request-%tky
      QuotaRem = request-QuotaRem - ( request-Endda - request-Begda + 1 )
      %control-QuotaRem = if_abap_behv=>mk-on
    ) ).


    MODIFY ENTITIES OF zi_leave_req iN LOCAL MODE
      ENTITY LeaveRequest
        UPDATE FROM lt_update
    REPORTED DATA(lt_reported)
    faiLED DATA(lt_failed).



    READ ENTITIES OF zi_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
        FIELDS ( QuotaTotal Begda Endda ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests2).

*  MODIFY ENTITIES OF ZI_LEAVE_QUOTA IN LOCAL MODE
*    ENTITY LeaveQuota  "use the entity name from ZI_LEAVE_QUOTA behavior def
*    UPDATE FIELDS ( your_field )
*    WITH VALUE #( FOR wa IN lt_main_data
*                    ( quota_id = wa-association_key_field  "the key field
*                      your_field = 'new_value' ) )
*    REPORTED DATA(ls_reported)
*    FAILED DATA(ls_failed).

*
*    READ ENTITIES OF zi_leave_quota
*      ENTITY LeaveQuota
*        FIELDS ( quota_rem  ) WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_quota).
*

    " 4. Pass back any messages (optional)
*    reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.


ENDCLASS.

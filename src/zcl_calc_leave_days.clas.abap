CLASS zcl_calc_leave_days DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_calc_leave_days IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_data TYPE STANDARD TABLE OF zc_leave_req.
    lt_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_row>).

      " ========================================
      " 1. Calculate Total Days (Requested)
      " ========================================
      IF <fs_row>-Begda IS NOT INITIAL AND <fs_row>-Endda IS NOT INITIAL.
        <fs_row>-TotalDays = <fs_row>-Endda - <fs_row>-Begda + 1.
      ELSE.
        <fs_row>-TotalDays = 0.
      ENDIF.

      " ========================================
      " 2. Read Quota from ztab_req_quota
      " ========================================
      IF <fs_row>-Persid IS NOT INITIAL AND <fs_row>-ReqType IS NOT INITIAL.

        " Read current quota from the quota table
        SELECT SINGLE quota_total, quota_rem
          FROM ztab_req_quota
          WHERE pernr = @<fs_row>-Persid
            AND req_type = @<fs_row>-ReqType
          INTO @DATA(ls_quota).

        IF sy-subrc = 0.
          " Quota record found
          <fs_row>-QuotaTotal = ls_quota-quota_total.
          <fs_row>-QuotaRem = ls_quota-quota_rem.

          " Calculate what quota will be AFTER this request
          IF <fs_row>-TotalDays > 0.
            <fs_row>-QuotaAfterRequest = ls_quota-quota_rem - <fs_row>-TotalDays.
          ELSE.
            <fs_row>-QuotaAfterRequest = ls_quota-quota_rem.
          ENDIF.


          IF <fs_row>-QuotaAfterRequest < 0.
            <fs_row>-QuotaCriticality = 1.   " Red - Over quota!
          ELSEIF <fs_row>-QuotaAfterRequest <= 2.
            <fs_row>-QuotaCriticality = 1.   " Red - Very low
          ELSEIF <fs_row>-QuotaAfterRequest <= 5.
            <fs_row>-QuotaCriticality = 2.   " Yellow - Low
          ELSE.
            <fs_row>-QuotaCriticality = 3.   " Green - Good
          ENDIF.

        ELSE.
          " No quota record found for this person/type
          <fs_row>-QuotaTotal = 0.
          <fs_row>-QuotaRem = 0.
          <fs_row>-QuotaAfterRequest = 0.
        ENDIF.

      ELSE.
        " Person or Type not set yet
        <fs_row>-QuotaTotal = 0.
        <fs_row>-QuotaRem = 0.
        <fs_row>-QuotaAfterRequest = 0.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    " Check if TotalDays is being requested
    IF line_exists( it_requested_calc_elements[ table_line = 'TOTALDAYS' ] ).

      " Force the framework to include these fields in 'it_original_data'
      INSERT CONV #( 'BEGDA' ) INTO TABLE et_requested_orig_elements.
      INSERT CONV #( 'ENDDA' ) INTO TABLE et_requested_orig_elements.

    ENDIF.

    " For QuotaAfterRequest calculation
    IF line_exists( it_requested_calc_elements[ table_line = 'QUOTAAFTERREQUEST' ] ) .
      INSERT CONV #( 'PERSID' ) INTO TABLE et_requested_orig_elements.
      INSERT CONV #( 'REQTYPE' ) INTO TABLE et_requested_orig_elements.
      INSERT CONV #( 'BEGDA' ) INTO TABLE et_requested_orig_elements.
      INSERT CONV #( 'ENDDA' ) INTO TABLE et_requested_orig_elements.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

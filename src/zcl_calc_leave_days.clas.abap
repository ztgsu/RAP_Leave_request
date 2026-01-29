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
    " Use your Base View type here
    DATA lt_data TYPE STANDARD TABLE OF zc_leave_req.
    lt_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_row>).
      " ABAP handles DATS subtraction perfectly: Mon to Wed = 2
      <fs_row>-TotalDays = <fs_row>-endda - <fs_row>-begda.

      " To make it inclusive (Mon to Wed = 3 days), add 1
      <fs_row>-TotalDays += 1.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    " Check if TotalDays is being requested
    IF line_exists( it_requested_calc_elements[ table_line = 'TOTALDAYS' ] ).

      " Force the framework to include these fields in 'it_original_data'
      insert conv #( 'BEGDA' ) into table et_requested_orig_elements.
      insert conv #( 'ENDDA' ) into table et_requested_orig_elements.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

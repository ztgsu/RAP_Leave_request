CLASS zt_cl_filler_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zt_cl_filler_class IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*  DELETE FROM ztab_req_app.
*
*    INSERT ztab_req_app FROM TABLE @( VALUE #(
*      ( approver = 'App1' )
*      ( approver = 'App2' )
*    ) ).

    DELETE FROM ztab_personel.

    INSERT ztab_personel FROM TABLE @( VALUE #(
      ( pernr = sy-uname name = 'Zübeyir Tayyar' )
    ) ).

    INSERT ztab_req_quota FROM TABLE @( VALUE #(
      ( pernr = sy-uname req_type = '03' quota_total = 14 quota_rem = 13 )
      ( pernr = sy-uname req_type = '01' quota_total = 10 quota_rem = 4 )
      ( pernr = sy-uname req_type = '04' quota_total = 30 quota_rem = 30 )
    ) ).

    out->write( 'Sample data inserted' ).

  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& Include          ZCOGUNIALV_F01
*&---------------------------------------------------------------------*

*** CLASS DEFINITION AND IMPLEMENTATION TO HANDLE OUR EVENTS ***


CLASS lcl_hotspot_handler IMPLEMENTATION. " currenly doesnt let me take the value of which field is clicked on
  METHOD handle_hotspot_click.
    CASE column.
      WHEN 'CNAME'.
        IF sy-subrc = 0.
          " Read the value in which the name matches the selected name from the class table to the work area
          CLEAR wa_zcoguniclass.
          READ TABLE it_zcoguniclass INTO wa_zcoguniclass INDEX row.
          " Get Student Data in relation to the class registered if available
          PERFORM get_student.
          IF it_zcuregist IS NOT INITIAL.
            "Display Student Data
            CALL METHOD generate_output( EXPORTING lv_fcat = it_fcat_regist CHANGING lt_name = it_zcuregist ).
          ELSE.
            MESSAGE 'NO CLASS TO STUDENT DATA WAS RETRIEVED' TYPE 'I'.
          ENDIF.
        ENDIF.
      WHEN 'SNUM'.
        IF sy-subrc = 0.
          CLEAR wa_zcuregist.
          READ TABLE it_zcuregist INTO wa_zcuregist INDEX row." READ TABLE INTO THE WORK ARE WITH SPECIFIC INDEX SELECTED AT SELECTION SCREEN
          PERFORM get_student_info.
          IF it_zcogunistudents IS NOT INITIAL." CHECK IF THE TABLE IS NOT INITIAL.
            "Display Student Data
            CALL METHOD generate_output( EXPORTING lv_fcat = it_fcat_student CHANGING lt_name = it_zcogunistudents ).
          ELSE.
            MESSAGE 'NO STUDENT INFORMATION DATA WAS RETRIEVED' TYPE 'I'.
          ENDIF.
        ENDIF.
*      WHEN OTHERS.
*        MESSAGE 'Double Click event: triggered???' TYPE 'I'.
    ENDCASE.
  ENDMETHOD.

  METHOD generate_output.
    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = lo_alv
          CHANGING
            t_table      = lt_name.
      CATCH cx_salv_msg.
    ENDTRY.

    PERFORM get_alv_fcat TABLES lv_fcat.

    lo_functions = lo_alv->get_functions( ).
    lo_functions->set_all( abap_true ).
    lo_alv->set_screen_status(
      pfstatus      = 'ZCOG_UNI_STATUS'
      report        = sy-repid
*      set_functions = lo_alv->c_functions_all
      ).
*    ls_key-report = sy-cprog.
*    ls_key-handle = '0500'.
*
*    lo_layout = lo_alv->get_layout( ).
*    lo_layout->set_key( ls_key ).
*
    lo_display = lo_alv->get_display_settings( ).
    lo_display->set_striped_pattern( if_salv_c_bool_sap=>true ).

*     Register the Handler for HotSpot Event, as well as assigning this event to the local event object
    lo_events = lo_alv->get_event( ).
    SET HANDLER lcl_hotspot_handler=>handle_hotspot_click FOR lo_events. "first object calls the method and the second raises the event
    CLEAR sy-ucomm.
    lo_alv->display( ).
  ENDMETHOD.
ENDCLASS.


*** MAIN IMPLEMENTATION DEFINITIONS ***


FORM get_coguniclass.
  SELECT
    a~name,
    a~class_section,
    a~professor,
    a~start_time,
    a~end_time,
    a~week_day,
    COUNT( DISTINCT b~student_num )
    FROM zcoguniclass AS a INNER JOIN zcuregist AS b
      ON a~class_section = b~class_section GROUP BY
      a~name,
      a~class_section,
      a~professor,
      a~start_time,
      a~end_time,
      a~week_day
    INTO TABLE @it_zcoguniclass.
ENDFORM.

FORM get_student.
  SELECT
    a~name,
    a~class_section,
    b~student_num
    FROM zcogunistudents AS b
    INNER JOIN zcuregist AS c ON b~student_num = c~student_num
    INNER JOIN zcoguniclass AS a ON a~class_section = c~class_section
    INTO TABLE @it_zcuregist
      WHERE a~class_section = @wa_zcoguniclass-class_section.
ENDFORM.

FORM get_student_info.
  SELECT *
    FROM zcogunistudents AS a
    INTO TABLE @it_zcogunistudents
      WHERE a~student_num = @wa_zcuregist-snum.
ENDFORM.

FORM get_alv_fcat TABLES p_it_fcat TYPE lvc_t_fcat.
  DATA : lo_columns  TYPE REF TO cl_salv_columns_table,
         lo_column_t TYPE REF TO cl_salv_column_table.

  lo_columns = lo_alv->get_columns( ).
  lo_alv->get_columns( )->set_optimize( abap_true ).
  LOOP AT p_it_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    TRY.
*      lo_column_t = CAST cl_salv_column_table( lo_alv->get_columns( )->get_column( wa_fcat-fieldname ) ).
        lo_column_t ?= lo_columns->get_column( <fs_fcat>-fieldname ).
        lo_column_t->set_long_text( <fs_fcat>-scrtext_l ).
        lo_column_t->set_medium_text( <fs_fcat>-scrtext_m ).
        lo_column_t->set_short_text( <fs_fcat>-scrtext_s ).
        IF <fs_fcat>-hotspot = 'X'.
          lo_column_t->set_cell_type( if_salv_c_cell_type=>hotspot ).
        ENDIF.
        lo_column_t->set_output_length( <fs_fcat>-outputlen ).
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDLOOP.
ENDFORM.


*** GENERATE CUSTOM FIELD CATALOGS FOR THE INTERNAL TABLES ***
FORM generate_fcat.
  CALL FUNCTION 'ZFCAT_CREATE_FM'
    EXPORTING
      im_table    = it_zcoguniclass
      im_fcat     = class_fcat
      im_hotspot  = to_hotspot
    IMPORTING
      ex_lvc_fcat = it_fcat_class
*     EX_SLIS_FCAT                =
    .
  CALL FUNCTION 'ZFCAT_CREATE_FM'
    EXPORTING
      im_table    = it_zcuregist
      im_fcat     = regist_fcat
      im_hotspot  = to_hotspot
    IMPORTING
      ex_lvc_fcat = it_fcat_regist
*     EX_SLIS_FCAT                =
    .
  CALL FUNCTION 'ZFCAT_CREATE_FM'
    EXPORTING
      im_table    = it_zcogunistudents
      im_fcat     = student_fcat
      im_hotspot  = to_hotspot
    IMPORTING
      ex_lvc_fcat = it_fcat_student
*     EX_SLIS_FCAT                =
    .
ENDFORM.

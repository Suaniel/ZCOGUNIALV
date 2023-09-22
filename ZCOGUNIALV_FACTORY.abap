*&---------------------------------------------------------------------*
*& Report zcogunialv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcogunialv.

*** DATA TYPE DEFINITIONS FOR OUR 3 TABLES (STUDENT, CLASS, AND REGISTER) ***

TYPES : BEGIN OF ty_zcoguniclass,
          name           TYPE zcoguniclass-name,
          class_section  TYPE zcoguniclass-class_section,
          professor      TYPE zcoguniclass-professor,
          start_time     TYPE zcoguniclass-start_time,
          end_time       TYPE zcoguniclass-end_time,
          week_day       TYPE zcoguniclass-week_day,
          total_students TYPE i.
TYPES END OF ty_zcoguniclass.

TYPES : BEGIN OF ty_zcogunistudents,
          student_num TYPE zcogunistudents-student_num,
          age         TYPE zcogunistudents-age,
          gender      TYPE zcogunistudents-gender,
          residency   TYPE zcogunistudents-residency,
          name        TYPE zcogunistudents-name,
          last_name   TYPE zcogunistudents-last_name.
TYPES END OF ty_zcogunistudents.

TYPES : BEGIN OF ty_zcuregist,
          className    TYPE zcuregist-classes,
          classSection TYPE zcuregist-class_section,
          sNUM         TYPE zcuregist-student_num.
TYPES END OF ty_zcuregist.

*** INTERAL TABLES AND WORK AREA DEFINITIONS ***

DATA : it_zcoguniclass    TYPE STANDARD TABLE OF ty_zcoguniclass,
       wa_zcoguniclass    TYPE ty_zcoguniclass,
       it_zcogunistudents TYPE STANDARD TABLE OF ty_zcogunistudents,
       wa_zcogunistudents TYPE ty_zcogunistudents,
       it_zcuregist       TYPE STANDARD TABLE OF ty_zcuregist,
       wa_zcuregist       TYPE ty_zcuregist,
       it_fcat            TYPE lvc_t_fcat,
       it_fcat1           TYPE lvc_t_fcat,
       it_fcat2           TYPE lvc_t_fcat.

*** OBJECTS TO GET/SET VARIABLES INTO OUR METHODS FOR OUR FACTORY METHOD ***

DATA : lo_alv       TYPE REF TO cl_salv_table,
       lo_functions TYPE REF TO cl_salv_functions_list,
       lo_display   TYPE REF TO cl_salv_display_settings,
       lo_layout    TYPE REF TO cl_salv_layout,
       lo_events    TYPE REF TO cl_salv_events_table,
       lo_msg       TYPE REF TO cx_salv_msg,
       lo_selection TYPE REF TO cl_salv_selections,
       lv_string    TYPE string,
       ls_key       TYPE salv_s_layout_key.



*** CLASS DEFINITION AND IMPLEMENTATION TO HANDLE OUR EVENTS ***


CLASS lcl_hotspot_handler DEFINITION.
  PUBLIC SECTION.
* We call the event method, as well as import a parameter that lets us take which column triggers the event
    CLASS-METHODS :
      handle_hotspot_click FOR EVENT link_click OF cl_salv_events_table IMPORTING row column,
      generate_output IMPORTING lv_fcat TYPE lvc_t_fcat CHANGING lt_name TYPE ANY TABLE.
ENDCLASS.
DATA lo_event_handler TYPE REF TO lcl_hotspot_handler.

CLASS lcl_hotspot_handler IMPLEMENTATION. " currenly doesnt let me take the value of which field is clicked on
  METHOD handle_hotspot_click.
    CASE column.
      WHEN 'NAME'.
        IF sy-subrc = 0.
          " Read the value in which the name matches the selected name from the class table to the work area
          CLEAR wa_zcoguniclass.
          READ TABLE it_zcoguniclass INTO wa_zcoguniclass INDEX row.
          " Get Student Data in relation to the class registered if available
          PERFORM get_student.
          IF it_zcuregist IS NOT INITIAL.
            "Display Student Data
            CALL METHOD generate_output( EXPORTING lv_fcat = it_fcat1 CHANGING lt_name = it_zcuregist ).
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
            CALL METHOD generate_output( EXPORTING lv_fcat = it_fcat2 CHANGING lt_name = it_zcogunistudents ).
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



*** MAIN PROGRAM. FUNCTIONALITY AND PERFORMS ***


START-OF-SELECTION.

  PERFORM generate_fcat.
* Get Data from Class Table
  PERFORM get_coguniclass.

  IF it_zcoguniclass IS NOT INITIAL.
    CALL METHOD lcl_hotspot_handler=>generate_output
      EXPORTING
        lv_fcat = it_fcat
      CHANGING
        lt_name = it_zcoguniclass.
  ELSE.
    MESSAGE 'Unable to retrieve data from the Class Table' TYPE 'I'.
  ENDIF.

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
    FROM zcogunistudents AS b INNER JOIN zcuregist AS c
      ON b~student_num = c~student_num INNER JOIN zcoguniclass AS a
      ON a~class_section = c~class_section
        INTO TABLE @it_zcuregist WHERE a~class_section = @wa_zcoguniclass-class_section.
ENDFORM.

FORM get_student_info.
  SELECT *
    FROM zcogunistudents AS a
      INTO TABLE @it_zcogunistudents WHERE a~student_num = @wa_zcuregist-snum.
ENDFORM.

FORM get_alv_fcat TABLES p_it_fcat TYPE lvc_t_fcat.
  DATA : lo_columns  TYPE REF TO cl_salv_columns_table,
         lo_column_t TYPE REF TO cl_salv_column_table.

  lo_columns = lo_alv->get_columns( ).
  lo_alv->get_columns( )->set_optimize( abap_true ).
  LOOP AT p_it_fcat INTO DATA(wa_fcat).
    TRY.
*      lo_column_t = CAST cl_salv_column_table( lo_alv->get_columns( )->get_column( wa_fcat-fieldname ) ).
        lo_column_t ?= lo_columns->get_column( wa_fcat-fieldname ).
        lo_column_t->set_long_text( wa_fcat-scrtext_l ).
        lo_column_t->set_medium_text( wa_fcat-scrtext_m ).
        lo_column_t->set_short_text( wa_fcat-scrtext_s ).
        IF wa_fcat-hotspot = 'X'.
          lo_column_t->set_cell_type( if_salv_c_cell_type=>hotspot ).
        ENDIF.
        lo_column_t->set_output_length( wa_fcat-outputlen ).
        CLEAR wa_fcat.
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDLOOP.
ENDFORM.


*** GENERATE CUSTOM FIELD CATALOGS FOR THE INTERNAL TABLES ***


FORM generate_fcat.
* Field catalog it_fcat1 in association with the table zcuregist
  it_fcat1[] = VALUE lvc_t_fcat(
    ( Fieldname = 'CLASSNAME'
      ref_table = 'IT_ZCUREGIST'
      coltext = 'Classes'
      col_pos = 1
      Outputlen = 40
      scrtext_l = 'Classes'
      scrtext_m = 'Classes'
      scrtext_s = 'Classes'
    )
    ( fieldname = 'CLASSSECTION'
      ref_table = 'IT_ZCUREGIST'
      coltext = 'SECTION'
      col_pos = 2
      outputlen = 20
      scrtext_l = 'Section'
      scrtext_m = 'Section'
      scrtext_s = 'Section'
    )
    ( fieldname = 'SNUM'
      ref_table = 'IT_ZCUREGIST'
      coltext = 'STUDENT NUM'
      col_pos = 3
      outputlen = 20
      hotspot = 'X'
      scrtext_l = 'Student Number'
      scrtext_m = 'Stdnt Num'
      scrtext_s = 'S.Num'
    )
  ).
* Field Catalog IT_FCAT in association with the table ZCOGUNICLASS
  it_fcat[] = VALUE lvc_t_fcat(
   ( fieldname = 'NAME'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'NAME'
     col_pos = 1
     outputlen = 40
     hotspot = 'X'
     scrtext_l = 'Name'
     scrtext_m = 'Name'
     scrtext_s = 'Name'
   )
   ( fieldname = 'CLASS_SECTION'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'SECTION'
     col_pos = 2
     outputlen = 20
     scrtext_l = 'Section'
     scrtext_m = 'Section'
     scrtext_s = 'Section'
   )
   ( fieldname = 'PROFESSOR'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'PROFESSOR'
     col_pos = 3
     outputlen = 20
     scrtext_l = 'Professor'
     scrtext_m = 'Prof.'
     scrtext_s = 'Prof'
   )
   ( fieldname = 'START_TIME'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'START TIME'
     col_pos = 4
     outputlen = 20
     scrtext_l = 'Start Time'
     scrtext_m = 'S.Time'
     scrtext_s = 'Strt'
   )
   ( fieldname = 'END_TIME'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'END TIME'
     col_pos = 5
     outputlen = 20
     scrtext_l = 'End Time'
     scrtext_m = 'E.Time'
     scrtext_s = 'End'
   )
   ( fieldname = 'WEEK_DAY'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'WEEK DAY'
     col_pos = 6
     outputlen = 20
     scrtext_l = 'Week Day'
     scrtext_m = 'Days'
     scrtext_s = 'Days'
   )
   ( fieldname = 'TOTAL_STUDENTS'
     ref_table = 'ZCOGUNICLASS'
     coltext = 'TOTAL STUDENTS'
     col_pos = 7
     outputlen = 20
     scrtext_l = 'Total Students'
     scrtext_m = 'Total St.'
     scrtext_s = 'T.St'
   )
  ).
*  Field Catalog IT_FCAT2 in association with the table ZCOGUNISTUDENTS
  it_fcat2[] = VALUE lvc_t_fcat(
   ( fieldname = 'STUDENT_NUM'
     ref_table = 'IT_ZCOGUNISTUDENTS'
     coltext = 'S.NUM'
     col_pos = 1
     outputlen = 20
     scrtext_l = 'Student Number'
     scrtext_m = 'S.Num'
     scrtext_s = 'S.Num'

   )
   ( fieldname = 'AGE'
     ref_table = 'IT_ZCOGUNISTUDENTS'
     coltext = 'AGE'
     col_pos = 2
     outputlen = 20
     scrtext_l = 'Age'
     scrtext_m = 'Age'
     scrtext_s = 'Age'
   )
   ( fieldname = 'GENDER'
     ref_table = 'IT_ZCOGUNISTUDENTS'
     coltext = 'GENDER'
     col_pos = 3
     outputlen = 20
     scrtext_l = 'Gender'
     scrtext_m = 'Gender'
     scrtext_s = 'Gender'
   )
   ( fieldname = 'RESIDENCY'
     ref_table = 'IT_ZCOGUNISTUDENTS'
     coltext = 'RESIDENCY'
     col_pos = 4
     outputlen = 20
     scrtext_l = 'Residency'
     scrtext_m = 'Residency'
     scrtext_s = 'Resdc'
   )
   ( fieldname = 'NAME'
     ref_table = 'IT_ZCOGUNISTUDENTS'
     coltext = 'NAME'
     col_pos = 5
     outputlen = 20
     scrtext_l = 'Name'
     scrtext_m = 'Name'
     scrtext_s = 'Name'
   )
   ( fieldname = 'LAST_NAME'
     ref_table = 'IT_ZCOGUNISTUDENTS'
     coltext = 'LAST NAME'
     col_pos = 6
     outputlen = 20
     scrtext_l = 'Last Name'
     scrtext_m = 'L.Name'
     scrtext_s = 'LN'
   )
  ).
ENDFORM.

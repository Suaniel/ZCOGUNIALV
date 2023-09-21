*&---------------------------------------------------------------------*
*& Report zcogunialv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcogunialv.

*** DATA TYPE DEFINITIONS FOR OUR 3 TABLES (STUDENT, CLASS, AND REGISTER) ***

TYPES : BEGIN OF TY_ZCOGUNICLASS,
          name           TYPE ZCOGUNICLASS-name,
          class_section  TYPE ZCOGUNICLASS-class_section,
          professor      TYPE ZCOGUNICLASS-professor,
          start_time     TYPE ZCOGUNICLASS-start_time,
          end_time       TYPE ZCOGUNICLASS-end_time,
          week_day       TYPE ZCOGUNICLASS-week_day,
          total_students TYPE I.
        TYPES END OF TY_ZCOGUNICLASS.

TYPES : BEGIN OF TY_ZCOGUNISTUDENTS,
          student_num TYPE ZCOGUNISTUDENTS-student_num,
          age         TYPE ZCOGUNISTUDENTS-age,
          gender      TYPE ZCOGUNISTUDENTS-gender,
          residency   TYPE ZCOGUNISTUDENTS-residency,
          name        TYPE ZCOGUNISTUDENTS-name,
          last_name   TYPE ZCOGUNISTUDENTS-last_name.
        TYPES END OF TY_ZCOGUNISTUDENTS.

TYPES : BEGIN OF TY_ZCUREGIST,
          className TYPE ZCUREGIST-classes,
          classSection TYPE ZCUREGIST-class_section,
          sNUM TYPE ZCUREGIST-student_num.
        TYPES END OF TY_ZCUREGIST.

*** INTERAL TABLES AND WORK AREA DEFINITIONS ***

DATA : IT_ZCOGUNICLASS    TYPE STANDARD TABLE OF TY_ZCOGUNICLASS,
       WA_ZCOGUNICLASS    TYPE TY_ZCOGUNICLASS,
       IT_ZCOGUNISTUDENTS TYPE STANDARD TABLE OF TY_ZCOGUNISTUDENTS,
       WA_ZCOGUNISTUDENTS TYPE TY_ZCOGUNISTUDENTS,
       IT_ZCUREGIST       TYPE STANDARD TABLE OF TY_ZCUREGIST,
       WA_ZCUREGIST       TYPE TY_ZCUREGIST,
       IT_FCAT            TYPE LVC_T_FCAT,
       IT_FCAT1           TYPE LVC_T_FCAT,
       IT_FCAT2           TYPE LVC_T_FCAT.

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


CLASS LCL_HOTSPOT_HANDLER DEFINITION.
  PUBLIC SECTION.
* We call the event method, as well as import a parameter that lets us take which column triggers the event
    CLASS-METHODS :
      HANDLE_HOTSPOT_CLICK FOR EVENT LINK_CLICK OF CL_SALV_EVENTS_TABLE IMPORTING row column,
      GENERATE_OUTPUT IMPORTING lv_fcat TYPE lvc_t_fcat CHANGING lt_name TYPE any table.
ENDCLASS.
DATA lo_event_handler TYPE REF TO LCL_HOTSPOT_HANDLER.

CLASS LCL_HOTSPOT_HANDLER IMPLEMENTATION. " currenly doesnt let me take the value of which field is clicked on
  METHOD HANDLE_HOTSPOT_CLICK.
    CASE column.
      WHEN 'NAME'.
        IF SY-SUBRC = 0.
          " Read the value in which the name matches the selected name from the class table to the work area
          CLEAR WA_ZCOGUNICLASS.
          READ TABLE IT_ZCOGUNICLASS INTO WA_ZCOGUNICLASS INDEX row.
          " Get Student Data in relation to the class registered if available
          PERFORM GET_STUDENT.
          IF IT_ZCUREGIST IS NOT INITIAL.
            "Display Student Data
            CALL METHOD GENERATE_OUTPUT( EXPORTING lv_fcat = it_fcat1 CHANGING lt_name = IT_ZCUREGIST ).
          ELSE.
            MESSAGE 'NO CLASS TO STUDENT DATA WAS RETRIEVED' TYPE 'I'.
          ENDIF.
        ENDIF.
      WHEN 'SNUM'.
        IF SY-SUBRC = 0.
          CLEAR wa_zcuregist.
          READ TABLE IT_ZCUREGIST INTO wa_zcuregist INDEX row." READ TABLE INTO THE WORK ARE WITH SPECIFIC INDEX SELECTED AT SELECTION SCREEN
          PERFORM get_student_info.
          IF it_zcogunistudents IS NOT INITIAL." CHECK IF THE TABLE IS NOT INITIAL.
            "Display Student Data
            CALL METHOD GENERATE_OUTPUT( EXPORTING lv_fcat = it_fcat2 CHANGING lt_name = it_zcogunistudents ).
          ELSE.
            MESSAGE 'NO STUDENT INFORMATION DATA WAS RETRIEVED' TYPE 'I'.
          ENDIF.
        ENDIF.
*      WHEN OTHERS.
*        MESSAGE 'Double Click event: triggered???' TYPE 'I'.
    ENDCASE.
  ENDMETHOD.

  METHOD GENERATE_OUTPUT.
    TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table   = lo_alv
        CHANGING
          t_table        = lt_name
        .
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
    SET HANDLER lcl_hotspot_handler=>HANDLE_HOTSPOT_CLICK FOR lo_events. "first object calls the method and the second raises the event
    CLEAR sy-ucomm.
    lo_alv->display( ).
  ENDMETHOD.
ENDCLASS.



*** MAIN PROGRAM. FUNCTIONALITY AND PERFORMS ***


START-OF-SELECTION.

PERFORM generate_fcat.
* Get Data from Class Table
PERFORM GET_COGUNICLASS.

CALL METHOD lcl_hotspot_handler=>GENERATE_OUTPUT
  EXPORTING
    lv_fcat = it_fcat
  CHANGING
    lt_name = it_zcoguniclass
  .


*** MAIN IMPLEMENTATION DEFINITIONS ***


FORM GET_COGUNICLASS.
  SELECT
    a~NAME,
    a~CLASS_SECTION,
    a~PROFESSOR,
    a~START_TIME,
    a~END_TIME,
    a~WEEK_DAY,
    COUNT( DISTINCT b~student_num )
    FROM ZCOGUNICLASS AS a INNER JOIN ZCUREGIST AS b
      ON a~class_section = b~class_section GROUP BY
      a~NAME,
      a~CLASS_SECTION,
      a~PROFESSOR,
      a~START_TIME,
      a~END_TIME,
      a~WEEK_DAY
    INTO TABLE @IT_ZCOGUNICLASS.
ENDFORM.

FORM get_student.
  SELECT
    a~NAME,
    a~CLASS_SECTION,
    b~STUDENT_NUM
    FROM ZCOGUNISTUDENTS AS b INNER JOIN ZCUREGIST AS c
      ON b~STUDENT_NUM = c~STUDENT_NUM INNER JOIN ZCOGUNICLASS AS a
      ON a~CLASS_SECTION = c~CLASS_SECTION
        INTO TABLE @IT_ZCUREGIST WHERE a~class_section = @WA_ZCOGUNICLASS-class_section.
ENDFORM.

FORM get_student_info.
  SELECT *
    FROM ZCOGUNISTUDENTS AS a
      INTO TABLE @IT_ZCOGUNISTUDENTS WHERE a~student_num = @wa_zcuregist-snum.
ENDFORM.

FORM get_alv_fcat TABLES p_it_fcat TYPE lvc_t_fcat.
  DATA :  lo_columns  TYPE REF TO cl_salv_columns_table,
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
      SCRTEXT_L = 'Classes'
      SCRTEXT_M = 'Classes'
      SCRTEXT_S = 'Classes'
    )
    ( FIELDNAME = 'CLASSSECTION'
      ref_table = 'IT_ZCUREGIST'
      COLTEXT = 'SECTION'
      COL_POS = 2
      OUTPUTLEN = 20
      SCRTEXT_L = 'Section'
      SCRTEXT_M = 'Section'
      SCRTEXT_S = 'Section'
    )
    ( FIELDNAME = 'SNUM'
      ref_table = 'IT_ZCUREGIST'
      COLTEXT = 'STUDENT NUM'
      COL_POS = 3
      OUTPUTLEN = 20
      HOTSPOT = 'X'
      SCRTEXT_L = 'Student Number'
      SCRTEXT_M = 'Stdnt Num'
      SCRTEXT_S = 'S.Num'
    )
  ).
* Field Catalog IT_FCAT in association with the table ZCOGUNICLASS
   it_fcat[] = VALUE lvc_t_fcat(
    ( FIELDNAME = 'NAME'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'NAME'
      COL_POS = 1
      OUTPUTLEN = 40
      HOTSPOT = 'X'
      SCRTEXT_L = 'Name'
      SCRTEXT_M = 'Name'
      SCRTEXT_S = 'Name'
    )
    ( FIELDNAME = 'CLASS_SECTION'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'SECTION'
      COL_POS = 2
      OUTPUTLEN = 20
      SCRTEXT_L = 'SECTION'
      SCRTEXT_M = 'SECTION'
      SCRTEXT_S = 'SECTION'
    )
    ( FIELDNAME = 'PROFESSOR'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'PROFESSOR'
      COL_POS = 3
      OUTPUTLEN = 20
      SCRTEXT_L = 'Professor'
      SCRTEXT_M = 'Prof.'
      SCRTEXT_S = 'Prof'
    )
    ( FIELDNAME = 'START_TIME'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'START TIME'
      COL_POS = 4
      OUTPUTLEN = 20
      SCRTEXT_L = 'Start Time'
      SCRTEXT_M = 'S.Time'
      SCRTEXT_S = 'Strt'
    )
    ( FIELDNAME = 'END_TIME'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'END TIME'
      COL_POS = 5
      OUTPUTLEN = 20
      SCRTEXT_L = 'End Time'
      SCRTEXT_M = 'E.Time'
      SCRTEXT_S = 'End'
    )
    ( FIELDNAME = 'WEEK_DAY'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'WEEK DAY'
      COL_POS = 6
      OUTPUTLEN = 20
      SCRTEXT_L = 'Week Day'
      SCRTEXT_M = 'Days'
      SCRTEXT_S = 'Days'
    )
    ( FIELDNAME = 'TOTAL_STUDENTS'
      ref_table = 'ZCOGUNICLASS'
      COLTEXT = 'TOTAL STUDENTS'
      COL_POS = 7
      OUTPUTLEN = 20
      SCRTEXT_L = 'Total Students'
      SCRTEXT_M = 'Total St.'
      SCRTEXT_S = 'T.St'
    )
   ).
*  Field Catalog IT_FCAT2 in association with the table ZCOGUNISTUDENTS
   it_fcat2[] = VALUE lvc_t_fcat(
    ( FIELDNAME = 'STUDENT_NUM'
      REF_TABLE = 'IT_ZCOGUNISTUDENTS'
      COLTEXT = 'S.NUM'
      COL_POS = 1
      OUTPUTLEN = 20
      SCRTEXT_L = 'Student Number'
      SCRTEXT_M = 'S.Num'
      SCRTEXT_S = 'S.Num'

    )
    ( FIELDNAME = 'AGE'
      REF_TABLE = 'IT_ZCOGUNISTUDENTS'
      COLTEXT = 'AGE'
      COL_POS = 2
      OUTPUTLEN = 20
      SCRTEXT_L = 'Age'
      SCRTEXT_M = 'Age'
      SCRTEXT_S = 'Age'
    )
    ( FIELDNAME = 'GENDER'
      REF_TABLE = 'IT_ZCOGUNISTUDENTS'
      COLTEXT = 'GENDER'
      COL_POS = 3
      OUTPUTLEN = 20
      SCRTEXT_L = 'Gender'
      SCRTEXT_M = 'Gender'
      SCRTEXT_S = 'Gender'
    )
    ( FIELDNAME = 'RESIDENCY'
      REF_TABLE = 'IT_ZCOGUNISTUDENTS'
      COLTEXT = 'RESIDENCY'
      COL_POS = 4
      OUTPUTLEN = 20
      SCRTEXT_L = 'Residency'
      SCRTEXT_M = 'Residency'
      SCRTEXT_S = 'Resdc'
    )
    ( FIELDNAME = 'NAME'
      REF_TABLE = 'IT_ZCOGUNISTUDENTS'
      COLTEXT = 'NAME'
      COL_POS = 5
      OUTPUTLEN = 20
      SCRTEXT_L = 'Name'
      SCRTEXT_M = 'Name'
      SCRTEXT_S = 'Name'
    )
    ( FIELDNAME = 'LAST_NAME'
      REF_TABLE = 'IT_ZCOGUNISTUDENTS'
      COLTEXT = 'LAST NAME'
      COL_POS = 6
      OUTPUTLEN = 20
      SCRTEXT_L = 'Last Name'
      SCRTEXT_M = 'L.Name'
      SCRTEXT_S = 'LN'
    )
   ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Include          ZCOGUNIALV_TOP
*&---------------------------------------------------------------------*

*** DATA TYPE DEFINITIONS FOR OUR 3 TABLES (STUDENT, CLASS, AND REGISTER) ***

TYPES : BEGIN OF ty_zcoguniclass,
          cname          TYPE zcoguniclass-name,
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
*       lo_layout    TYPE REF TO cl_salv_layout,
       lo_events    TYPE REF TO cl_salv_events_table,
*       lo_msg       TYPE REF TO cx_salv_msg,
*       lo_selection TYPE REF TO cl_salv_selections,
*       lv_string    TYPE string,
       ls_key       TYPE salv_s_layout_key.

*** OBJECT DEFINITIONS TO CONSTRUCT DYNAMIC FIELD CATALOG BASED ON A TEXT ELEMENT ***

DATA: go_structdescr  TYPE REF TO cl_abap_structdescr,
      go_structdescr1 TYPE REF TO cl_abap_structdescr,
      go_structdescr2 TYPE REF TO cl_abap_structdescr,
      go_table        TYPE REF TO cl_abap_tabledescr,
      go_table1       TYPE REF TO cl_abap_tabledescr,
      go_table2       TYPE REF TO cl_abap_tabledescr,
      count_offset TYPE i VALUE 1.

DATA:   gv_class TYPE CHAR20 VALUE 'IT_COGUNICLASS',
        gv_stdn  TYPE CHAR20 VALUE 'IT_ZCOGUNISTUDENTS',
        gv_cureg TYPE CHAR20 VALUE 'IT_ZCUREGIST'.

CONSTANTS: fieldcat_string TYPE string VALUE 'Classes,Section,Student Num.,Name,Section,Professor,Start Time,End Time,Week Day,Total Students,Student Number,Age,Gender,Residency,Name,Last Name',
           to_hotspot      TYPE string VALUE 'SNUM,CNAME'.


CLASS lcl_hotspot_handler DEFINITION.
  PUBLIC SECTION.
* We call the event method, as well as import a parameter that lets us take which column triggers the event
    CLASS-METHODS :
      handle_hotspot_click FOR EVENT link_click OF cl_salv_events_table IMPORTING row column,
      generate_output IMPORTING lv_fcat TYPE lvc_t_fcat CHANGING lt_name TYPE ANY TABLE.
ENDCLASS.
DATA lo_event_handler TYPE REF TO lcl_hotspot_handler.

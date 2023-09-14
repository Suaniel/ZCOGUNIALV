*&---------------------------------------------------------------------*
*& Report zcogunialv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcogunialv.

*** OBJECT DEFINITIONS ***
DATA : OB_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       OB_GRID TYPE REF TO CL_GUI_ALV_GRID,
       OB_CUREGIST_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       OB_CUREGIST_GRID TYPE REF TO CL_GUI_ALV_GRID.

*** DATA TYPE DEFINITIONS ***
TYPES : BEGIN OF TY_ZCOGUNICLASS,
          name           TYPE ZCOGUNICLASS-name,
          class_section  TYPE ZCOGUNICLASS-class_section,
          professor      TYPE ZCOGUNICLASS-professor,
          start_time     TYPE ZCOGUNICLASS-start_time,
          end_time       TYPE ZCOGUNICLASS-end_time,
          week_day       TYPE ZCOGUNICLASS-week_day.
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
       LT_ZCUREGIST       TYPE STANDARD TABLE OF TY_ZCUREGIST,
       IT_FCAT            TYPE LVC_T_FCAT,
       WA_FCAT            TYPE LVC_S_FCAT,
       IT_FCAT1           TYPE LVC_T_FCAT,
       WA_FCAT1           TYPE LVC_S_FCAT.

*** CLASS DEFINITION AND IMPLEMENTATION ***
CLASS LCL_HOTSPOT DEFINITION.
  PUBLIC SECTION.
* We call the event method, as well as import a parameter that lets us take which column triggers the event
    METHODS HANDLE_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID IMPORTING E_COLUMN_ID ES_ROW_NO.
ENDCLASS.

CLASS LCL_HOTSPOT IMPLEMENTATION. "currenly doesnt let me take the value of which field is clicked on
  METHOD HANDLE_HOTSPOT_CLICK.
    CASE E_COLUMN_ID-FIELDNAME.
      WHEN 'NAME'.
        IF SY-SUBRC = 0.
          " Read the value in which the name matches the selected name from the class table to the work area
          CLEAR WA_ZCOGUNICLASS.
          READ TABLE IT_ZCOGUNICLASS INTO WA_ZCOGUNICLASS INDEX ES_ROW_NO-ROW_ID.
          " Get Student Data in relation to the class registered if available
          PERFORM GET_STUDENT.
          IF lt_zcuregist IS NOT INITIAL.
            "Display Student Data
            CALL SCREEN 200.
          ELSE.
            MESSAGE 'NO CLASS TO STUDENT DATA WAS RETRIEVED' TYPE 'I'.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        MESSAGE 'Double Click event: triggered???' TYPE 'I'.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

DATA OB1 TYPE REF TO LCL_HOTSPOT.

*** MAIN PROGRAM. FUNCTIONALITY AND PERFORMS ***
START-OF-SELECTION.

PERFORM FILLFCATCLASS.
" CREATE FIELD CATALOG FOR CLASS-STUDENT (ZCUREGIST) TABLE
PERFORM ZCUREGISTFLDCTG.

CALL SCREEN 100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF OB_CONT IS NOT BOUND.
    SET PF-STATUS 'STATUS100'.
    CREATE OBJECT ob_cont
      EXPORTING
        container_name              = 'CUSTCTRL1'.

    CREATE OBJECT ob_grid
      EXPORTING
        i_parent          = OB_CONT.

* Get Data from Class Table
    PERFORM GET_COGUNICLASS.
* Register the Handler for HotSpot Event.
    PERFORM REGISTERHANDLER.
    IF IT_ZCOGUNICLASS IS NOT INITIAL.
      PERFORM DISPLAYZCOGUNICLASS. "Display the Data retrieved by the Class Table
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

FORM GET_COGUNICLASS.
  SELECT NAME CLASS_SECTION PROFESSOR START_TIME END_TIME WEEK_DAY FROM ZCOGUNICLASS INTO TABLE IT_ZCOGUNICLASS.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAYZCOGUNICLASS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM displayzcoguniclass .
  CALL METHOD ob_grid->set_table_for_first_display
    CHANGING
      it_fieldcatalog               = it_fcat
      it_outtab                     = it_zcoguniclass.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTERHANDLER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM registerhandler .
  CREATE OBJECT OB1.
  SET HANDLER OB1->HANDLE_HOTSPOT_CLICK FOR OB_GRID. "first object calls the method and the second raises the event
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STUDENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_student.
  SELECT a~NAME, a~CLASS_SECTION, b~STUDENT_NUM
    FROM ZCOGUNISTUDENTS AS b INNER JOIN ZCUREGIST AS c ON b~STUDENT_NUM = c~STUDENT_NUM
                              INNER JOIN ZCOGUNICLASS AS a ON a~NAME = c~CLASSES AND
                                                              a~CLASS_SECTION = c~CLASS_SECTION
      INTO TABLE @lt_zcuregist WHERE a~NAME = @WA_ZCOGUNICLASS-name.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  IF OB_CUREGIST_CONT IS NOT BOUND.
    " Linking custom control with container
    SET PF-STATUS 'STATUS200'.
    CREATE OBJECT ob_curegist_cont
      EXPORTING
        container_name              = 'CUSTCTRL2'.
    " Linking Custom Container with Grid
    CREATE OBJECT ob_curegist_grid
      EXPORTING
        i_parent          = OB_CUREGIST_CONT.

    " Show Data retrieved
    PERFORM DISPLAYCUREGISTGRID.
    ELSE.
      CALL METHOD ob_curegist_grid->refresh_table_display. " Refresh data whenever we retrieve it again
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form DISPLAYCUREGISTGRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM displaycuregistgrid .
  CALL METHOD ob_curegist_grid->set_table_for_first_display
    CHANGING
      it_fieldcatalog               = it_fcat1
      it_outtab                     = LT_ZCUREGIST.
ENDFORM.


*** GENERATE CUSTOM FIELD CATALOGS FOR THE INTERNAL TABLES ***

* Field Catalog IT_FCAT1 in association with the table ZCUREGIST
FORM zcuregistfldctg .
  WA_FCAT1-FIELDNAME = 'CLASSES'.
  wa_fcat1-ref_table = 'ZCUREGIST'.
  WA_FCAT1-COLTEXT = 'CLASSES'.
  WA_FCAT1-COL_POS = 1.
  WA_FCAT1-OUTPUTLEN = 40.
  WA_FCAT1-HOTSPOT = 'X'.
  APPEND WA_FCAT1 TO IT_FCAT1.

  CLEAR WA_FCAT1.
  WA_FCAT1-FIELDNAME = 'CLASS_SECTION'.
  wa_fcat1-ref_table = 'ZCUREGIST'.
  WA_FCAT1-COLTEXT = 'SECTION'.
  WA_FCAT1-COL_POS = 2.
  WA_FCAT1-OUTPUTLEN = 3.
  WA_FCAT1-HOTSPOT = 'X'.
  APPEND WA_FCAT1 TO IT_FCAT1.

  CLEAR WA_FCAT1.
  WA_FCAT1-FIELDNAME = 'STUDENT_NUM'.
  wa_fcat1-ref_table = 'ZCUREGIST'.
  WA_FCAT1-COLTEXT = 'STUDENT NUM'.
  WA_FCAT1-COL_POS = 3.
  WA_FCAT1-OUTPUTLEN = 9.
  WA_FCAT1-HOTSPOT = 'X'.
  APPEND WA_FCAT1 TO IT_FCAT1.
ENDFORM.

* Field Catalog IT_FCAT in association with the table ZCOGUNICLASS
FORM fillfcatclass .
  WA_FCAT-FIELDNAME = 'NAME'.
  WA_FCAT-COLTEXT = 'NAME'.
  WA_FCAT-COL_POS = 1.
  WA_FCAT-OUTPUTLEN = 40.
  WA_FCAT-HOTSPOT = 'X'.
  APPEND WA_FCAT TO IT_FCAT.

  CLEAR WA_FCAT.
  WA_FCAT-FIELDNAME = 'CLASS_SECTION'.
  WA_FCAT-COLTEXT = 'SECTION'.
  WA_FCAT-COL_POS = 2.
  WA_FCAT-OUTPUTLEN = 3.
  WA_FCAT-HOTSPOT = 'X'.
  APPEND WA_FCAT TO IT_FCAT.

  CLEAR WA_FCAT.
  WA_FCAT-FIELDNAME = 'PROFESSOR'.
  WA_FCAT-COLTEXT = 'PROFESSOR'.
  WA_FCAT-COL_POS = 3.
  WA_FCAT-OUTPUTLEN = 20.
  WA_FCAT-HOTSPOT = 'X'.
  APPEND WA_FCAT TO IT_FCAT.

  CLEAR WA_FCAT.
  WA_FCAT-FIELDNAME = 'START_TIME'.
  WA_FCAT-COLTEXT = 'START TIME'.
  WA_FCAT-COL_POS = 4.
  WA_FCAT-OUTPUTLEN = 6.
  WA_FCAT-HOTSPOT = 'X'.
  APPEND WA_FCAT TO IT_FCAT.

  CLEAR WA_FCAT.
  WA_FCAT-FIELDNAME = 'END_TIME'.
  WA_FCAT-COLTEXT = 'END TIME'.
  WA_FCAT-COL_POS = 5.
  WA_FCAT-OUTPUTLEN = 6.
  WA_FCAT-HOTSPOT = 'X'.
  APPEND WA_FCAT TO IT_FCAT.

  CLEAR WA_FCAT.
  WA_FCAT-FIELDNAME = 'WEEK_DAY'.
  WA_FCAT-COLTEXT = 'WEEK DAY'.
  WA_FCAT-COL_POS = 6.
  WA_FCAT-OUTPUTLEN = 5.
  WA_FCAT-HOTSPOT = 'X'.
  APPEND WA_FCAT TO IT_FCAT.
ENDFORM.

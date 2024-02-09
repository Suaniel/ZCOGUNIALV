*&---------------------------------------------------------------------*
*& Report zcogunialv
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcogunialv.

INCLUDE ZCOGUNIALV_TOP.

INCLUDE ZCOGUNIALV_F01.

*** MAIN PROGRAM. FUNCTIONALITY AND PERFORMS ***


START-OF-SELECTION.

  PERFORM generate_fcat CHANGING go_table2 go_structdescr2 it_fcat1 it_zcuregist.
  PERFORM generate_fcat CHANGING go_table go_structdescr it_fcat it_zcoguniclass.
  PERFORM generate_fcat CHANGING go_table1 go_structdescr1 it_fcat2 it_zcogunistudents.

  CLEAR count_offset.
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

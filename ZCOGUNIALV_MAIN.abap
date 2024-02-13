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

  PERFORM generate_fcat.

* Get Data from Class Table
  PERFORM get_coguniclass.

  IF it_zcoguniclass IS NOT INITIAL.
    CALL METHOD lcl_hotspot_handler=>generate_output
      EXPORTING
        lv_fcat = it_fcat_class
      CHANGING
        lt_name = it_zcoguniclass.
  ELSE.
    MESSAGE 'Unable to retrieve data from the Class Table' TYPE 'I'.
  ENDIF.

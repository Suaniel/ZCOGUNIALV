FUNCTION zfcat_create_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_TABLE) TYPE  ANY TABLE
*"     VALUE(IM_FCAT) TYPE  STRING
*"     REFERENCE(IM_HOTSPOT) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_LVC_FCAT) TYPE  LVC_T_FCAT
*"     REFERENCE(EX_SLIS_FCAT) TYPE  SLIS_T_FIELDCAT_ALV
*"  RAISING
*"      CX_SY_MOVE_CAST_ERROR
*"----------------------------------------------------------------------

* PROGRAM REQUIREMENTS/DEPENDENCIES:
* - The imported field catalog (IM_FCAT) is in the same order in relation to the imported table fields (IM_TABLE)
* - The hotspot fields imported (IM_HOTSPOT) do not have to be in order, however, they MUST share the same name as the original field name
*   in the imported table (IM_TABLE), NOT the name given in the imported field catalog string (IM_FCAT).


  DATA: lo_structdescr TYPE REF TO cl_abap_structdescr,
        lo_table       TYPE REF TO cl_abap_tabledescr,
        ls_lvc_fcat    TYPE lvc_s_fcat,
        ls_slis_fcat   TYPE slis_fieldcat_alv.

  CONSTANTS: lc_delimiter TYPE CHAR1  VALUE ',',
             lc_tname_del TYPE STRING VALUE '\TYPE=',
             lc_x         TYPE CHAR1  VALUE 'X'.

  TRY.
      "RETRIEVES THE DATA FROM THE OUTPUT TABLES AND GETS THE INDIVIDUAL COMPONENT INFORMATION (name, table name, length of field...)
      lo_table ?= cl_abap_typedescr=>describe_by_data( im_table ).
      lo_structdescr ?= lo_table->get_table_line_type( ).
    CATCH cx_sy_move_cast_error.
  ENDTRY.


  SPLIT: im_fcat    AT lc_delimiter INTO TABLE DATA(fcat_tab), "Imported field catalog string is split at the delimiter and assigned to a table
         im_hotspot AT lc_delimiter INTO TABLE DATA(hs_tab), "Imported hotspot field string (in reference to their original field names) is split at the delimiter and assigned to a table
         lo_structdescr->absolute_name AT lc_tname_del INTO DATA(path) DATA(table_name). "Absolute name attribute gives us the path to the table type reference. Its split into path and name.

*Looping through the acquired components of the imported table.
  LOOP AT lo_structdescr->components INTO DATA(ls_attr).

    "Reading through the table created from the field catalog string imported and split into fields assigned to a table
    READ TABLE fcat_tab INTO DATA(ls_fc) INDEX sy-tabix.

* Create field catalog for lvc_t_fcat type implementation.
    ls_lvc_fcat-fieldname = ls_attr-name.
    ls_lvc_fcat-ref_table = table_name.
    ls_lvc_fcat-coltext = ls_fc.
    ls_lvc_fcat-col_pos = sy-tabix.
    ls_lvc_fcat-Outputlen = ls_attr-length.
    ls_lvc_fcat-scrtext_l = ls_fc.
    ls_lvc_fcat-scrtext_m = ls_fc.
    ls_lvc_fcat-scrtext_s = ls_fc.


* Create field catalog for slis_t_fieldcat_alv type implementation
    ls_slis_fcat-fieldname = ls_attr-name.
    ls_slis_fcat-tabname = table_name.
    ls_slis_fcat-col_pos = sy-tabix.
    ls_slis_fcat-Outputlen = ls_attr-length.
    ls_slis_fcat-seltext_l = ls_fc.
    ls_slis_fcat-seltext_m = ls_fc.
    ls_slis_fcat-seltext_s = ls_fc.

    "Read through the hotspot table (which is only 1 column, thus we access it with 'table line')
    "   and compare the variable to the field name stored in the components of the table imported.
    READ TABLE hs_tab INTO DATA(ls_hs) WITH KEY table_line = ls_attr-name.
    IF sy-subrc = 0.
      ls_lvc_fcat-hotspot = lc_x.
      ls_slis_fcat-hotspot = lc_x.
    ENDIF.

    "Append the retrieved values to both field catalog types the module outputs as exporting parameters
    APPEND: ls_lvc_fcat  TO ex_lvc_fcat,
            ls_slis_fcat TO ex_slis_fcat.

    CLEAR: ls_lvc_fcat, ls_slis_fcat, ls_fc, ls_attr, ls_hs.
  ENDLOOP.

ENDFUNCTION.

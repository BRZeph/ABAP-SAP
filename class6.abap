REPORT YFATEC_JLOPES_CLASSROOM_6.

TABLES: mara, makt.

*mara-mtart  tipo de material
*mara-matkl  grupo de mercadoria
*mara-matnr  codigo
*makt-maktx  descriçao do material

SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
 SELECT-OPTIONS:
   s_matkl for mara-matkl,
   s_mtart for mara-mtart.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 100.

SELECTION-SCREEN: BEGIN OF TABBED BLOCK tabs FOR 5 LINES,
                  TAB (20) tab1 USER-COMMAND PUSH1,
                  END OF BLOCK tabs.


CLASS zcl_material_report DEFINITION.
  PUBLIC SECTION.
    TYPES: lr_matkl TYPE RANGE OF mara-matkl,
           lr_mtart TYPE RANGE OF mara-mtart.
    METHODS: initialize_screen,
             select_data
              IMPORTING ls_matkl TYPE lr_matkl
                        ls_mtart TYPE lr_mtart,
             display_alv.

  PRIVATE SECTION.
    TYPES: BEGIN OF lcy_exercicio,
          mtart TYPE mara-mtart,
          matkl TYPE mara-matkl,
          matnr TYPE mara-matnr,
          maktx TYPE makt-maktx,
          END OF lcy_exercicio.
      DATA: lco_salv TYPE REF TO cl_salv_table,
        lco_functions TYPE REF TO cl_salv_functions,
        lct_exercicio TYPE TABLE OF lcy_exercicio.


ENDCLASS.

CLASS zcl_material_report IMPLEMENTATION.

  METHOD select_data.
      SELECT (lct_exercicio)
    FROM mara
    INNER JOIN makt on mara~matnr = makt~matnr
    WHERE mara~matkl in @ls_matkl[] and mara~mtart in @ls_mtart[]
    INTO CORRESPONDING FIELDS OF TABLE @lct_exercicio.

  IF sy-subrc NE 0.
     MESSAGE 'Não foi possível encontrar os dados, tente novamente' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  ENDMETHOD.

  METHOD display_alv.

    IF lct_exercicio IS NOT INITIAL.
        TRY.
            cl_salv_table=>factory(
            IMPORTING
              r_salv_table = lco_salv
            CHANGING
              t_table      = lct_exercicio
              ).

          lco_functions = lco_salv->get_functions( ).
          lco_functions->set_all( abap_true ).
          lco_salv->display( ).
        CATCH cx_salv_msg.

        ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD initialize_screen.

  tab1 = 'Seleção de dados'.
  tabs-prog = sy-repid.
  tabs-dynnr = 100.

  ENDMETHOD.

ENDCLASS.

DATA: lo_exercicio TYPE REF TO zcl_material_report.

LOAD-OF-PROGRAM.
  CREATE OBJECT lo_exercicio.

 INITIALIZATION.
  lo_exercicio->initialize_screen( ).

START-OF-SELECTION.

  lo_exercicio->select_data( EXPORTING ls_matkl = s_matkl[]
                                        ls_mtart = s_mtart[] ).

  lo_exercicio->display_alv( ).

END-OF-SELECTION.
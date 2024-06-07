REPORT YFATEC_JLOPES_CLASSROOM_7.

TABLES: vbak, kna1.

*vbak-vbeln Documento de venda
*vbak-erdat Data de venda
*vbak-netwr  Valor líquido
*vbak-kunnr  Nº do cliente
*kna1-name1  Nome do cliente

SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
 SELECT-OPTIONS:
   s_kunnr for vbak-kunnr,
   s_erdat for vbak-erdat.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 100.

SELECTION-SCREEN: BEGIN OF TABBED BLOCK tabs FOR 5 LINES,
                  TAB (20) tab1 USER-COMMAND PUSH1,
                  END OF BLOCK tabs.


CLASS zcl_sales_report DEFINITION.
  PUBLIC SECTION.
    TYPES: lr_kunnr TYPE RANGE OF vbak-kunnr,
           lr_erdat TYPE RANGE OF vbak-erdat.
    METHODS: initialize_screen,
             select_data
              IMPORTING ls_kunnr TYPE lr_kunnr
                        ls_erdat TYPE lr_erdat,
             display_alv.

  PRIVATE SECTION.
    TYPES: BEGIN OF lcy_exercicio,
          vbeln TYPE vbak-vbeln,
          name1 TYPE kna1-name1,
          erdat TYPE vbak-erdat,
          netwr TYPE vbak-netwr,
          END OF lcy_exercicio.
      DATA: lco_salv TYPE REF TO cl_salv_table,
        lco_functions TYPE REF TO cl_salv_functions,
        lct_exercicio TYPE TABLE OF lcy_exercicio.


ENDCLASS.

CLASS zcl_sales_report IMPLEMENTATION.

  METHOD select_data.

    SELECT vbak~vbeln, kna1~name1, vbak~erdat, vbak~netwr
    FROM vbak
    INNER JOIN kna1 on vbak~kunnr = kna1~kunnr
    WHERE vbak~kunnr in @ls_kunnr[] and vbak~erdat in @ls_erdat[]
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

DATA: lo_exercicio TYPE REF TO zcl_sales_report.

LOAD-OF-PROGRAM.
  CREATE OBJECT lo_exercicio.

 INITIALIZATION.
  lo_exercicio->initialize_screen( ).

START-OF-SELECTION.

  lo_exercicio->select_data( EXPORTING ls_kunnr = s_kunnr[]
                                        ls_erdat = s_erdat[] ).

  lo_exercicio->display_alv( ).

END-OF-SELECTION.
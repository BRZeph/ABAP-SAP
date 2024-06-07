REPORT YFATEC_JLOPES_CLASSROOM_2.

DATA: lo_salv TYPE REF TO cl_salv_table,
      lo_functions TYPE REF TO cl_salv_functions.

TABLES: vbak, kna1.

*vbak-vbeln Documento de venda
*vbak-erdat Data de venda
*vbak-netwr  Valor líquido
*vbak-kunnr  Nº do cliente
*kna1-name1  Nome do cliente

SELECT-OPTIONS:
      s_kunnr for kna1-kunnr,
      s_erdat for vbak-erdat.

START-OF-SELECTION.

  select vbak~vbeln, kna1~name1, vbak~erdat, vbak~netwr
    FROM vbak
    INNER JOIN kna1 on vbak~kunnr = kna1~kunnr
    WHERE vbak~kunnr in @s_kunnr[] and vbak~erdat in @s_erdat[]
    INTO TABLE @data(lt_exercicio).


  IF sy-subrc EQ 0.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_salv
        CHANGING
          t_table      = lt_exercicio
          ).

      lo_functions = lo_salv->get_functions( ).
      lo_functions->set_all( abap_true ).

      lo_salv->display( ).
  ELSE.
    MESSAGE 'Não foi possível encontrar os dados, tente novamente' TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

END-OF-SELECTION.
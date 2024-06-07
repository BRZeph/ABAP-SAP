REPORT YFATEC_JLOPES_CLASSROOM_3.

DATA: lo_salv TYPE REF TO cl_salv_table,
      lo_functions TYPE REF TO cl_salv_functions.

TABLES: eina, lfa1, ekpo.

*eina-infnr  N° doc de compra
*eina-lifnr N do fornecedor
*eina-erdat  Data de compra
*ekpo-netwr  Valor liquido da compra
*lfa1-name1  Nome do fornecedor

SELECT-OPTIONS:
     s_lifnr for eina-lifnr,
     s_erdat for eina-erdat.

START-OF-SELECTION.

  select eina~infnr, lfa1~name1, eina~erdat, SUM( ekpo~netwr ) as valor_total
    FROM eina
    INNER JOIN lfa1 on eina~lifnr = lfa1~lifnr
    INNER JOIN ekpo on eina~infnr = ekpo~infnr
    WHERE eina~lifnr IN @s_lifnr[] AND eina~erdat in @s_erdat[]
    GROUP BY eina~infnr, lfa1~name1, eina~erdat
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
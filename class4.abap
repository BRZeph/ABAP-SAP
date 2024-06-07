REPORT YFATEC_JLOPES_CLASSROOM_4.

TABLES: marc, mard.

*marc-matnr material
*marc-werks centro
*mard-labst estoque disponível

Select-OPTIONS:
  s_werks for marc-werks,
  s_matnr for marc-matnr.

INITIALIZATION.
  DATA: lo_salv TYPE REF TO cl_salv_table,
        lo_functions TYPE REF TO cl_salv_functions.

START-OF-SELECTION.

  SELECT marc~werks, marc~matnr, mard~labst
    FROM marc
    INNER JOIN mard on marc~matnr = mard~matnr AND marc~werks = mard~werks
    WHERE marc~matnr in @s_matnr[] AND marc~werks IN @s_werks[]
    INTO TABLE @DATA(lt_exercicio).

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
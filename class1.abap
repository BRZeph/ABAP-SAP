REPORT YFATEC_JLOPES_CLASSROOM_1.

TABLES: mara, makt.

*mara-matnr  Cod do material
*makt-maktx  Descrição do material
*mara-matkl  Grupo de materiais

DATA: lo_salv TYPE REF TO cl_salv_table,
      lo_functions TYPE REF TO cl_salv_functions.

SELECT-OPTIONS:
      s_matkl FOR mara-matkl.

START-OF-SELECTION.

  SELECT mara~matnr, makt~maktx, mara~matkl
    FROM mara
    INNER JOIN makt ON mara~matnr = makt~matnr
    WHERE mara~matkl IN @s_matkl[]
    INTO TABLE @DATA(lt_mara).

  IF sy-subrc EQ 0.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_salv
        CHANGING
          t_table      = lt_mara
          ).

      lo_functions = lo_salv->get_functions( ).
      lo_functions->set_all( abap_true ).

      lo_salv->display( ).
  ELSE.
    MESSAGE 'Não foi possível encontrar os dados, tente novamente' TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Include          ZGESTION_PED_AB1510_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module M_STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE m_status_9000 OUTPUT.
  SET PF-STATUS 'STATUS_9000'.
  SET TITLEBAR 'TITLE_9000'.
ENDMODULE.

MODULE m_cargar_datos OUTPUT.

  "Preparo la tabla que vemos en el ALV
  IF go_pedido IS BOUND."Si el objeto existe
    REFRESH gt_lineas."dejamos limpia la tabla
    MOVE-CORRESPONDING go_pedido->posiciones TO gt_lineas."pasamos posiciones del pedido a la tabla

    "Pongo icono papelera
    LOOP AT gt_lineas ASSIGNING FIELD-SYMBOL(<fs>).
      <fs>-borrar = '@11@'.
    ENDLOOP.

  ELSE.
    REFRESH gt_lineas.
  ENDIF.

  "Pintamos el ALV
  IF go_alv IS NOT BOUND."si no existe
    "creamos el contenedor y metemos el alv dentro
    CREATE OBJECT go_cc
      EXPORTING
        container_name = 'CC1'.

    cl_salv_table=>factory(
         EXPORTING
           r_container  = go_cc
         IMPORTING
           r_salv_table = go_alv
         CHANGING
           t_table      = gt_lineas ).

      "Ajusto el ancho de las columnas al contenido
    go_columns = go_alv->get_columns( ).
    go_columns->set_optimize( 'X' ).

    "Pongo título a la columna de la papelera
    TRY.
        go_column = go_columns->get_column( 'BORRAR' ).
        go_column->set_short_text( 'Borrar' ).
        go_column->set_medium_text( 'Borrar' ).
        go_column->set_long_text( 'Borrar posición' ).
      CATCH cx_salv_not_found.
*       Si no existe la columna, no hago nada
    ENDTRY.

    "Engancho el doble clic del ALV con mi clase lcl_handler
    DATA: go_handler TYPE REF TO lcl_handler.
    DATA: go_events  TYPE REF TO cl_salv_events_table.

    go_events = go_alv->get_event( ).

    CREATE OBJECT go_handler.
    SET HANDLER go_handler->on_double_click FOR go_events.

    go_alv->display( ).

  ELSE.

   "El ALV ya existe: solo le digo que se repinte con los datos nuevos
    go_alv->refresh( ).

  ENDIF.
ENDMODULE.

MODULE m_status_9001 OUTPUT.

  SET PF-STATUS 'STATUS_9001'.
  SET TITLEBAR 'TITLE_9001'.

ENDMODULE.

MODULE m_status_9002 OUTPUT.

  SET PF-STATUS 'STATUS_9002'.
  SET TITLEBAR 'TITLE_9002'.

ENDMODULE.
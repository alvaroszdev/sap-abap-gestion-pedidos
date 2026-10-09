*&---------------------------------------------------------------------*
*& Include          ZGESTION_PED_AB1510_TOP
*&---------------------------------------------------------------------*

tables zvbak_ab1510. "cabecera del pedido
tables zvbap_ab1510. "Posiciones nuevas

data ok_code type sy-ucomm.
data:go_pedido TYPE REF TO zcl_pedido_ab1510.     "creo un objeto y le doy la forma de la clase
DATA: go_cc  TYPE REF TO cl_gui_custom_container, "codigo para crear el ALV
      go_alv TYPE REF TO cl_salv_table.
DATA: gv_numero TYPE zvbak_ab1510-zvbeln_ab1510. "Numero de pedido que me devuelve el rango al crearlo

 "Para retocar las columnas del ALV (títulos y ancho)
DATA: go_columns TYPE REF TO cl_salv_columns_table,
      go_column  TYPE REF TO cl_salv_column.


TYPES: BEGIN OF ty_linea,
         zvbeln_ab1510    TYPE zvbap_ab1510-zvbeln_ab1510,
         zposnt_ab1510    TYPE zvbap_ab1510-zposnt_ab1510,
         matnr            TYPE zvbap_ab1510-matnr,             "Damos forma a la tabla
         charg            TYPE zvbap_ab1510-charg,
         meins            TYPE zvbap_ab1510-meins,
         zcantidad_ab1510 TYPE zvbap_ab1510-zcantidad_ab1510,
         zprecio_ab1510   TYPE zvbap_ab1510-zprecio_ab1510,
         borrar           TYPE char4,
       END OF ty_linea.


DATA: gt_lineas TYPE STANDARD TABLE OF ty_linea. "creo una tabla para el alv
                                                  "de la forma ty_linea

DATA: gv_posicion TYPE zvbap_ab1510-zposnt_ab1510. "variable para guardar el numero de posicion
                                                   " para borrar

CLASS lcl_handler DEFINITION.

  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row
                  column.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_double_click.

    IF column EQ 'BORRAR'.
      "Leo la fila pulsada para saber qué número de posición tiene
      READ TABLE gt_lineas INTO DATA(ls_linea) INDEX row.
      IF sy-subrc EQ 0.
        "Le pido al pedido que quite esa posición
        CALL METHOD go_pedido->quitar_linea
          EXPORTING
            in_pos = ls_linea-zposnt_ab1510.

        "Fuerzo que la pantalla pase por el PAI y el PBO para que
        "la tabla se repinte sin la posición que acabo de quitar
        cl_gui_cfw=>set_new_ok_code( 'REFRESCA' ).

      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Report ZLISTADO_PED_AB1510
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlistado_ped_ab1510.


"Declaro las tablas
TABLES: zvbak_ab1510,zvbap_ab1510.


"creamos las filas y posiciones qu evamos a dar a una tabla
TYPES: BEGIN OF ty_salida,
         zvbeln_ab1510    TYPE zvbak_ab1510-zvbeln_ab1510,
         zerdat_ab1510    TYPE zvbak_ab1510-zerdat_ab1510,
         zoferta_ab1510   TYPE zvbak_ab1510-zoferta_ab1510,
         zbnddt_ab1510    TYPE zvbak_ab1510-zbnddt_ab1510,
         zwaerk_ab1510    TYPE zvbak_ab1510-zwaerk_ab1510,
         zkunnr_ab1510    TYPE zvbak_ab1510-zkunnr_ab1510,
         zgenvio_ab1510   TYPE zvbak_ab1510-zgenvio_ab1510,
         ziva_ab1510      TYPE zvbak_ab1510-ziva_ab1510,
         zmjhar_ab1510    TYPE zvbak_ab1510-zmjhar_ab1510,
         zposnt_ab1510    TYPE zvbap_ab1510-zposnt_ab1510,
         matnr            TYPE zvbap_ab1510-matnr,
         charg            TYPE zvbap_ab1510-charg,
         meins            TYPE zvbap_ab1510-meins,
         zcantidad_ab1510 TYPE zvbap_ab1510-zcantidad_ab1510,
         zprecio_ab1510   TYPE zvbap_ab1510-zprecio_ab1510,
       END OF ty_salida.

"Creamos nuestra tabla con los datos del ty_

DATA: gt_salida TYPE STANDARD TABLE OF ty_salida.

"Creamos el alv
DATA: go_alv       TYPE REF TO cl_salv_table,
      go_functions TYPE REF TO cl_salv_functions_list.

"Hacemos la pantalla de seleccion

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_vbeln FOR zvbak_ab1510-zvbeln_ab1510, "pedido
                  so_erdat FOR zvbak_ab1510-zerdat_ab1510, "fecha de creacion
                  so_bnddt FOR zvbak_ab1510-zbnddt_ab1510, "limite de validez
                  so_kunnr FOR zvbak_ab1510-zkunnr_ab1510, "cliente
                  so_matnr FOR zvbap_ab1510-matnr,         "material
                  so_prec  FOR zvbap_ab1510-zprecio_ab1510."precio

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.


  SELECT k~zvbeln_ab1510 k~zerdat_ab1510 k~zoferta_ab1510
       k~zbnddt_ab1510 k~zwaerk_ab1510 k~zkunnr_ab1510
       k~zgenvio_ab1510 k~ziva_ab1510 k~zmjhar_ab1510
       p~zposnt_ab1510 p~matnr p~charg p~meins
       p~zcantidad_ab1510 p~zprecio_ab1510
  FROM zvbak_ab1510 AS k                            "a la tabla zvbap la llamo K
  INNER JOIN zvbap_ab1510 AS p                      "a la tabla zvbap la llamo P
    ON p~zvbeln_ab1510 = k~zvbeln_ab1510
  INTO CORRESPONDING FIELDS OF TABLE gt_salida
  WHERE k~zvbeln_ab1510  IN so_vbeln
    AND k~zerdat_ab1510  IN so_erdat
    AND k~zbnddt_ab1510  IN so_bnddt
    AND k~zkunnr_ab1510  IN so_kunnr
    AND p~matnr          IN so_matnr
    AND p~zprecio_ab1510 IN so_prec.

  IF sy-subrc NE 0.
    MESSAGE 'No hay nada que mostrar' TYPE 'E'.

  ENDIF.

  "Los ordeno por pedido y posición para que se lean bien

  SORT gt_salida BY zvbeln_ab1510 zposnt_ab1510.

"Creo el ALV con la tabla de resultados
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_salida ).

"Activo la barra de botones: ordenar, filtrar, exportar...
      go_functions = go_alv->get_functions( ).
      go_functions->set_all( 'X' ).

      go_alv->display( ).

    CATCH cx_salv_msg.
      MESSAGE 'Error al mostrar el listado' TYPE 'E'.
  ENDTRY.
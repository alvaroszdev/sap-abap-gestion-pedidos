class ZCL_PEDIDO_AB1510 definition
  public
  final
  create public .

public section.

  data CABECERA type ZVBAK_AB1510 .
  data POSICIONES type ZTT_ZVBAP_AB1510 .

  methods CONSTRUCTOR
    importing
      !IN_CAB type ZVBAK_AB1510 .
  methods ADD_LINEA
    importing
      !IN_LINEA type ZVBAP_AB1510 .
  methods QUITAR_LINEA
    importing
      !IN_POS type ZPOSNT_AB1510 .
  methods SAVE .
  methods REFRESCAR .
  methods BORRAR
    importing
      !IN_PED type ZVBELN_AB1510 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_PEDIDO_AB1510 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDO_AB1510->ADD_LINEA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IN_LINEA                       TYPE        ZVBAP_AB1510
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_linea.

      DATA: ls_linea TYPE zvbap_ab1510,
            ls_mara  TYPE zmara_ab1510,
            ls_pos   TYPE zvbap_ab1510,
            lv_ult   TYPE zposnt_ab1510.

      ls_linea = in_linea.

* Buscar el material en el maestro
      SELECT SINGLE *
        FROM zmara_ab1510
        INTO ls_mara
        WHERE matnr EQ ls_linea-matnr.

      IF sy-subrc NE 0.
        MESSAGE 'El material no existe' TYPE 'I'.
        RETURN.
      ENDIF.

* Copiar los datos del material a la línea
      ls_linea-charg          = ls_mara-charg.
      ls_linea-meins          = ls_mara-meins.
      ls_linea-zprecio_ab1510 = ls_mara-zprecio_ab1510.

* Número de pedido de la cabecera
      ls_linea-zvbeln_ab1510 = cabecera-zvbeln_ab1510.

* Siguiente número de posición (10, 20, 30...)
      LOOP AT posiciones INTO ls_pos.
        IF ls_pos-zposnt_ab1510 GT lv_ult.
          lv_ult = ls_pos-zposnt_ab1510.
        ENDIF.
      ENDLOOP.
      ls_linea-zposnt_ab1510 = lv_ult + 10.

      APPEND ls_linea TO posiciones.

    ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDO_AB1510->BORRAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IN_PED                         TYPE        ZVBELN_AB1510
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD borrar.

    DELETE FROM zvbak_ab1510 WHERE zvbeln_ab1510 EQ in_ped.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE 'Pedido eliminado' TYPE 'S'.

      DELETE FROM zvbap_ab1510 WHERE zvbeln_ab1510 EQ in_ped.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
        MESSAGE 'Pedido eliminado' TYPE 'S'.
      ENDIF.

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDO_AB1510->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IN_CAB                         TYPE        ZVBAK_AB1510
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CONSTRUCTOR.

    clear cabecera.
    cabecera = in_cab.

    REFRESH posiciones[].

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDO_AB1510->QUITAR_LINEA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IN_POS                         TYPE        ZPOSNT_AB1510
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD quitar_linea.

    DELETE posiciones WHERE zposnt_ab1510 EQ in_pos.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDO_AB1510->REFRESCAR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD refrescar.

    CLEAR cabecera.
    REFRESH posiciones.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_PEDIDO_AB1510->SAVE
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD save.

      IF posiciones IS INITIAL OR cabecera IS INITIAL.

        MESSAGE 'Debes añadir alguna linea y cabecera' TYPE 'I'.

      ELSE.

        MODIFY zvbak_ab1510 FROM cabecera.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
          MESSAGE 'Pedido grabado en cabecera' TYPE 'I'.
        ELSE.
          MESSAGE 'Error al guardar los datos' TYPE 'I'.
        ENDIF.

        DELETE FROM zvbap_ab1510 WHERE zvbeln_ab1510 EQ cabecera-zvbeln_ab1510.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

        INSERT zvbap_ab1510 FROM TABLE posiciones.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
          MESSAGE 'Posiciones del pedido grabadas' TYPE 'I'.
        ELSE.
          MESSAGE 'Error al guardar los datos' TYPE 'I'.
        ENDIF.

      ENDIF.

    ENDMETHOD.
ENDCLASS.
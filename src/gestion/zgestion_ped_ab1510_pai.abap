*&---------------------------------------------------------------------*
*& Include          ZGESTION_PED_AB1510_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9000 INPUT.
  CASE  ok_code.

    WHEN 'EXIT'.

      LEAVE PROGRAM.

    WHEN 'CANCEL' OR 'BACK'.

      LEAVE TO SCREEN 0.

    WHEN 'CREAR'.

      "Pido el siguiente número de pedido al rango numérico

      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZPEDAB1510'
        IMPORTING
          number                  = gv_numero
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.

      IF sy-subrc NE 0.

        "Sin número no puedo crear el pedido
        MESSAGE 'No se ha podido obtener el número de pedido' TYPE 'I'.

      ELSE.

        "Pongo el número en la cabecera de pantalla y creo el pedido

        zvbak_ab1510-zvbeln_ab1510 = gv_numero.

        CREATE OBJECT go_pedido "crea el objeto pedido
          EXPORTING
            in_cab = zvbak_ab1510. "lo mete en la cabecera

        IF go_pedido IS BOUND. "si existe
          MESSAGE 'Pedido creado!' TYPE 'I'. "pedido creado
        ENDIF.
      ENDIF.

    WHEN 'ADD'.

      IF go_pedido IS BOUND.
        "limpiamos la linea anterior y abro la nueva para escribirla
        CLEAR zvbap_ab1510.

        CALL SCREEN '9001' STARTING AT 5 5
                           ENDING AT 70 12.
      ELSE.
        MESSAGE 'Crea un pedido' TYPE 'I'.
      ENDIF.

    WHEN 'SAVE'.

      IF go_pedido IS BOUND.
        "Guardo en la base de datos la cabecera y posiciones del pedido
        go_pedido->save( ).
      ELSE.
        MESSAGE 'Crea un pedido' TYPE 'I'.
      ENDIF.

    WHEN 'ELIMINAR'."quita una posición del pedido

      IF go_pedido IS BOUND.
        "Limpio la posicion escrita anteriormente para que se quede limpio
        CLEAR gv_posicion.

        CALL SCREEN '9002' STARTING AT 5 5
                           ENDING AT 50 12.
      ELSE.
        MESSAGE 'No hay ningun pedido abierto' TYPE 'I'.
      ENDIF.

    WHEN 'BORRAR'."borra el pedido entero

      IF go_pedido IS BOUND.
        "Borro el pedido de la base de datos (cabecera y posicion)
        go_pedido->borrar( in_ped = go_pedido->cabecera-zvbeln_ab1510 ).
        "vaciamos de memoria y limpiamos pantalla
        go_pedido->refrescar( ).
        CLEAR zvbak_ab1510.
      ELSE.
        MESSAGE 'No hay pedido abierto' TYPE 'I'.
      ENDIF.

    WHEN 'VER'.

      "Esta funcion rellena los ceros de la izquierda y hace que 1 sea 0000000001
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zvbak_ab1510-zvbeln_ab1510
        IMPORTING
          output = zvbak_ab1510-zvbeln_ab1510.

      SELECT SINGLE *
        FROM zvbak_ab1510
        INTO zvbak_ab1510
        WHERE zvbeln_ab1510 EQ zvbak_ab1510-zvbeln_ab1510."Me trae la fila cuya columna coincide con la escrita
      " en esa pantalla
      IF sy-subrc EQ 0.

        "Existe: creo el objeto con la cabecera que acabo de leer
        CREATE OBJECT go_pedido
          EXPORTING
            in_cab = zvbak_ab1510.

        "Y cargo sus posiciones directamente en el objeto
        SELECT *
          FROM zvbap_ab1510
          INTO TABLE go_pedido->posiciones
          WHERE zvbeln_ab1510 EQ zvbak_ab1510-zvbeln_ab1510.

      ELSE.
        MESSAGE 'El pedido no existe' TYPE 'I'.
      ENDIF.

    WHEN 'REFRESCAR'.

      IF go_pedido IS BOUND. "si el pedido existe

        go_pedido->refrescar( ). "lo refreca

        CLEAR zvbak_ab1510."limpia la cabecera
      ELSE.
        MESSAGE 'No hay ningun pedido abierto' TYPE 'I'."si no mensaje de que no existe
      ENDIF.

  ENDCASE.

  CLEAR ok_code.

ENDMODULE.

MODULE m_user_command_9001 INPUT.



  CASE ok_code.

    WHEN 'OK'.

*     Le paso al pedido la línea que ha escrito el usuario.
*     La clase busca el material y completa precio, unidad y grupo.
      CALL METHOD go_pedido->add_linea
        EXPORTING
          in_linea = zvbap_ab1510.

      CLEAR zvbap_ab1510.
      LEAVE TO SCREEN 0.

    WHEN 'CANCELAR'.
      LEAVE TO SCREEN 0.


  ENDCASE.

  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9002 INPUT.

  CASE ok_code.

    WHEN 'OK'.
      "Le pido al pedido que quite la posición que ha escrito el usuario
      CALL METHOD go_pedido->quitar_linea
        EXPORTING
          in_pos = gv_posicion.

      CLEAR zvbap_ab1510.
      LEAVE TO SCREEN 0.

    WHEN 'CANCELAR'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
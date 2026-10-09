*&---------------------------------------------------------------------*
*& Report ZGESTION_PED_AB1510
*&---------------------------------------------------------------------*
*& Sistema Gestor de Pedidos de Ventas (SGPV)
*& Proyecto final del curso SAP Full Stack - Álvaro Salvador (AB1510)
*&
*& Transacción para la gestión integral de pedidos de ventas:
*&   - Crear pedidos (con número automático del rango ZPEDAB1510)
*&   - Añadir y quitar posiciones
*&   - Grabar, visualizar y borrar pedidos
*&
*& Tablas: ZVBAK_AB1510 (cabecera), ZVBAP_AB1510 (posiciones)
*&         ZMARA_AB1510 (maestro de materiales)
*& Clase:  ZCL_PEDIDO_AB1510 (lógica del pedido)
*&---------------------------------------------------------------------*
REPORT zgestion_ped_ab1510.

"Organizo el programa en includes para separar responsabilidades:
"las declaraciones, lo que pasa antes de pintar la pantalla y lo que
"pasa cuando el usuario pulsa un botón.
INCLUDE zgestion_ped_ab1510_top.   "Declaraciones globales y handler del ALV
INCLUDE zgestion_ped_ab1510_pbo.   "Módulos PBO: status, título y ALV
INCLUDE zgestion_ped_ab1510_pai.   "Módulos PAI: acciones de cada botón

START-OF-SELECTION.

"Arranco la aplicación mostrando la pantalla principal
  CALL SCREEN 9000.
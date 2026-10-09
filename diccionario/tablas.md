# Diccionario de datos

Objetos del diccionario ABAP (SE11) creados para el proyecto.

## ZVBAK_AB1510 — Pedidos: datos de cabecera

| Campo | Clave | Elemento de datos | Tipo | Long. | Dec. | Descripción |
|---|:---:|---|---|---:|---:|---|
| MANDT | X | MANDT | CLNT | 3 | 0 | Mandante |
| ZVBELN_AB1510 | X | ZVBELN_AB1510 | CHAR | 10 | 0 | Pedido de ventas |
| ZERDAT_AB1510 | | ZERDAT_AB1510 | DATS | 8 | 0 | Fecha de creación del registro |
| ZOFERTA_AB1510 | | ZOFERTA_AB1510 | CHAR | 10 | 0 | Oferta |
| ZBNDDT_AB1510 | | ZBNDDT_AB1510 | DATS | 8 | 0 | Pedido válido hasta |
| ZWAERK_AB1510 | | ZWAERK_AB1510 | CUKY | 5 | 0 | Moneda de documento comercial |
| ZKUNNR_AB1510 | | ZKUNNR_AB1510 | CHAR | 10 | 0 | Número de deudor |
| ZGENVIO_AB1510 | | ZGENVIO_AB1510 | DEC | 8 | 2 | Gastos de envío |
| ZIVA_AB1510 | | ZIVA_AB1510 | DEC | 7 | 2 | IVA |
| ZMJHAR_AB1510 | | ZMJHAR_AB1510 | CHAR | 4 | 0 | Año fiscal del pedido |

## ZVBAP_AB1510 — Pedidos: datos de posición

| Campo | Clave | Elemento de datos | Tipo | Long. | Dec. | Descripción |
|---|:---:|---|---|---:|---:|---|
| MANDT | X | MANDT | CLNT | 3 | 0 | Mandante |
| ZVBELN_AB1510 | X | ZVBELN_AB1510 | CHAR | 10 | 0 | Pedido de ventas |
| ZPOSNT_AB1510 | X | ZPOSNT_AB1510 | NUMC | 6 | 0 | Posición de pedido |
| MATNR | | ZMATNR | CHAR | 18 | 0 | Nº de artículo |
| CHARG | | ZCHARG | CHAR | 9 | 0 | Grupo de artículo |
| MEINS | | ZMEINS | CHAR | 5 | 0 | Unidad de medida |
| ZCANTIDAD_AB1510 | | ZCANTIDAD_AB1510 | NUMC | 8 | 0 | Cantidad |
| ZPRECIO_AB1510 | | ZPRECIO_AB1510 | DEC | 8 | 2 | Precio por unidad |

## ZMARA_AB1510 — Datos generales de artículos

| Campo | Clave | Elemento de datos | Tipo | Long. | Dec. | Descripción |
|---|:---:|---|---|---:|---:|---|
| MANDT | X | MANDT | CLNT | 3 | 0 | Mandante |
| MATNR | X | ZMATNR | CHAR | 18 | 0 | Nº de artículo |
| ZMDESC_AB1510 | | ZMDESC_AB1510 | CHAR | 100 | 0 | Descripción de material |
| CHARG | | ZCHARG | CHAR | 9 | 0 | Grupo de artículo |
| MEINS | | ZMEINS | CHAR | 5 | 0 | Unidad de medida |
| ZPRECIO_AB1510 | | ZPRECIO_AB1510 | DEC | 8 | 2 | Precio por unidad |

## Relaciones entre tablas

- **ZVBAK → ZVBAP:** una cabecera tiene varias posiciones, unidas por `ZVBELN_AB1510`.
- **Clave externa ZVBAP-MATNR → ZMARA_AB1510:** solo se pueden pedir materiales que existan en el maestro. Los dos campos comparten el elemento de datos `ZMATNR`.
- **Clave externa ZVBAK-ZWAERK_AB1510 → TCURC:** la moneda se valida contra la tabla estándar de monedas de SAP.

## Otros objetos

| Objeto | Tipo | Uso |
|---|---|---|
| `ZTT_ZVBAP_AB1510` | Tipo de tabla | Tabla de posiciones del atributo `POSICIONES` de la clase |
| `ZAB_MATNR_AB1510` | Ayuda de búsqueda | F4 del material, con su descripción |
| Vista de actualización de `ZMARA_AB1510` | SM30 | Mantenimiento del maestro de materiales |
| `ZPEDAB1510` | Rango numérico (SNRO) | Numeración automática de pedidos, intervalo 01: 1 a 9999999999 |

## Transacciones

| Transacción | Programa | Descripción |
|---|---|---|
| `ZGESTION_PED_AB1510` | `ZGESTION_PED_AB1510` | Gestión integral de pedidos |
| `ZLISTADO_PED_AB1510` | `ZLISTADO_PED_AB1510` | Listado ALV de pedidos |

## Dynpros del programa de gestión

| Dynpro | Tipo | Contenido |
|---|---|---|
| 9000 | Normal | Cabecera del pedido y ALV de posiciones (Custom Control `CC1`) |
| 9001 | Ventana modal | Alta de posición: material y cantidad |
| 9002 | Ventana modal | Baja de posición: número de posición |
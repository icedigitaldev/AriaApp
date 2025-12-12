# Plan de Corrección - Flujo de Órdenes

## Resumen de Problemas Corregidos

| #   | Tarea                                                        | Archivo                                           | Estado        |
| --- | ------------------------------------------------------------ | ------------------------------------------------- | ------------- |
| 1   | Agregar campo "responsable global" de la orden               | `order_summary_modal.dart`, `new_order_view.dart` | ✅ Completado |
| 2   | Corregir la alineación vertical de items en el modal         | `order_summary_modal.dart`                        | ✅ Completado |
| 3   | Eliminar redundancia de `customerName` en el modal           | `order_summary_modal.dart`                        | ✅ Completado |
| 4   | Corregir navegación: crear orden → ir a detalles, no a mesas | `new_order_view.dart`                             | ✅ Completado |
| 5   | Rediseñar `order_details_view.dart` - Total en bottom bar    | `order_details_view.dart`                         | ✅ Completado |
| 6   | Mover "Agregar Items" al header con ícono compacto           | `order_details_view.dart`                         | ✅ Completado |
| 7   | Quitar total del header (ya estará en bottom bar)            | `order_details_view.dart`                         | ✅ Completado |
| 8   | Hacer tarjetas de items más compactas                        | `order_details_view.dart`                         | ✅ Completado |
| 9   | Mostrar nombre del cliente de forma apropiada en cada item   | `order_details_view.dart`                         | ✅ Completado |

---

## Cambios Realizados

### 1. OrderSummaryModal (`order_summary_modal.dart`)

- Se agregó campo de texto para capturar el "Responsable del pago"
- Se modificó el callback `onConfirm` para recibir `String responsibleName`
- Se eliminó la duplicación del `customerName` en el subtítulo de precios
- Se corrigió la alineación vertical con `mainAxisAlignment: MainAxisAlignment.center`
- Se optimizaron los espaciados y tamaños de las tarjetas de items

### 2. NewOrderView (`new_order_view.dart`)

- Se modificó `_confirmOrder` para recibir `responsibleName`
- Se agregó el campo `responsibleName` en los datos de la orden que se guardan en Firebase
- Se cambió la navegación post-creación de `Navigator.pop` a `Navigator.pushReplacementNamed('/order-details')`

### 3. OrderDetailsView (`order_details_view.dart`)

- Se rediseñó completamente la vista
- Header compacto: muestra "Mesa X" + cantidad de items + mesero
- Botón de agregar items movido al header como ícono de carrito
- Se eliminó el FAB (FloatingActionButton)
- Tarjetas de items más compactas con diseño horizontal:
  - Cantidad a la izquierda en badge
  - Nombre + variante + cliente en una fila compacta
  - Precio subtotal a la derecha
- Bottom bar fijo con:
  - Total del pedido
  - Botón "Pagar" preparado para futuro flujo de pago

---

## Campos de la Orden en Firebase

```json
{
  "tableId": "...",
  "tableNumber": 5,
  "staffId": "...",
  "staffName": "Nombre del mesero",
  "responsibleName": "Nombre del responsable de pago", // NUEVO
  "items": [
    {
      "dishId": "...",
      "name": "Pollo a la Brasa",
      "price": 45.0,
      "quantity": 2,
      "variantName": "Medio Pollo",
      "customerName": "Juan" // Quién pidió este plato específico
    }
  ],
  "totalAmount": 90.0,
  "status": "pending",
  "businessId": "...",
  "createdAt": "...",
  "updatedAt": "..."
}
```

---

## Notas

- El campo `customerName` es por item individual (quién pidió ese plato)
- El campo `responsibleName` es global de la orden (quién va a pagar)
- La navegación ahora es: Mesas → Nueva Orden → Detalles de Orden → Mesas (sin ciclos)

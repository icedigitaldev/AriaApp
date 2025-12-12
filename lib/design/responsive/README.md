## ResponsiveScaler

Inicializar una sola vez en el main.dart:
```dart
MaterialApp(
  builder: (context, child) {
    ResponsiveScaler.init(context);
    return child!;
  },
);
```

Uso:
```dart
ResponsiveScaler.height(value)
ResponsiveScaler.width(value)
ResponsiveScaler.font(value)
ResponsiveScaler.radius(value)
ResponsiveScaler.icon(value)
ResponsiveScaler.padding(EdgeInsets)
ResponsiveScaler.margin(EdgeInsets)
```

No llamar `init()` en las vistas.
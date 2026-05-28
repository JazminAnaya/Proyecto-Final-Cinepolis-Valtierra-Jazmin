import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Welcome screen displays correctly', (WidgetTester tester) async {
    // Construir la app y generar un frame
    await tester.pumpWidget(const CinepolisApp());

    // Verificar que el título y elementos principales están presentes
    expect(find.text('Cinepolis'), findsOneWidget);
    expect(find.text('Valtierra'), findsOneWidget);
    expect(find.text('Iniciar Sesión como Administrador'), findsOneWidget);
    expect(find.text('Iniciar Sesión como Usuario'), findsOneWidget);
  });
}
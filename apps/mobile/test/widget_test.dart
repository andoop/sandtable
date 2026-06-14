import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandtable_mobile_review/data/models/document.dart';
import 'package:sandtable_mobile_review/ui/screens/document_screen.dart';

void main() {
  testWidgets('shows missing document state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DocumentScreen(
          document: SandtableDocument(name: 'plan', status: 'missing'),
        ),
      ),
    );
    expect(find.text('尚未生成'), findsOneWidget);
  });

  testWidgets('renders document content as markdown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DocumentScreen(
          document: SandtableDocument(
              name: 'prd', status: 'ok', content: 'Hello PRD'),
        ),
      ),
    );
    expect(find.textContaining('Hello PRD'), findsOneWidget);
  });
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates and reads a family document', () async {
    final firestore = FakeFirebaseFirestore();
    final dataSource = FirestoreDataSource(firestore);
    final now = DateTime(2026, 6, 27);

    final family = await dataSource.createFamily(
      FamilyDto(
        name: 'Smith Family',
        grandpaName: 'Grandpa',
        inviteCode: 'ABC123',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final loaded = await dataSource.getFamily(family.id);
    expect(loaded?.name, 'Smith Family');
    expect(loaded?.inviteCode, 'ABC123');
  });
}

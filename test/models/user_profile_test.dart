import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/models/app_models.dart';

void main() {
  test('reads the profile photo address from the row', () {
    final profile = UserProfile.fromJson({
      'id': 'u',
      'full_name': 'Maria',
      'email': 'm@example.com',
      'avatar_url': 'https://example.com/me.jpg',
    });

    expect(profile.avatarUrl, 'https://example.com/me.jpg');
  });

  test('a row without a photo has none', () {
    final profile = UserProfile.fromJson({'id': 'u', 'email': 'm@example.com'});

    expect(profile.avatarUrl, isNull);
  });

  test('the photo address survives a round trip through JSON', () {
    final original = UserProfile(
      id: 'u',
      fullName: 'Maria',
      email: 'm@example.com',
      avatarUrl: 'https://example.com/me.jpg',
    );

    expect(
      UserProfile.fromJson(original.toJson()).avatarUrl,
      original.avatarUrl,
    );
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const root = 'design/prototypes';
  const immersivePages = <String>{
    '02-onboarding',
    '03-auth',
    '05-home',
    '06-scan',
    '13-pro',
  };
  const densePages = <String>{
    '01-shell',
    '04-profile-setup',
    '07-crops',
    '08-calendar',
    '09-care-plan',
    '10-advisories',
    '11-health-log',
    '12-shop',
    '14-profile',
  };

  test('glass is opt-in, not a blanket card/nav override', () {
    final css = File('$root/shared/tokens.css').readAsStringSync();

    expect(css, contains('.glass-dark'));
    expect(
      css,
      isNot(contains('.appbar, .bottom-nav, .top, .card, .frame, .phone')),
    );
    expect(css, isNot(contains('.card, .bottom-nav {')));
    expect(
      css,
      isNot(contains('backdrop-filter: blur(var(--glass-sigma)) !important')),
    );
  });

  test(
    'immersive pages use a glass-dark text plate at most once per variant',
    () {
      for (final page in immersivePages) {
        final html = File('$root/$page/index.html').readAsStringSync();
        expect(
          html,
          contains('glass-dark'),
          reason: '$page must opt into glass',
        );

        final sections = html.split('<section class="variant"').skip(1);
        for (final section in sections) {
          expect(
            RegExp('glass-dark').allMatches(section).length,
            lessThanOrEqualTo(1),
            reason: '$page variant exceeds the one-blur budget',
          );
        }
      }
    },
  );

  test('dense utility pages stay opaque', () {
    for (final page in densePages) {
      final html = File('$root/$page/index.html').readAsStringSync();
      expect(
        html,
        isNot(contains('glass-dark')),
        reason: '$page is dense/utility',
      );
      expect(
        html,
        isNot(contains('class="glass')),
        reason: '$page is dense/utility',
      );
    }
  });

  test('every brief records a glass re-judgment', () {
    for (final page in [...immersivePages, ...densePages]) {
      final brief = File('$root/$page/brief.md').readAsStringSync();
      expect(
        brief,
        contains('Glass re-judgment'),
        reason: '$page verdict was not re-judged',
      );
    }
  });
}

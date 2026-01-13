import 'package:flutter_test/flutter_test.dart';
import 'package:bizd_tech_service/core/config/environment.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('Default environment should be dev', () {
      // Reset to default
      AppConfig.setEnvironment(Environment.dev);
      expect(AppConfig.environment, equals(Environment.dev));
    });

    test('Can set environment to staging', () {
      AppConfig.setEnvironment(Environment.staging);
      expect(AppConfig.environment, equals(Environment.staging));
    });

    test('Can set environment to prod', () {
      AppConfig.setEnvironment(Environment.prod);
      expect(AppConfig.environment, equals(Environment.prod));
    });

    test('Dev environment has correct default host', () {
      AppConfig.setEnvironment(Environment.dev);
      expect(AppConfig.defaultHost, equals('svr10.biz-dimension.com'));
    });

    test('Staging environment has correct default host', () {
      AppConfig.setEnvironment(Environment.staging);
      expect(AppConfig.defaultHost, equals('staging.biz-dimension.com'));
    });

    test('Prod environment has correct default host', () {
      AppConfig.setEnvironment(Environment.prod);
      expect(AppConfig.defaultHost, equals('svr10.biz-dimension.com'));
    });

    test('Default port should be 9093', () {
      expect(AppConfig.defaultPort, equals('9093'));
    });

    test('SSL should only be disabled in dev', () {
      AppConfig.setEnvironment(Environment.dev);
      expect(AppConfig.shouldDisableSSL, isTrue);

      AppConfig.setEnvironment(Environment.staging);
      expect(AppConfig.shouldDisableSSL, isFalse);

      AppConfig.setEnvironment(Environment.prod);
      expect(AppConfig.shouldDisableSSL, isFalse);
    });

    test('Auth endpoint should be correct', () {
      expect(AppConfig.authEndpoint, equals('/api/auth'));
    });

    test('SAP endpoint should be correct', () {
      expect(AppConfig.sapEndpoint, equals('/api/sapIntegration'));
    });

    test('Attachments endpoint should be correct', () {
      expect(AppConfig.attachmentsEndpoint, equals('/api/sapIntegration/Attachments2'));
    });

    test('Notifications endpoint should be correct', () {
      expect(AppConfig.notificationsEndpoint, equals('/api/notifications/sendToWeb'));
    });

    test('Base URL should update based on environment', () {
      AppConfig.setEnvironment(Environment.dev);
      expect(AppConfig.baseUrl, contains('svr10.biz-dimension.com'));

      AppConfig.setEnvironment(Environment.staging);
      expect(AppConfig.baseUrl, contains('staging.biz-dimension.com'));
    });
  });
}

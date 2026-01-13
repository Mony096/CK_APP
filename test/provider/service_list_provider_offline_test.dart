import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:bizd_tech_service/provider/service_list_provider_offline.dart';

void main() {
  group('ServiceListProviderOffline Tests', () {
    late ServiceListProviderOffline provider;
    late Directory tempDir;

    setUpAll(() async {
      // Use a temporary directory for Hive instead of the app documents directory
      tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
    });

    setUp(() {
      provider = ServiceListProviderOffline();
    });

    tearDown(() async {
      // Clean up Hive boxes after each test
      if (Hive.isBoxOpen('service_lists')) {
        await Hive.box('service_lists').clear();
      }
      if (Hive.isBoxOpen('offlineCompleted')) {
        await Hive.box('offlineCompleted').clear();
      }
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Initial state should have empty documents', () {
      expect(provider.documents, isEmpty);
    });

    test('Initial state should have empty completedServices', () {
      expect(provider.completedServices, isEmpty);
    });

    test('Initial isLoading should be false', () {
      expect(provider.isLoading, isFalse);
    });

    test('Initial currentDate should be null', () {
      expect(provider.currentDate, isNull);
    });

    test('setDate should update currentDate', () {
      final testDate = DateTime(2024, 1, 15);
      provider.setDate(testDate);
      expect(provider.currentDate, equals(testDate));
    });

    test('clearCurrentDate should set currentDate to null', () {
      provider.setDate(DateTime.now());
      expect(provider.currentDate, isNotNull);
      
      provider.clearCurrentDate();
      expect(provider.currentDate, isNull);
    });

    test('saveDocuments should store documents', () async {
      final testDocs = [
        {'DocEntry': 1, 'U_CK_Status': 'Open'},
        {'DocEntry': 2, 'U_CK_Status': 'Service'},
      ];

      await provider.saveDocuments(testDocs);
      
      expect(provider.documents.length, equals(2));
    });

    test('clearDocuments should remove all documents', () async {
      final testDocs = [
        {'DocEntry': 1, 'U_CK_Status': 'Open'},
      ];

      await provider.saveDocuments(testDocs);
      expect(provider.documents.isNotEmpty, isTrue);

      await provider.clearDocuments();
      expect(provider.documents, isEmpty);
    });

    test('addCompletedService should add service with pending status', () async {
      final payload = {
        'DocEntry': 123,
        'U_CK_Status': 'Entry',
      };

      await provider.addCompletedService(payload);
      
      expect(provider.completedServices.length, equals(1));
      expect(provider.completedServices[0]['sync_status'], equals('pending'));
    });

    test('getCompletedServicesToSync should return pending services', () async {
      await provider.addCompletedService({'DocEntry': 1});
      await provider.addCompletedService({'DocEntry': 2});

      final pendingServices = await provider.getCompletedServicesToSync();
      
      expect(pendingServices.length, equals(2));
      expect(pendingServices.every((s) => s['sync_status'] == 'pending'), isTrue);
    });

    test('markServiceSynced should remove the service', () async {
      await provider.addCompletedService({'DocEntry': 100});
      expect(provider.completedServices.length, equals(1));

      await provider.markServiceSynced(100);
      
      // After marking as synced, it should be removed
      final remaining = await provider.getCompletedServicesToSync();
      expect(remaining.where((s) => s['DocEntry'] == 100), isEmpty);
    });

    test('saveDocuments and loadDocuments should work together', () async {
      final testDocs = [
        {'DocEntry': 1, 'U_CK_Status': 'Open', 'U_CK_Date': '2024-01-15T10:00:00'},
        {'DocEntry': 2, 'U_CK_Status': 'Service', 'U_CK_Date': '2024-01-15T11:00:00'},
      ];

      await provider.saveDocuments(testDocs);
      await provider.loadDocuments();
      
      expect(provider.documents.length, equals(2));
    });

    test('Date filter should work correctly', () async {
      final testDocs = [
        {'DocEntry': 1, 'U_CK_Status': 'Open', 'U_CK_Date': '2024-01-15T10:00:00'},
        {'DocEntry': 2, 'U_CK_Status': 'Service', 'U_CK_Date': '2024-01-16T11:00:00'},
        {'DocEntry': 3, 'U_CK_Status': 'Entry', 'U_CK_Date': '2024-01-15T14:00:00'},
      ];

      await provider.saveDocuments(testDocs);
      
      // Set date filter
      provider.setDate(DateTime(2024, 1, 15));
      await provider.loadDocuments();
      
      // Should only return 2 docs from Jan 15
      expect(provider.documents.length, equals(2));
      expect(provider.documents.every((d) => 
        d['U_CK_Date'].toString().contains('2024-01-15')), isTrue);
    });
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HttpCertificatePinning', () {
    const MethodChannel channel = MethodChannel('http_certificate_pinning');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'check') {
          return 'SUCCESS';
        }
        return null;
      });
      log.clear();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    test('check method invokes with correct arguments', () async {
      const String testUrl = 'https://example.com';
      const SHA testSha = SHA.SHA256;
      const List<String> testFingerprints = ['AA:BB:CC:DD:EE:FF', '11:22:33:44:55:66'];
      final Map<String, String> testHeaders = {'Authorization': 'Bearer token'};
      const int testTimeout = 10000;

      await HttpCertificatePinning.check(
        serverURL: testUrl,
        sha: testSha,
        allowedSHAFingerprints: testFingerprints,
        headerHttp: testHeaders,
        timeout: testTimeout,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'check');
      expect(log.first.arguments, <String, dynamic>{
        'url': testUrl,
        'headers': testHeaders,
        'type': 'SHA256',
        'fingerprints': ['AABBCCDDEEFF', '112233445566'],
        'timeout': testTimeout,
      });
    });

    test('check method handles null headers and timeout gracefully', () async {
      const String testUrl = 'https://example.com';
      const List<String> testFingerprints = ['AA:BB:CC:DD:EE:FF'];

      await HttpCertificatePinning.check(
        serverURL: testUrl,
        sha: SHA.SHA1,
        allowedSHAFingerprints: testFingerprints,
        headerHttp: null,
        timeout: null,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'check');
      expect(log.first.arguments, <String, dynamic>{
        'url': testUrl,
        'headers': {},
        'type': 'SHA1',
        'fingerprints': ['AABBCCDDEEFF'],
        'timeout': null,
      });
    });

    test('check method returns expected string on success', () async {
      const String testUrl = 'https://example.com';
      const List<String> testFingerprints = ['AA:BB:CC:DD:EE:FF'];

      final String result = await HttpCertificatePinning.check(
        serverURL: testUrl,
        sha: SHA.SHA256,
        allowedSHAFingerprints: testFingerprints,
      );

      expect(result, 'SUCCESS');
    });

    test('check method handles empty fingerprints list', () async {
      const String testUrl = 'https://example.com';
      const SHA testSha = SHA.SHA256;
      const List<String> testFingerprints = [];

      await HttpCertificatePinning.check(
        serverURL: testUrl,
        sha: testSha,
        allowedSHAFingerprints: testFingerprints,
      );

      expect(log, hasLength(1));
      expect(log.first.arguments['fingerprints'], []);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/domain/device/device_product.dart';
import 'package:koralcore/domain/device/device_product_resolver.dart';

void main() {
  group('DeviceProductResolver', () {
    const resolver = DeviceProductResolver();

    test('resolves Koral Dose 4H to doser4k', () {
      expect(resolver.resolve('Koral Dose 4H'), DeviceProduct.doser4k);
      expect(resolver.resolve('koral dose 4h'), DeviceProduct.doser4k);
      expect(resolver.resolve('  Koral Dose 4H  '), DeviceProduct.doser4k);
    });

    test('resolves Koral Dose 4R to doser', () {
      expect(resolver.resolve('Koral Dose 4R'), DeviceProduct.doser);
      expect(resolver.resolve('koral dose 4r'), DeviceProduct.doser);
    });

    test('resolves LED devices to ledController', () {
      expect(resolver.resolve('Koral LED Controller'), DeviceProduct.ledController);
      expect(resolver.resolve('My LED Light'), DeviceProduct.ledController);
    });

    test('resolves unknown strings to unknown', () {
      expect(resolver.resolve('Random Device'), DeviceProduct.unknown);
      expect(resolver.resolve('Dose 4X'), DeviceProduct.unknown); // Not 4H or 4R
      expect(resolver.resolve(''), DeviceProduct.unknown);
    });

    test('resolves null to unknown', () {
      expect(resolver.resolve(null), DeviceProduct.unknown);
    });

    test('prioritizes exact matches for 4H/4R logic', () {
      // Logic: contains dose & 4h & !4r
      expect(resolver.resolve('Dose 4H 4R'), DeviceProduct.unknown); // Contains both
    });
  });
}

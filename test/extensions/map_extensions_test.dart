import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('MapKnife', () {
    group('pick', () {
      test('should pick only specified keys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.pick(['a', 'c']), equals({'a': 1, 'c': 3}));
      });
      test('should ignore missing keys', () {
        final map = {'a': 1, 'b': 2};
        expect(map.pick(['a', 'z']), equals({'a': 1}));
      });
    });

    group('omit', () {
      test('should omit specified keys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.omit(['a', 'c']), equals({'b': 2}));
      });
    });

    group('invert', () {
      test('should swap keys and values', () {
        final map = {'a': '1', 'b': '2'};
        expect(map.invert(), equals({'1': 'a', '2': 'b'}));
      });
    });

    group('filterKeys & filterValues', () {
      test('filterKeys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.filterKeys((k) => k != 'b'), equals({'a': 1, 'c': 3}));
      });
      test('filterValues', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.filterValues((v) => v > 1), equals({'b': 2, 'c': 3}));
      });
    });

    group('mapKeys & mapValuesWithKey', () {
      test('mapKeys', () {
        final map = {'a': 1, 'b': 2};
        expect(
          map.mapKeys((k, v) => k.toUpperCase()),
          equals({'A': 1, 'B': 2}),
        );
      });
      test('mapValuesWithKey', () {
        final map = {'a': 1, 'b': 2};
        expect(
          map.mapValuesWithKey((k, v) => v * 10),
          equals({'a': 10, 'b': 20}),
        );
      });
    });
  });

  group('StringMapKnife', () {
    group('deepMerge', () {
      test('should recursively merge maps', () {
        final m1 = {
          'a': {'b': 1},
          'c': 2,
        };
        final m2 = {
          'a': {'d': 3},
          'e': 4,
        };
        final merged = m1.deepMerge(m2);
        expect(
          merged,
          equals({
            'a': {'b': 1, 'd': 3},
            'c': 2,
            'e': 4,
          }),
        );
      });
    });

    group('flattenKeys & unflattenKeys', () {
      test('should flatten nested maps', () {
        final nested = {
          'user': {
            'profile': {'name': 'John'},
            'age': 30,
          },
        };
        final flattened = nested.flattenKeys();
        expect(
          flattened,
          equals({'user.profile.name': 'John', 'user.age': 30}),
        );
      });

      test('should unflatten keys back to nested structure', () {
        final flat = {'user.profile.name': 'John', 'user.age': 30};
        final unflattened = flat.unflattenKeys();
        expect(
          unflattened,
          equals({
            'user': {
              'profile': {'name': 'John'},
              'age': 30,
            },
          }),
        );
      });
    });

    group('getNestedValue & setNestedValue', () {
      test('getNestedValue', () {
        final map = {
          'user': {
            'profile': {'name': 'John'},
          },
        };
        expect(map.getNestedValue('user.profile.name'), equals('John'));
        expect(map.getNestedValue('user.age'), isNull);
      });

      test('setNestedValue', () {
        final map = <String, dynamic>{};
        final updated = map.setNestedValue('user.profile.name', 'John');
        expect(
          updated,
          equals({
            'user': {
              'profile': {'name': 'John'},
            },
          }),
        );
      });
    });

    group('toQueryString & queryStringToMap', () {
      test('toQueryString', () {
        final map = {'name': 'John Doe', 'age': '30'};
        expect(map.toQueryString(), equals('name=John+Doe&age=30'));
      });

      test('queryStringToMap', () {
        final query = 'name=John%20Doe&age=30';
        expect(
          queryStringToMap(query),
          equals({'name': 'John Doe', 'age': '30'}),
        );
      });
    });

    group('whereNotNull', () {
      test('should filter out null values', () {
        final map = {'a': 1, 'b': null, 'c': 'test'};
        expect(map.whereNotNull(), equals({'a': 1, 'c': 'test'}));
      });
    });
  });

  group('MapNullableValueKnife', () {
    test('compact', () {
      final map = {'a': 1, 'b': null};
      final Map<String, int> compacted = map.compact();
      expect(compacted, equals({'a': 1}));
    });
  });
}

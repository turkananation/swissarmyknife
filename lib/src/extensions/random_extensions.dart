/// Advanced random selection, ranges, and probability extensions on [Random].
///
/// Contains weighted choices, integer/double range bounds, weighted booleans,
/// and collection sampling helpers.
library;

import 'dart:math' as math;

/// Extensions on [math.Random] to provide advanced random value generation.
///
/// Example:
/// ```dart
/// final random = Random();
/// final item = random.nextElement(['apple', 'banana', 'orange']);
/// ```
extension RandomKnife on math.Random {
  /// Selects a random element from the specified [list].
  ///
  /// Throws [ArgumentError] if the collection is empty.
  ///
  /// Example:
  /// ```dart
  /// print(Random().nextElement([10, 20, 30])); // e.g. 20
  /// ```
  T nextElement<T>(Iterable<T> list) {
    if (list.isEmpty) {
      throw ArgumentError('Collection cannot be empty.');
    }
    final index = nextInt(list.length);
    return list.elementAt(index);
  }

  /// Selects a random element from [elements] according to their relative [weights].
  ///
  /// [elements] and [weights] must have the same length. Throws [ArgumentError]
  /// if they do not match, if empty, or if the sum of weights is non-positive.
  ///
  /// Example:
  /// ```dart
  /// final items = ['A', 'B'];
  /// final weights = [0.8, 0.2]; // 80% chance of A, 20% B
  /// print(Random().nextWeightedElement(items, weights)); // A or B
  /// ```
  T nextWeightedElement<T>(List<T> elements, List<double> weights) {
    if (elements.length != weights.length) {
      throw ArgumentError('Elements and weights must have the same length.');
    }
    if (elements.isEmpty) {
      throw ArgumentError('Collection cannot be empty.');
    }

    final sumOfWeights = weights.reduce((a, b) => a + b);
    if (sumOfWeights <= 0.0) {
      throw ArgumentError('Sum of weights must be greater than zero.');
    }

    final r = nextDouble() * sumOfWeights;
    var accumulated = 0.0;
    for (var i = 0; i < elements.length; i++) {
      accumulated += weights[i];
      if (r <= accumulated) {
        return elements[i];
      }
    }
    return elements.last;
  }

  /// Generates a random integer in the range [min] and [max] (inclusive).
  ///
  /// Throws [ArgumentError] if [min] > [max].
  ///
  /// Example:
  /// ```dart
  /// print(Random().nextIntInRange(5, 10)); // e.g. 7
  /// ```
  int nextIntInRange(int min, int max) {
    if (min > max) {
      throw ArgumentError('min ($min) cannot be greater than max ($max).');
    }
    final range = max - min + 1;
    return min + nextInt(range);
  }

  /// Generates a random double in the range [min] and [max].
  ///
  /// Throws [ArgumentError] if [min] > [max].
  ///
  /// Example:
  /// ```dart
  /// print(Random().nextDoubleInRange(1.5, 3.5)); // e.g. 2.14...
  /// ```
  double nextDoubleInRange(double min, double max) {
    if (min > max) {
      throw ArgumentError('min ($min) cannot be greater than max ($max).');
    }
    final range = max - min;
    return min + (nextDouble() * range);
  }

  /// Generates a boolean value that returns `true` with the specified [probability].
  ///
  /// [probability] must be between `0.0` and `1.0` inclusive.
  ///
  /// Example:
  /// ```dart
  /// // 75% chance of returning true
  /// final success = Random().nextBoolWithProbability(0.75);
  /// ```
  bool nextBoolWithProbability(double probability) {
    if (probability < 0.0 || probability > 1.0) {
      throw ArgumentError(
        'Probability ($probability) must be between 0.0 and 1.0.',
      );
    }
    return nextDouble() < probability;
  }
}

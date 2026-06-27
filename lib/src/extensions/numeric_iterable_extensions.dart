/// Advanced mathematical and statistical extensions on numeric iterables.
///
/// Contains sum, average, median, mode, variance, standard deviation,
/// percentiles, and min/max shorthand utilities.
library;

import 'dart:math' as math;

/// Extensions on [Iterable] of numeric types to provide statistical aggregates.
///
/// Example:
/// ```dart
/// final scores = [80, 90, 100];
/// print(scores.average()); // 90.0
/// ```
extension NumericIterableKnife on Iterable<num> {
  /// Computes the sum of all elements in the collection.
  ///
  /// Returns `0` if empty.
  ///
  /// Example:
  /// ```dart
  /// print([1, 2, 3].sum()); // 6
  /// ```
  num sum() {
    num total = 0;
    for (final element in this) {
      total += element;
    }
    return total;
  }

  /// Computes the average of all elements in the collection.
  ///
  /// Returns `0.0` if empty.
  ///
  /// Example:
  /// ```dart
  /// print([1, 2, 3, 4].average()); // 2.5
  /// ```
  double average() {
    if (isEmpty) return 0.0;
    return sum() / length;
  }

  /// Finds the median value of this collection.
  ///
  /// Returns `0.0` if empty. For even length collections, returns
  /// the average of the two middle values.
  ///
  /// Example:
  /// ```dart
  /// print([1, 3, 2].median()); // 2.0
  /// print([1, 2, 3, 4].median()); // 2.5
  /// ```
  double median() {
    if (isEmpty) return 0.0;
    final sorted = toList()..sort();
    final len = sorted.length;
    final mid = len ~/ 2;
    if (len.isOdd) {
      return sorted[mid].toDouble();
    } else {
      return (sorted[mid - 1] + sorted[mid]) / 2.0;
    }
  }

  /// Finds the mode (most frequent value or values) of this collection.
  ///
  /// Returns an empty list if empty. Can return multiple modes for multimodal distributions.
  ///
  /// Example:
  /// ```dart
  /// print([1, 2, 2, 3].mode()); // [2]
  /// print([1, 1, 2, 2].mode()); // [1, 2]
  /// ```
  List<num> mode() {
    if (isEmpty) return const [];
    final freq = <num, int>{};
    var maxCount = 0;
    for (final val in this) {
      final count = (freq[val] ?? 0) + 1;
      freq[val] = count;
      if (count > maxCount) {
        maxCount = count;
      }
    }
    final modes = <num>[];
    for (final entry in freq.entries) {
      if (entry.value == maxCount) {
        modes.add(entry.key);
      }
    }
    return modes;
  }

  /// Computes the population variance of the collection.
  ///
  /// Returns `0.0` if empty.
  ///
  /// Example:
  /// ```dart
  /// print([2, 4, 4, 4, 5, 5, 7, 9].variance()); // 4.0
  /// ```
  double variance() {
    if (isEmpty) return 0.0;
    final avg = average();
    double totalDiff = 0.0;
    for (final val in this) {
      final diff = val - avg;
      totalDiff += diff * diff;
    }
    return totalDiff / length;
  }

  /// Computes the population standard deviation of the collection.
  ///
  /// Returns `0.0` if empty.
  ///
  /// Example:
  /// ```dart
  /// print([2, 4, 4, 4, 5, 5, 7, 9].standardDeviation()); // 2.0
  /// ```
  double standardDeviation() {
    return math.sqrt(variance());
  }

  /// Computes the p-th percentile of this collection, where [p] is between `0.0` and `1.0` inclusive.
  ///
  /// Uses linear interpolation between values. Throws [ArgumentError] if [p] is out of range.
  ///
  /// Example:
  /// ```dart
  /// final list = [15, 20, 35, 40, 50];
  /// print(list.percentile(0.4)); // 29.0
  /// ```
  double percentile(double p) {
    if (p < 0.0 || p > 1.0) {
      throw ArgumentError(
        'Percentile p ($p) must be between 0.0 and 1.0 inclusive.',
      );
    }
    if (isEmpty) return 0.0;
    final sorted = toList()..sort();
    if (sorted.length == 1) return sorted.first.toDouble();
    final index = p * (sorted.length - 1);
    final lower = index.floor();
    final upper = index.ceil();
    final weight = index - lower;
    return sorted[lower] + weight * (sorted[upper] - sorted[lower]);
  }

  /// Returns the absolute minimum value in this collection.
  ///
  /// Throws [StateError] if the collection is empty.
  num min() {
    if (isEmpty) {
      throw StateError('No elements in collection.');
    }
    num currentMin = first;
    for (final val in this) {
      if (val < currentMin) {
        currentMin = val;
      }
    }
    return currentMin;
  }

  /// Returns the absolute maximum value in this collection.
  ///
  /// Throws [StateError] if the collection is empty.
  num max() {
    if (isEmpty) {
      throw StateError('No elements in collection.');
    }
    num currentMax = first;
    for (final val in this) {
      if (val > currentMax) {
        currentMax = val;
      }
    }
    return currentMax;
  }
}

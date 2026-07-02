/// Tree and graph helpers for lightweight in-memory data structures.
///
/// Use [TreeNode] for immutable tree-shaped values and [Graph] for mutable
/// adjacency-map graphs with traversal, paths, and cycle checks.
library;

import 'dart:collection';

/// Traversal order for tree values.
enum TreeTraversalOrder {
  /// Visit a node before its children.
  preOrder,

  /// Visit children before their parent node.
  postOrder,

  /// Visit nodes level by level from the root.
  breadthFirst,
}

/// Immutable tree node.
///
/// Children are copied into an unmodifiable list so callers can safely reuse
/// input collections without later mutations changing the tree.
final class TreeNode<T> {
  /// Creates a tree node with [value] and optional [children].
  TreeNode(this.value, [Iterable<TreeNode<T>> children = const []])
    : children = List<TreeNode<T>>.unmodifiable(children);

  /// Creates a tree node with no children.
  TreeNode.leaf(this.value) : children = const [];

  /// Value stored at this node.
  final T value;

  /// Child nodes.
  final List<TreeNode<T>> children;

  /// Whether this node has no children.
  bool get isLeaf => children.isEmpty;

  /// Number of nodes in this subtree, including this node.
  int get size => 1 + children.fold<int>(0, (sum, child) => sum + child.size);

  /// Maximum number of edges from this node to a leaf.
  int get height {
    if (children.isEmpty) return 0;
    return 1 + children.map((child) => child.height).reduce(_maxInt);
  }

  /// Pre-order node traversal.
  Iterable<TreeNode<T>> preOrder() sync* {
    yield this;
    for (final child in children) {
      yield* child.preOrder();
    }
  }

  /// Post-order node traversal.
  Iterable<TreeNode<T>> postOrder() sync* {
    for (final child in children) {
      yield* child.postOrder();
    }
    yield this;
  }

  /// Breadth-first node traversal.
  Iterable<TreeNode<T>> breadthFirst() sync* {
    final queue = ListQueue<TreeNode<T>>()..add(this);
    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      yield node;
      queue.addAll(node.children);
    }
  }

  /// Values in the requested traversal [order].
  Iterable<T> values({TreeTraversalOrder order = TreeTraversalOrder.preOrder}) {
    return switch (order) {
      TreeTraversalOrder.preOrder => preOrder().map((node) => node.value),
      TreeTraversalOrder.postOrder => postOrder().map((node) => node.value),
      TreeTraversalOrder.breadthFirst => breadthFirst().map(
        (node) => node.value,
      ),
    };
  }

  /// First node whose value matches [test], using pre-order traversal.
  TreeNode<T>? find(bool Function(T value) test) {
    for (final node in preOrder()) {
      if (test(node.value)) return node;
    }
    return null;
  }

  /// Whether any node value matches [test].
  bool any(bool Function(T value) test) => find(test) != null;

  /// Nodes whose values match [test], using pre-order traversal.
  Iterable<TreeNode<T>> where(bool Function(T value) test) sync* {
    for (final node in preOrder()) {
      if (test(node.value)) yield node;
    }
  }

  /// Maps every node value while preserving tree shape.
  TreeNode<R> map<R>(R Function(T value) convert) {
    return TreeNode<R>(
      convert(value),
      children.map((child) => child.map(convert)),
    );
  }

  @override
  String toString() => 'TreeNode($value, children: ${children.length})';
}

/// Directed edge between two graph vertices.
final class GraphEdge<T> {
  /// Creates an edge from [from] to [to].
  const GraphEdge(this.from, this.to);

  /// Source vertex.
  final T from;

  /// Target vertex.
  final T to;

  @override
  bool operator ==(Object other) {
    return other is GraphEdge<T> && other.from == from && other.to == to;
  }

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'GraphEdge($from -> $to)';
}

/// Mutable graph backed by insertion-ordered adjacency sets.
final class Graph<T> {
  /// Creates an empty graph.
  Graph({this.isDirected = true, Map<T, Iterable<T>>? adjacency}) {
    if (adjacency != null) {
      for (final entry in adjacency.entries) {
        addVertex(entry.key);
        for (final neighbor in entry.value) {
          addEdge(entry.key, neighbor);
        }
      }
    }
  }

  /// Creates a directed graph.
  Graph.directed({Map<T, Iterable<T>>? adjacency})
    : this(isDirected: true, adjacency: adjacency);

  /// Creates an undirected graph.
  Graph.undirected({Map<T, Iterable<T>>? adjacency})
    : this(isDirected: false, adjacency: adjacency);

  /// Creates a graph from [edges].
  Graph.fromEdges(Iterable<GraphEdge<T>> edges, {this.isDirected = true}) {
    for (final edge in edges) {
      addEdge(edge.from, edge.to);
    }
  }

  final Map<T, Set<T>> _adjacency = <T, Set<T>>{};

  /// Whether edges are directed.
  final bool isDirected;

  /// All vertices in insertion order.
  Iterable<T> get vertices => _adjacency.keys;

  /// Number of vertices.
  int get vertexCount => _adjacency.length;

  /// Number of edges.
  int get edgeCount => edges.length;

  /// All graph edges.
  List<GraphEdge<T>> get edges {
    if (isDirected) {
      return [
        for (final entry in _adjacency.entries)
          for (final neighbor in entry.value) GraphEdge<T>(entry.key, neighbor),
      ];
    }

    final seen = <_UndirectedPair<T>>{};
    final result = <GraphEdge<T>>[];
    for (final entry in _adjacency.entries) {
      for (final neighbor in entry.value) {
        final pair = _UndirectedPair<T>(entry.key, neighbor);
        if (seen.add(pair)) {
          result.add(GraphEdge<T>(entry.key, neighbor));
        }
      }
    }
    return List<GraphEdge<T>>.unmodifiable(result);
  }

  /// Snapshot of the adjacency map.
  Map<T, Set<T>> get adjacency {
    final snapshot = <T, Set<T>>{};
    for (final entry in _adjacency.entries) {
      snapshot[entry.key] = Set<T>.unmodifiable(entry.value);
    }
    return Map<T, Set<T>>.unmodifiable(snapshot);
  }

  /// Whether [vertex] exists in the graph.
  bool containsVertex(T vertex) => _adjacency.containsKey(vertex);

  /// Adds [vertex] if it is not already present.
  void addVertex(T vertex) {
    _adjacency.putIfAbsent(vertex, () => <T>{});
  }

  /// Adds an edge from [from] to [to].
  ///
  /// Undirected graphs add the reciprocal edge automatically.
  void addEdge(T from, T to) {
    addVertex(from);
    addVertex(to);
    _adjacency[from]!.add(to);
    if (!isDirected) {
      _adjacency[to]!.add(from);
    }
  }

  /// Removes [vertex] and every edge pointing to it.
  bool removeVertex(T vertex) {
    final removed = _adjacency.remove(vertex) != null;
    if (!removed) return false;

    for (final neighbors in _adjacency.values) {
      neighbors.remove(vertex);
    }
    return true;
  }

  /// Removes the edge from [from] to [to].
  ///
  /// Undirected graphs also remove the reciprocal edge.
  bool removeEdge(T from, T to) {
    final removed = _adjacency[from]?.remove(to) ?? false;
    if (!isDirected) {
      _adjacency[to]?.remove(from);
    }
    return removed;
  }

  /// Neighbors of [vertex] in insertion order.
  Set<T> neighborsOf(T vertex) {
    return Set<T>.unmodifiable(_adjacency[vertex] ?? <T>{});
  }

  /// Breadth-first traversal from [start].
  Iterable<T> breadthFirst(T start) sync* {
    if (!containsVertex(start)) return;

    final visited = <T>{start};
    final queue = ListQueue<T>()..add(start);

    while (queue.isNotEmpty) {
      final vertex = queue.removeFirst();
      yield vertex;

      for (final neighbor in _adjacency[vertex]!) {
        if (visited.add(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
  }

  /// Depth-first traversal from [start].
  Iterable<T> depthFirst(T start) sync* {
    if (!containsVertex(start)) return;

    final visited = <T>{};
    final stack = <T>[start];

    while (stack.isNotEmpty) {
      final vertex = stack.removeLast();
      if (!visited.add(vertex)) continue;
      yield vertex;

      final neighbors = _adjacency[vertex]!.toList().reversed;
      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          stack.add(neighbor);
        }
      }
    }
  }

  /// Shortest unweighted path from [start] to [goal], or `null`.
  List<T>? shortestPath(T start, T goal) {
    if (!containsVertex(start) || !containsVertex(goal)) return null;
    if (start == goal) return [start];

    final visited = <T>{start};
    final previous = <T, T>{};
    final queue = ListQueue<T>()..add(start);

    while (queue.isNotEmpty) {
      final vertex = queue.removeFirst();
      for (final neighbor in _adjacency[vertex]!) {
        if (!visited.add(neighbor)) continue;
        previous[neighbor] = vertex;
        if (neighbor == goal) {
          return _reconstructPath(start, goal, previous);
        }
        queue.add(neighbor);
      }
    }

    return null;
  }

  /// Whether a path exists from [start] to [goal].
  bool hasPath(T start, T goal) => shortestPath(start, goal) != null;

  /// Whether the graph contains at least one cycle.
  bool get hasCycle => isDirected ? _hasDirectedCycle() : _hasUndirectedCycle();

  List<T> _reconstructPath(T start, T goal, Map<T, T> previous) {
    final path = <T>[goal];
    var current = goal;

    while (current != start) {
      current = previous[current] as T;
      path.add(current);
    }

    return path.reversed.toList(growable: false);
  }

  bool _hasDirectedCycle() {
    final visiting = <T>{};
    final visited = <T>{};

    bool visit(T vertex) {
      if (visiting.contains(vertex)) return true;
      if (visited.contains(vertex)) return false;

      visiting.add(vertex);
      for (final neighbor in _adjacency[vertex]!) {
        if (visit(neighbor)) return true;
      }
      visiting.remove(vertex);
      visited.add(vertex);
      return false;
    }

    for (final vertex in _adjacency.keys) {
      if (visit(vertex)) return true;
    }
    return false;
  }

  bool _hasUndirectedCycle() {
    final visited = <T>{};

    bool visit(T vertex, T? parent) {
      visited.add(vertex);
      for (final neighbor in _adjacency[vertex]!) {
        if (!visited.contains(neighbor)) {
          if (visit(neighbor, vertex)) return true;
        } else if (neighbor != parent) {
          return true;
        }
      }
      return false;
    }

    for (final vertex in _adjacency.keys) {
      if (!visited.contains(vertex) && visit(vertex, null)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    final kind = isDirected ? 'directed' : 'undirected';
    return 'Graph($kind, vertices: $vertexCount, edges: $edgeCount)';
  }
}

final class _UndirectedPair<T> {
  const _UndirectedPair(this.a, this.b);

  final T a;
  final T b;

  @override
  bool operator ==(Object other) {
    return other is _UndirectedPair<T> &&
        ((other.a == a && other.b == b) || (other.a == b && other.b == a));
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode;
}

int _maxInt(int left, int right) => left > right ? left : right;

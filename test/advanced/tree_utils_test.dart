import 'package:swissarmyknife/swissarmyknife.dart';
import 'package:test/test.dart';

void main() {
  group('TreeNode', () {
    TreeNode<String> sampleTree() {
      return TreeNode('root', [
        TreeNode('left', [TreeNode.leaf('left.left')]),
        TreeNode('right', [
          TreeNode.leaf('right.left'),
          TreeNode.leaf('right.right'),
        ]),
      ]);
    }

    test('should expose size, height, and leaf state', () {
      final tree = sampleTree();

      expect(tree.isLeaf, isFalse);
      expect(tree.size, equals(6));
      expect(tree.height, equals(2));
      expect(TreeNode.leaf('leaf').isLeaf, isTrue);
    });

    test('should keep children immutable', () {
      final children = [TreeNode.leaf('child')];
      final tree = TreeNode('root', children);

      children.add(TreeNode.leaf('late'));

      expect(tree.children, hasLength(1));
      expect(
        () => tree.children.add(TreeNode.leaf('bad')),
        throwsUnsupportedError,
      );
    });

    test(
      'should traverse in pre-order, post-order, and breadth-first order',
      () {
        final tree = sampleTree();

        expect(
          tree.values(),
          equals([
            'root',
            'left',
            'left.left',
            'right',
            'right.left',
            'right.right',
          ]),
        );
        expect(
          tree.values(order: TreeTraversalOrder.postOrder),
          equals([
            'left.left',
            'left',
            'right.left',
            'right.right',
            'right',
            'root',
          ]),
        );
        expect(
          tree.values(order: TreeTraversalOrder.breadthFirst),
          equals([
            'root',
            'left',
            'right',
            'left.left',
            'right.left',
            'right.right',
          ]),
        );
      },
    );

    test('should find, filter, and map values', () {
      final tree = sampleTree();

      expect(tree.find((value) => value == 'right.left')?.value, 'right.left');
      expect(tree.any((value) => value == 'missing'), isFalse);
      expect(
        tree
            .where((value) => value.startsWith('right'))
            .map((node) => node.value),
        equals(['right', 'right.left', 'right.right']),
      );

      final lengths = tree.map((value) => value.length);
      expect(lengths.values(), equals([4, 4, 9, 5, 10, 11]));
    });
  });

  group('Graph', () {
    test('should add directed vertices and edges', () {
      final graph = Graph<String>.directed()
        ..addEdge('a', 'b')
        ..addEdge('a', 'c')
        ..addVertex('isolated');

      expect(graph.isDirected, isTrue);
      expect(graph.vertexCount, equals(4));
      expect(graph.edgeCount, equals(2));
      expect(graph.neighborsOf('a'), equals({'b', 'c'}));
      expect(graph.neighborsOf('b'), isEmpty);
      expect(graph.vertices, equals(['a', 'b', 'c', 'isolated']));
      expect(
        graph.edges,
        equals([const GraphEdge('a', 'b'), const GraphEdge('a', 'c')]),
      );
    });

    test('should traverse directed graphs deterministically', () {
      final graph = Graph<String>.directed()
        ..addEdge('a', 'b')
        ..addEdge('a', 'c')
        ..addEdge('b', 'd')
        ..addEdge('c', 'e');

      expect(graph.breadthFirst('a'), equals(['a', 'b', 'c', 'd', 'e']));
      expect(graph.depthFirst('a'), equals(['a', 'b', 'd', 'c', 'e']));
      expect(graph.breadthFirst('missing'), isEmpty);
      expect(graph.depthFirst('missing'), isEmpty);
    });

    test('should find shortest unweighted paths', () {
      final graph = Graph<String>.directed()
        ..addEdge('a', 'b')
        ..addEdge('b', 'd')
        ..addEdge('a', 'c')
        ..addEdge('c', 'd')
        ..addVertex('isolated');

      expect(graph.shortestPath('a', 'd'), equals(['a', 'b', 'd']));
      expect(graph.shortestPath('a', 'a'), equals(['a']));
      expect(graph.hasPath('a', 'd'), isTrue);
      expect(graph.hasPath('d', 'a'), isFalse);
      expect(graph.shortestPath('a', 'isolated'), isNull);
      expect(graph.shortestPath('missing', 'a'), isNull);
    });

    test('should maintain reciprocal edges for undirected graphs', () {
      final graph = Graph<String>.undirected()
        ..addEdge('a', 'b')
        ..addEdge('b', 'c');

      expect(graph.isDirected, isFalse);
      expect(graph.edgeCount, equals(2));
      expect(graph.neighborsOf('a'), equals({'b'}));
      expect(graph.neighborsOf('b'), equals({'a', 'c'}));
      expect(graph.shortestPath('c', 'a'), equals(['c', 'b', 'a']));

      expect(graph.removeEdge('a', 'b'), isTrue);
      expect(graph.neighborsOf('a'), isEmpty);
      expect(graph.neighborsOf('b'), equals({'c'}));

      expect(graph.removeVertex('c'), isTrue);
      expect(graph.containsVertex('c'), isFalse);
      expect(graph.neighborsOf('b'), isEmpty);
    });

    test('should create graphs from adjacency maps and edge lists', () {
      final fromAdjacency = Graph<String>.undirected(
        adjacency: {
          'a': ['b'],
          'c': const <String>[],
        },
      );
      final fromEdges = Graph.fromEdges(const [
        GraphEdge('a', 'b'),
        GraphEdge('b', 'c'),
      ]);

      expect(fromAdjacency.neighborsOf('b'), equals({'a'}));
      expect(fromAdjacency.containsVertex('c'), isTrue);
      expect(fromEdges.shortestPath('a', 'c'), equals(['a', 'b', 'c']));
    });

    test('should expose immutable adjacency snapshots', () {
      final graph = Graph<String>.directed()..addEdge('a', 'b');
      final adjacency = graph.adjacency;

      expect(() => adjacency['a']!.add('c'), throwsUnsupportedError);
      expect(() => adjacency['new'] = const <String>{}, throwsUnsupportedError);
      expect(graph.neighborsOf('a'), equals({'b'}));
    });

    test('should detect directed and undirected cycles', () {
      final acyclicDirected = Graph<String>.directed()
        ..addEdge('a', 'b')
        ..addEdge('b', 'c');
      final cyclicDirected = Graph<String>.directed()
        ..addEdge('a', 'b')
        ..addEdge('b', 'c')
        ..addEdge('c', 'a');
      final acyclicUndirected = Graph<String>.undirected()
        ..addEdge('a', 'b')
        ..addEdge('b', 'c');
      final cyclicUndirected = Graph<String>.undirected()
        ..addEdge('a', 'b')
        ..addEdge('b', 'c')
        ..addEdge('c', 'a');

      expect(acyclicDirected.hasCycle, isFalse);
      expect(cyclicDirected.hasCycle, isTrue);
      expect(acyclicUndirected.hasCycle, isFalse);
      expect(cyclicUndirected.hasCycle, isTrue);
    });
  });
}

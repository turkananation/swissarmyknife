import 'package:swissarmyknife/swissarmyknife.dart';

Future<void> main() async {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString()); // 1.5M
  print('hello'.wrap('[', ']')); // [hello]

  final parsed = Result.runCatching(() => int.parse('42'));
  print(parsed.getOrElse(0)); // 42

  final piped = ' 21 '.toPipeline().map((s) => s.trim()).map(int.parse).result;
  print(piped); // 21

  final square = memoize<int, int>((n) => n * n);
  print(square(7)); // 49

  var count = 0;
  final history = CommandHistory();
  history.execute(
    Command<int>(
      name: 'increment',
      execute: () => ++count,
      undo: () => count--,
    ),
  );
  history.undo();
  print(count); // 0

  final lazy = Lazy(() => 'loaded');
  print(lazy.value); // loaded

  final breaker = CircuitBreaker(failureThreshold: 2);
  print((await breaker.execute(() => 42)).valueOrNull); // 42

  final queue = TaskQueue(concurrency: 1);
  print(await queue.add(() => 'queued').future); // queued

  final tree = TreeNode('root', [TreeNode.leaf('child')]);
  print(tree.values().join(' > ')); // root > child

  final graph = Graph<String>.undirected()
    ..addEdge('home', 'cache')
    ..addEdge('cache', 'api');
  print(graph.shortestPath('home', 'api')); // [home, cache, api]

  final encoded = CodecPipelines.stringToBase64.convert('hello');
  print(encoded); // aGVsbG8=

  final evaluator = ExpressionEvaluator();
  print(
    evaluator.evaluate(
      'price * quantity',
      variables: {'price': 9, 'quantity': 4},
    ),
  ); // 36

  final store = ReactiveStore<int>(0);
  store.set(3);
  print(store.state); // 3
  await store.dispose();

  final cron = CronExpression.parse('0 9 * * MON-FRI');
  print(cron.next(DateTime(2026, 7, 2, 8, 30))); // 2026-07-02 09:00:00.000

  final middleware = MiddlewarePipeline<int>().use(
    MiddlewarePipeline.transform((value) => value + 1),
  );
  print(await middleware.run(4)); // 5

  final debouncer = Debouncer(const Duration(milliseconds: 250));
  debouncer.run(() => print('debounced'));
  debouncer.dispose();

  final validator = Validator<String>.email().minLength(5);
  print(validator.validate('me@example.com').isSuccess); // true

  final json = {
    'user': {'name': 'Ada'},
  };
  print(json.at('user.name').asStringOr('Unknown')); // Ada

  final userSchema = SchemaValidator.object({
    'name': SchemaField(SchemaValidator.string(minLength: 1)),
  });
  print(userSchema.validate({'name': 'Ada'}).isValid); // true

  final request = Http.get(
    'https://api.example.com/users',
  ).withTimeout(const Duration(seconds: 5));
  print(request.method); // GET

  final api = ApiClientBuilder(
    'https://api.example.com/v1',
  ).withBearerToken('token').build();
  print(
    api.resolve('users', query: {'page': 1}),
  ); // https://api.example.com/v1/users?page=1

  Log.i('ready', tag: 'APP');
}

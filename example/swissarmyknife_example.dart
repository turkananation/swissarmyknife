import 'package:swissarmyknife/swissarmyknife.dart';

void main() {
  print('hello_world'.toPascalCase()); // HelloWorld
  print(1500000.toCompactString()); // 1.5M
  print('hello'.wrap('[', ']')); // [hello]
}

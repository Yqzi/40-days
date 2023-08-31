void main() {
  List<int> l = [1, 2, 3];
  List<int> l2 = l.map((e) => e).toList();

  l2.add(4);

  print(l);
}

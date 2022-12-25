import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

//1 Components
//2 Stateless
//3 Dio / Http
//4 State Managment = Providers / GetX / BloC / Cubit
//5 Animation

void main() async {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemList()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<String> fetchText() async {
  // try catch
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var response =
      await http.get(Uri.parse('https://www.boredapi.com/api/activity'));
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    var dynamicText = jsonResponse['activity'];
    print('the game says $dynamicText.');
    prefs.setString("quote_tag", dynamicText);
    return dynamicText;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return "false";
  }
}

class ItemList with ChangeNotifier, DiagnosticableTreeMixin {
  List<String> _itemsliked = [];

  void addItem(String itemData) {
    _itemsliked.add(itemData);
    notifyListeners();
  }

  void DeleteItem(String itemData) {
    _itemsliked.remove(itemData);
    notifyListeners();
  }

  List<String> get itemliked => _itemsliked;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(
        title: 'test2',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ItemList model = ItemList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model._itemsliked;
  }

  late Future<String> _session;

  List<String> Liked = [];

  void _nextText() {
    setState(() {
      _session = fetchText();
    });
  }

  @override
  void initState() {
    _session = fetchText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _session,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Material(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                    width: 50,
                    child: Center(
                        child: Image.asset(
                      "assets/images/boring.png",
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withOpacity(0.4),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0)),
                    ),
                    height: 500,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        child: Center(
                            child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                                color: Colors.black,
                                wordSpacing: 0,
                                decoration: TextDecoration.none,
                                fontSize: 36,
                                fontWeight: FontWeight.bold),
                          ),
                        ))),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: IconButton(
                        onPressed: () {
                          _nextText();
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        iconSize: 45,
                        color: Color(0xFFFF5E51),
                      )),
                      Expanded(
                          child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnimatedListSample()),
                          );
                        },
                        icon: const Icon(Icons.star),
                        iconSize: 36,
                        color: Color(0xFF07A6FF),
                      )),
                      Expanded(
                          child: IconButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString("liked", '${snapshot.data} ');
                          print('added to liked : ' + '${snapshot.data} ');
                          Liked.add('${snapshot.data}');
                          print(Liked);
                          //providerItem.addItem('${snapshot.data}');
                          //context.watch<ItemList>().addItem('${snapshot.data}');
                          // ignore: use_build_context_synchronously
                          Provider.of<ItemList>(context, listen: false)
                              .addItem('${snapshot.data}');

                          _nextText();
                        },
                        icon: const Icon(Icons.favorite_rounded),
                        iconSize: 45,
                        color: Color(0xFF00D387),
                      )),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

class AnimatedListSample extends StatefulWidget {
  const AnimatedListSample({super.key});

  @override
  State<AnimatedListSample> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<AnimatedListSample> {
  final List<int> _items = List<int>.generate(50, (int index) => index);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My liked activities"),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: ReorderableListView(
          children: <Widget>[
            for (int index = 0;
                index < Provider.of<ItemList>(context)._itemsliked.length;
                index += 1)
              ListTile(
                key: Key('$index'),
                tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                title: Text(Provider.of<ItemList>(context)._itemsliked[index]),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final String item = Provider.of<ItemList>(context, listen: false)
                  ._itemsliked
                  .removeAt(oldIndex);
              Provider.of<ItemList>(context, listen: false)
                  ._itemsliked
                  .insert(newIndex, item);
            });
          },
        ),
      ),
    );
  }
}

class _AnimatedListSampleState extends State<AnimatedListSample> {
  List<String> Liked;
  _AnimatedListSampleState(this.Liked);

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<int> _list;
  int? _selectedItem;
  late int
      _nextItem; // The next item inserted when the user presses the '+' button.

  @override
  void initState() {
    super.initState();
    _list = ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[0, 1, 2],
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = 3;
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(
      int item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    final int index =
        _selectedItem == null ? _list.length : _list.indexOf(_selectedItem!);
    _list.insert(index, _nextItem++);
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem!));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("my Liked items"),
      ),
      body: ReorderableListView(
          onReorder: ((int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final String item =
                  Provider.of<ItemList>(context)._itemsliked.removeAt(oldIndex);
              Provider.of<ItemList>(context)._itemsliked.insert(newIndex, item);
            });
          }),
          children: List.generate(
            Provider.of<ItemList>(context)._itemsliked.length,
            (index) => ListTile(
              key: Key('$index'),
              trailing: const Icon(Icons.favorite),
              title: Text(Provider.of<ItemList>(context)._itemsliked[index]),
            ),
          )),
    );
  }
}

typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList!.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    this.onTap,
    this.selected = false,
    required this.animation,
    required this.item,
  }) : assert(item >= 0);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final int item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headlineMedium!;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    }
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 80.0,
            child: Card(
              color: Colors.primaries[item % Colors.primaries.length],
              child: Center(
                child: Text('Item $item', style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

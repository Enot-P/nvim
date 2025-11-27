local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

-- Вспомогательная функция для получения имени класса
local function get_class_name(args)
	return args[1][1] or "ClassName"
end

-- Flutter/Dart снипеты
return {
	-- Stateless Widget
	s("stateL", {
		t("class "),
		i(1, "name"),
		t(" extends StatelessWidget {"),
		t({ "", "  const " }),
		f(get_class_name, { 1 }),
		t("({super.key});"),
		t({ "", "", "  @override" }),
		t({ "", "  Widget build(BuildContext context) {" }),
		t({ "", "    return Container(" }),
		t({ "", "      child: " }),
		i(2, "null"),
		t(","),
		t({ "", "    );" }),
		t({ "", "  }" }),
		t({ "", "}" }),
	}),

	-- Example StatelessWidget with Scaffold > SafeArea > Center > ElevatedButton
	s("example_widget", {
		t("class "),
		i(1, "ExampleWidget"),
		t(" extends StatelessWidget {"),
		t({ "", "  const " }),
		f(get_class_name, { 1 }),
		t("({super.key});"),
		t({ "", "", "  @override" }),
		t({ "", "  Widget build(BuildContext context) {" }),
		t({ "", "    return Scaffold(" }),
		t({ "", "      body: SafeArea(" }),
		t({ "", "        child: Center(" }),
		t({ "", "          child: ElevatedButton(" }),
		t({ "", "            onPressed: " }),
		i(2, "() {}"),
		t(","),
		t({ "", "            child: const Text(\"Жми меня\")," }),
		t({ "", "          )," }),
		t({ "", "        )," }),
		t({ "", "      )," }),
		t({ "", "    );" }),
		t({ "", "  }" }),
		t({ "", "}" }),
	}),

	-- Stateful Widget
	s("stateF", {
		t("class "),
		i(1, "name"),
		t(" extends StatefulWidget {"),
		t({ "", "  " }),
		f(get_class_name, { 1 }),
		t("({super.key});"),
		t({ "", "", "  @override" }),
		t({ "", "  State<" }),
		f(get_class_name, { 1 }),
		t("> createState() => _"),
		f(get_class_name, { 1 }),
		t("State();"),
		t({ "", "}" }),
		t({ "", "" }),
		t({ "", "class _" }),
		f(get_class_name, { 1 }),
		t("State extends State<"),
		f(get_class_name, { 1 }),
		t("> {"),
		t({ "", "  @override" }),
		t({ "", "  Widget build(BuildContext context) {" }),
		t({ "", "    return Container(" }),
		t({ "", "       child: " }),
		i(2, "null"),
		t(","),
		t({ "", "    );" }),
		t({ "", "  }" }),
		t({ "", "}" }),
	}),

	-- Build Method
	s("build", {
		t("@override"),
		t({ "", "Widget build(BuildContext context) {" }),
		t({ "", "  return " }),
		i(0),
		t(";"),
		t({ "", "}" }),
	}),

	-- InitState
	s("initS", {
		t("@override"),
		t({ "", "void initState() {" }),
		t({ "", "  super.initState();" }),
		t({ "", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- Dispose
	s("dis", {
		t("@override"),
		t({ "", "void dispose() {" }),
		t({ "", "  " }),
		i(0),
		t({ "", "  super.dispose();" }),
		t({ "", "}" }),
	}),

	-- ListView Builder
	s("listViewB", {
		t("ListView.builder("),
		t({ "", "  itemCount: " }),
		i(1, "1"),
		t(","),
		t({ "", "  itemBuilder: (BuildContext context, int index) {" }),
		t({ "", "    return " }),
		i(2),
		t(";"),
		t({ "", "  }," }),
		t({ "", ")," }),
	}),

	-- GridView Builder
	s("gridViewB", {
		t("GridView.builder("),
		t({ "", "  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(" }),
		t({ "", "    crossAxisCount: " }),
		i(1, "2"),
		t(","),
		t({ "", "  )," }),
		t({ "", "  itemCount: " }),
		i(2, "2"),
		t(","),
		t({ "", "  itemBuilder: (BuildContext context, int index) {" }),
		t({ "", "    return " }),
		i(3),
		t(";"),
		t({ "", "  }," }),
		t({ "", ")," }),
	}),

	-- Stream Builder
	s("streamBldr", {
		t("StreamBuilder("),
		t({ "", "  stream: " }),
		i(1, "stream"),
		t(","),
		t({ "", "  initialData: " }),
		i(2, "initialData"),
		t(","),
		t({ "", "  builder: (BuildContext context, AsyncSnapshot snapshot) {" }),
		t({ "", "    return Container(" }),
		t({ "", "      child: " }),
		i(3, "child"),
		t(","),
		t({ "", "    );" }),
		t({ "", "  }," }),
		t({ "", ")," }),
	}),

	-- Future Builder
	s("futureBldr", {
		t("FutureBuilder("),
		t({ "", "  future: " }),
		i(1, "Future"),
		t(","),
		t({ "", "  initialData: " }),
		i(2, "InitialData"),
		t(","),
		t({ "", "  builder: (BuildContext context, AsyncSnapshot snapshot) {" }),
		t({ "", "    return " }),
		i(3),
		t(";"),
		t({ "", "  }," }),
		t({ "", ")," }),
	}),

	-- Material App
	s("mateapp", {
		t("import 'package:flutter/material.dart';"),
		t({ "", "" }),
		t({ "", "void main() => runApp(MyApp());" }),
		t({ "", "" }),
		t({ "", "class MyApp extends StatelessWidget {" }),
		t({ "", "  @override" }),
		t({ "", "  Widget build(BuildContext context) {" }),
		t({ "", "    return MaterialApp(" }),
		t({ "", "      title: 'Material App'," }),
		t({ "", "      home: Scaffold(" }),
		t({ "", "        appBar: AppBar(" }),
		t({ "", "          title: Text('Material App Bar')," }),
		t({ "", "        )," }),
		t({ "", "        body: Center(" }),
		t({ "", "          child: Container(" }),
		t({ "", "            child: Text('Hello World')," }),
		t({ "", "          )," }),
		t({ "", "        )," }),
		t({ "", "      )," }),
		t({ "", "    );" }),
		t({ "", "  }" }),
		t({ "", "}" }),
	}),

	-- Cupertino App
	s("cupeapp", {
		t("import 'package:flutter/cupertino.dart';"),
		t({ "", "" }),
		t({ "", "void main() => runApp(MyApp());" }),
		t({ "", "" }),
		t({ "", "class MyApp extends StatelessWidget {" }),
		t({ "", "  @override" }),
		t({ "", "  Widget build(BuildContext context) {" }),
		t({ "", "    return CupertinoApp(" }),
		t({ "", "      title: 'Cupertino App'," }),
		t({ "", "      home: CupertinoPageScaffold(" }),
		t({ "", "        navigationBar: CupertinoNavigationBar(" }),
		t({ "", "          middle: Text('Cupertino App Bar')," }),
		t({ "", "        )," }),
		t({ "", "        child: Center(" }),
		t({ "", "          child: Container(" }),
		t({ "", "            child: Text('Hello World')," }),
		t({ "", "          )," }),
		t({ "", "        )," }),
		t({ "", "      )," }),
		t({ "", "    );" }),
		t({ "", "  }" }),
		t({ "", "}" }),
	}),

	-- Debug Print
	s("debugP", {
		t("debugPrint("),
		i(1, "statement"),
		t(");"),
	}),

	-- Import statements
	s("importM", {
		t("import 'package:flutter/material.dart';"),
	}),

	s("importC", {
		t("import 'package:flutter/cupertino.dart';"),
	}),

	-- Custom Painter
	s("customPainter", {
		t("class "),
		i(1, "name"),
		t("Painter extends CustomPainter {"),
		t({ "", "" }),
		t({ "", "  @override" }),
		t({ "", "  void paint(Canvas canvas, Size size) {" }),
		t({ "", "  }" }),
		t({ "", "" }),
		t({ "", "  @override" }),
		t({ "", "  bool shouldRepaint(" }),
		f(get_class_name, { 1 }),
		t("Painter oldDelegate) => false;"),
		t({ "", "" }),
		t({ "", "  @override" }),
		t({ "", "  bool shouldRebuildSemantics(" }),
		f(get_class_name, { 1 }),
		t("Painter oldDelegate) => false;"),
		t({ "", "}" }),
	}),

	-- Main function
	s("main", {
		t("void main(List<String> args) {"),
		t({ "", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- Try-catch
	s("try", {
		t("try {"),
		t({ "", "  " }),
		i(0),
		t({ "", "} catch (" }),
		i(1, "e"),
		t(") {"),
		t({ "", "}" }),
	}),

	-- If statement
	s("if", {
		t("if ("),
		i(1),
		t(") {"),
		t({ "", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- If-else statement
	s("ife", {
		t("if ("),
		i(1),
		t(") {"),
		t({ "", "  " }),
		i(0),
		t({ "", "} else {" }),
		t({ "", "}" }),
	}),

	-- For loop
	s("for", {
		t("for (var i = 0; i < "),
		i(1, "count"),
		t("; i++) {"),
		t({ "", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- For-in loop
	s("fori", {
		t("for (var "),
		i(1, "item"),
		t(" in "),
		i(2, "items"),
		t(") {"),
		t({ "", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- Class definition
	s("class", {
		t("class "),
		i(1, "Name"),
		t(" {"),
		t({ "", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- Test function
	s("test", {
		t("test('"),
		i(1),
		t("', () {"),
		t({ "", "  " }),
		i(0),
		t({ "", "});" }),
	}),

	-- Widget test
	s("widgetTest", {
		t("testWidgets("),
		t({ "", "   '" }),
		i(1, "test description"),
		t("',"),
		t({ "", "   (WidgetTester tester) async {}," }),
		t({ "", "});" }),
	}),

	-- =====================
	-- Bloc snippets
	-- =====================

	-- Imports
	s("importbloc", {
		t("import 'package:bloc/bloc.dart';")
	}),
	s("importflutterbloc", {
		t("import 'package:flutter_bloc/flutter_bloc.dart';")
	}),
	s("importbloctest", {
		t("import 'package:bloc_test/bloc_test.dart';")
	}),

	-- Bloc class
	s("bloc", {
		t("import 'package:bloc/bloc.dart';"),
		t({"", ""}),
		t("class "), i(1, "MyBloc"), t(" extends Bloc<"), i(2, "MyEvent"), t(", "), i(3, "MyState"), t("> {"),
		t({"", "  "}), t(""),
		t({"", "  "}), t(""),
		t({"", "  ",}),
		t({"", "  "}), t(""),
		t({"", "  "}), t(""),
		t({"", "  "}), t(""),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", ""}),
		t({"", "  ",}),
		t({"", "  "}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  ",}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "  ", "  "}),
		t({"", "}"}),
	}),

	-- Cubit class
	s("cubit", {
		t("import 'package:bloc/bloc.dart';"),
		t({"", ""}),
		t("class "), i(1, "MyCubit"), t(" extends Cubit<"), i(2, "MyState"), t("> {"),
		t({"", "  ", "  ",}),
		t({"", "}"}),
	}),

	-- Event handler registration (on<Event>)
	s("onevent", {
		t("on<"), i(1, "MyEvent"), t(">(event, emit) async {"),
		t({"", "  "}), i(0),
		t({"", "});"}),
	}),
	-- Private event handler method
	s("_onevent", {
		t("Future<void> _on"), i(1, "Event"), t("("), i(2, "MyEvent"), t(
			", Emitter<"), i(3, "MyState"), t("> emit) async {"),
		t({"", "  "}), i(0),
		t({"", "}"}),
	}),

	-- BlocObserver
	s("blocobserver", {
		t("class "), i(1, "AppBlocObserver"), t(" extends BlocObserver {"),
		t({"", "  @override"}),
		t({"", "  void onChange(BlocBase bloc, Change change) {"}),
		t({"", "    super.onChange(bloc, change);"}),
		t({"", "  }"}),
		t({"", "  @override"}),
		t({"", "  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {"}),
		t({"", "    super.onError(bloc, error, stackTrace);"}),
		t({"", "  }"}),
		t({"", "}"}),
	}),

	-- Providers
	s("blocprovider", {
		t("BlocProvider<"), i(1, "MyBloc"), t({">(", "  create: (context) => "}),
		i(2, "MyBloc()"), t({",", "  child: "}), i(0, "child"), t({",", ")"}),
	}),
	s("multiblocprovider", {
		t({"MultiBlocProvider(", "  providers: const [", "    // BlocProvider(create: (_) => MyBloc()),", "  ],", "  child: "}),
		i(0, "child"), t({",", ")"}),
	}),
	s("repoprovider", {
		t("RepositoryProvider<"), i(1, "MyRepository"), t({">(", "  create: (context) => "}),
		i(2, "MyRepository()"), t({",", "  child: "}), i(0, "child"), t({",", ")"}),
	}),
	s("multirepoprovider", {
		t({"MultiRepositoryProvider(", "  providers: const [", "    // RepositoryProvider(create: (_) => MyRepository()),", "  ],", "  child: "}),
		i(0, "child"), t({",", ")"}),
	}),

	-- Widgets
	s("blocbuilder", {
		t("BlocBuilder<"), i(1, "MyBloc"), t(", "), i(2, "MyState"), t({">(", "  builder: (context, state) {", "    "}), i(0), t({"", "  },", ")"}),
	}),
	s("blocselector", {
		t("BlocSelector<"), i(1, "MyBloc"), t(", "), i(2, "T"), t({">(", "  selector: (context, state) {", "    return "}), i(3, "state as T"), t({";", "  },", "  builder: (context, selected) {", "    "}), i(0), t({"", "  },", ")"}),
	}),
	s("bloclistener", {
		t("BlocListener<"), i(1, "MyBloc"), t(", "), i(2, "MyState"), t({">(", "  listener: (context, state) {", "    "}), i(0), t({"", "  },", "  child: "}), i(3, "child"), t({",", ")"}),
	}),
	s("multibloclistener", {
		t({"MultiBlocListener(", "  listeners: const [", "    // BlocListener<Bloc, State>(listener: (context, state) {}),", "  ],", "  child: "}),
		i(0, "child"), t({",", ")"}),
	}),
	s("blocconsumer", {
		t("BlocConsumer<"), i(1, "MyBloc"), t(", "), i(2, "MyState"), t({">(", "  listener: (context, state) {", "    "}), i(0), t({"", "  },", "  builder: (context, state) {", "    "}), i(3), t({"", "  },", ")"}),
	}),

	-- Shortcuts
	s("blocof", {
		t("BlocProvider.of<"), i(1, "MyBloc"), t(">(context)"),
	}),
	s("repoof", {
		t("RepositoryProvider.of<"), i(1, "MyRepository"), t(">(context)"),
	}),
	s("read", {
		t("context.read<"), i(1, "T"), t(">()"),
	}),
	s("watch", {
		t("context.watch<"), i(1, "T"), t(">()"),
	}),
	s("select", {
		t("context.select<"), i(1, "T"), t(", "), i(2, "R"), t(">(("), i(3, "value"), t(") => "), i(4, "expr"), t(")"),
	}),

	-- Event/State
	s("blocstate", {
		t("class "), i(1, "MyState"), t({" {", "  const "}), f(get_class_name, {1}), t("();"),
		t({"", "}"}),
	}),
	s("blocevent", {
		t("class "), i(1, "MyEvent"), t({" {", "  const "}), f(get_class_name, {1}), t("();"),
		t({"", "}"}),
	}),

	-- blocTest
	s("bloctest", {
		t("blocTest<"), i(1, "MyBloc"), t({">(", "  '"}), i(2, "description"), t({"',", "  build: () => "}), i(3, "MyBloc()"), t({",", "  act: (bloc) => "}), i(4, ""), t({",", "  expect: () => ["}), i(5, ""), t({"],", ")"}),
	}),

	-- Mocks
	s("mockbloc", {
		t("class "), i(1, "MockMyBloc"), t(" extends MockBloc<"), i(2, "MyEvent"), t(", "), i(3, "MyState"), t("> implements "), i(4, "MyBloc"), t(" {}"),
	}),
	s("_mockbloc", {
		t("class _"), i(1, "MockMyBloc"), t(" extends MockBloc<"), i(2, "MyEvent"), t(", "), i(3, "MyState"), t("> implements "), i(4, "MyBloc"), t(" {}"),
	}),
	s("mockcubit", {
		t("class "), i(1, "MockMyCubit"), t(" extends MockCubit<"), i(2, "MyState"), t("> implements "), i(3, "MyCubit"), t(" {}"),
	}),
	s("_mockcubit", {
		t("class _"), i(1, "MockMyCubit"), t(" extends MockCubit<"), i(2, "MyState"), t("> implements "), i(3, "MyCubit"), t(" {}"),
	}),
	s("fake", {
		t("class "), i(1, "MyFake"), t(" extends Fake {}"),
	}),
	s("_fake", {
		t("class _"), i(1, "MyFake"), t(" extends Fake {}"),
	}),
	s("mock", {
		t("class "), i(1, "MyMock"), t(" extends Mock {}"),
	}),
	s("_mock", {
		t("class _"), i(1, "MyMock"), t(" extends Mock {}"),
	}),

	-- Freezed
	s("fstate", {
		t("@freezed"),
		t({"", "class "}), i(1, "MyState"), t(" with _"), f(get_class_name, {1}), t({" {", "  const factory "}), f(get_class_name, {1}), t("() = _"), f(get_class_name, {1}), t(";"),
		t({"", "}"}),
	}),
	s("fevent", {
		t("@freezed"),
		t({"", "class "}), i(1, "MyEvent"), t(" with _"), f(get_class_name, {1}), t({" {", "  const factory "}), f(get_class_name, {1}), t("() = _"), f(get_class_name, {1}), t(";"),
		t({"", "}"}),
	}),

  -- Snippet for InheritedWidget with watch, read, and updateShouldNotify
s("inheritedW", {
    t("class "),
    i(1, "MyInheritedWidget"),
    t(" extends InheritedWidget {"),
    t({"", "  final "}),
    i(2, "ModelType"),
    t({" model;"}),
    t({"", "  const "}),
    f(get_class_name, {1}),
    t({"({", "    super.key,", "    required this.model,", "    required super.child,", "  });", ""}),
    t({"  @override", "  bool updateShouldNotify("}),
    f(get_class_name, {1}),
    t({" oldWidget) => model != oldWidget.model;", ""}),
    t({"", "  static "}),
    f(get_class_name, {1}),
    t({"? watch(BuildContext context) {", "    return context.dependOnInheritedWidgetOfExactType<"}),
    f(get_class_name, {1}),
    t({">();", "  }", ""}),
    t({"", "  static "}),
    f(get_class_name, {1}),
    t({"? read(BuildContext context) {", "    final element = context.getElementForInheritedWidgetOfExactType<"}),
    f(get_class_name, {1}),
    t({">();", "    return element?.widget as "}),
    f(get_class_name, {1}),
    t({"?;", "  }", "}"})
}),
s("inheritedNotifier", {
    t("class "),
    i(1, "MyInheritedNotifier"),
    t(" extends InheritedNotifier<"),
    i(2, "NotifierType"),
    t({"> {", "  final "}),
    f(function(args)
        return args[1][1] .. "Model"
    end, {2}),
    t({" model;", ""}),
    t({"  const "}),
    f(get_class_name, {1}),
    t({"({", "    super.key,", "    required this.model,", "    required super.child,", "  }) : super(notifier: model);", ""}),
    t({"  @override", "  bool updateShouldNotify("}),
    f(get_class_name, {1}),
    t({" oldWidget) => model != oldWidget.model;", ""}),
    t({"", "  static "}),
    f(get_class_name, {1}),
    t({"? watch(BuildContext context) {", "    return context", "        .dependOnInheritedWidgetOfExactType<"}),
    f(get_class_name, {1}),
    t({">();", "  }", ""}),
    t({"", "  static "}),
    f(get_class_name, {1}),
    t({"? read(BuildContext context) {", "    final element = context", "        .getElementForInheritedWidgetOfExactType<"}),
    f(get_class_name, {1}),
    t({">();", "    return element?.widget as "}),
    f(get_class_name, {1}),
    t({"?;", "  }", "}"})
}),
}

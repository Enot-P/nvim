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
	s("statelessW", {
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

	-- Stateful Widget
	s("statefulW", {
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
}

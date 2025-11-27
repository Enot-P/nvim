local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

local function pascal_case(str)
  if not str or str == "" then return "Subject" end
  local parts = {}
  for w in tostring(str):gmatch("[^_%s-]+") do
    parts[#parts + 1] = (w:sub(1, 1):upper() .. w:sub(2):lower())
  end
  return table.concat(parts, "")
end

local function filename_subject(_, snip)
  local base = snip.env.TM_FILENAME_BASE or ""
  base = base:gsub("_(bloc|cubit)$", "")
  return pascal_case(base ~= "" and base or "Subject")
end

return {
  -- Bloc
  s("bloc", {
    t("class "), i(1, "Subject"), t("Bloc extends Bloc<"), i(2, "Subject"), t("Event, "), i(3, "Subject"), t({"State> {", "\t"}),
    f(function(_, snip) return (snip.nodes[1].mark:pos_begin() and "" or "") end, {}),
    t("") ,
    f(function(args) return args[1][1] end, {1}), t("Bloc() : super("), f(function(args) return args[1][1] end, {1}), t({"Initial()) {", "\t\ton<"}),
    f(function(args) return args[1][1] end, {2}), t("Event>((event, emit) {"),
    t({"", "\t\t\t"}), i(4, "// TODO: implement event handler"),
    t({"", "\t\t});", "\t}", "}"}),
  }),

  -- Cubit
  s("cubit", {
    t("class "), i(1, "Subject"), t("Cubit extends Cubit<"), i(2, "Subject"), t({"State> {", "\t"}),
    f(function(args) return args[1][1] end, {1}), t("Cubit() : super("), f(function(args) return args[1][1] end, {1}), t({"Initial());", "}"}),
  }),

  -- BlocObserver
  s("blocobserver", {
    t({"import 'package:bloc/bloc.dart';", "", "class "}), i(1, "My"), t({"BlocObserver extends BlocObserver {", "\t@override", "\tvoid onEvent(Bloc bloc, Object? event) {", "\t\tsuper.onEvent(bloc, event);", "\t\t"}), i(2, "// TODO: implement onEvent"), t({"", "\t}", "", "\t@override", "\tvoid onError(BlocBase bloc, Object error, StackTrace stackTrace) {", "\t\t"}), i(3, "// TODO: implement onError"), t({"", "\t\tsuper.onError(bloc, error, stackTrace);", "\t}", "", "\t@override", "\tvoid onChange(BlocBase bloc, Change change) {", "\t\tsuper.onChange(bloc, change);", "\t\t"}), i(4, "// TODO: implement onChange"), t({"", "\t}", "", "\t@override", "\tvoid onTransition(Bloc bloc, Transition transition) {", "\t\tsuper.onTransition(bloc, transition);", "\t\t"}), i(5, "// TODO: implement onTransition"), t({"", "\t}", "}"}),
  }),

  -- Bloc State
  s("blocstate", {
    t("class "), i(1, "Subject"), i(2, "Verb"), i(3, "State"), t(" extends "), f(function(args) return args[1][1] end, {1}), t({"State {", "\tconst "}),
    f(function(args) return args[1][1] .. (args[2][1] or "") .. (args[3][1] or "") end, {1, 2, 3}), t("("), i(5), t({");", "", "\t"}), i(4), t({"", "", "\t@override", "\tList<Object> get props => ["}), i(6), t({"];", "}"}),
  }),

  -- Bloc Event
  s("blocevent", {
    t("class "), i(1, "Subject"), i(2, "Noun"), i(3, "Verb"), t(" extends "), f(function(args) return args[1][1] end, {1}), t({"Event {", "\tconst "}),
    f(function(args) return args[1][1] .. (args[2][1] or "") .. (args[3][1] or "") end, {1, 2, 3}), t("("), i(5), t({");", "", "\t"}), i(4), t({"", "", "\t@override", "\tList<Object> get props => ["}), i(6), t({"];", "}"}),
  }),

  -- Import package:bloc
  s("importbloc", { t("import 'package:bloc/bloc.dart';") }),

  -- Register Event Handler (on<Event>)
  s("onevent", {
    t("on<"), f(function(_, snip) return filename_subject(_, snip) end, {}), t("Event>((event, emit) {"),
    t({"", "\t"}), i(1, "// TODO: implement event handler"),
    t({"", "});"}),
  }),

  -- Define Event Handler (_onEvent)
  s("_onevent", {
    c(1, { t("void"), t("Future<void>") }), t(" _on"), i(2, "Event"), t("("),
    f(function(_, snip) return (snip.nodes[2] and snip.nodes[2].opts and snip.nodes[2].opts.pos) and "" or "" end, {}),
    t("\n\t"), f(function(args) return args[1][1] end, {2}), t(" event,"),
    t("\n\tEmitter<"), f(function(_, snip) return filename_subject(_, snip) end, {}), t("State> emit,"),
    t({"", ") "}), c(3, { t("");, t("async") }), t({" {", "\t"}), i(4, "// TODO: implement event handler"), t({"", "}"}),
  }),

  -- BlocTest
  s("bloctest", {
    t("blocTest<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {1}), t({"State>(", "\t'emits ["}), i(3, "MyState"), t("] when "), i(4, "MyEvent"), t({" is added.',", "\tbuild: () => "}), f(function(args) return args[1][1] end, {1}), c(5, { t("Bloc"), t("Cubit") }), t({"(),", "\tact: (bloc) => bloc.add("}), i(6, "MyEvent()"), t({"),", "\texpect: () => const <"}), f(function(args) return args[1][1] end, {1}), t({"State>["}), f(function(args) return args[1][1] end, {3}), t({"()],", ");"}),
  }),

  -- Import package:bloc_test
  s("importbloctest", { t("import 'package:bloc_test/bloc_test.dart';") }),

  -- Mock/ Fake/ etc.
  s("mockbloc", { t("class Mock"), i(1, "Subject"), t("Bloc extends MockBloc<"), f(function(args) return args[1][1] end, {1}), t("Event, "), f(function(args) return args[1][1] end, {1}), t("State> implements "), f(function(args) return args[1][1] end, {1}), t("Bloc {}") }),
  s("_mockbloc", { t("class _Mock"), i(1, "Subject"), t("Bloc extends MockBloc<"), f(function(args) return args[1][1] end, {1}), t("Event, "), f(function(args) return args[1][1] end, {1}), t("State> implements "), f(function(args) return args[1][1] end, {1}), t("Bloc {}") }),
  s("mockcubit", { t("class Mock"), i(1, "Subject"), t("Cubit extends MockCubit<"), f(function(args) return args[1][1] end, {1}), t("State> implements "), f(function(args) return args[1][1] end, {1}), t("Cubit {}") }),
  s("_mockcubit", { t("class _Mock"), i(1, "Subject"), t("Cubit extends MockCubit<"), f(function(args) return args[1][1] end, {1}), t("State> implements "), f(function(args) return args[1][1] end, {1}), t("Cubit {}") }),
  s("fake", { t("class Fake"), i(1, "Subject"), t(" extends Fake implements "), f(function(args) return args[1][1] end, {1}), t(" {}") }),
  s("_fake", { t("class _Fake"), i(1, "Subject"), t(" extends Fake implements "), f(function(args) return args[1][1] end, {1}), t(" {}") }),
  s("mock", { t("class Mock"), i(1, "Subject"), t(" extends Mock implements "), f(function(args) return args[1][1] end, {1}), t(" {}") }),
  s("_mock", { t("class _Mock"), i(1, "Subject"), t(" extends Mock implements "), f(function(args) return args[1][1] end, {1}), t(" {}") }),

  -- Providers and Widgets
  s("blocprovider", {
    t({"BlocProvider(", "\tcreate: (context) => "}), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t({"(),", "\tchild: "}), i(3, "Container()"), t({",", ")"}),
  }),
  s("multiblocprovider", {
    t({"MultiBlocProvider(", "\tproviders: [", "\t\tBlocProvider(", "\t\t\tcreate: (context) => "}), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t({"(),", "\t\t),", "\t\tBlocProvider(", "\t\t\tcreate: (context) => "}), i(3, "Subject"), c(4, { t("Bloc"), t("Cubit") }), t({"(),", "\t\t),", "\t],", "\tchild: "}), i(5, "Container()"), t({",", ")"}),
  }),
  s("repoprovider", {
    t({"RepositoryProvider(", "\tcreate: (context) => "}), i(1, "Subject"), t({"Repository(),", "\tchild: "}), i(2, "Container()"), t({",", ")"}),
  }),
  s("multirepoprovider", {
    t({"MultiRepositoryProvider(", "\tproviders: [", "\t\tRepositoryProvider(", "\t\t\tcreate: (context) => "}), i(1, "Subject"), t({"Repository(),", "\t\t),", "\t\tRepositoryProvider(", "\t\t\tcreate: (context) => "}), i(2, "Subject"), t({"Repository(),", "\t\t),", "\t],", "\tchild: "}), i(3, "Container()"), t({",", ")"}),
  }),
  s("blocbuilder", {
    t("BlocBuilder<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {1}), t({"State>(", "\tbuilder: (context, state) {", "\t\treturn "}), i(3, "Container()"), t({";", "\t},", ")"}),
  }),
  s("blocselector", {
    t("BlocSelector<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {1}), t("State, "), i(3, "Selected"), t({">(", "\tselector: (state) {", "\t\treturn "}), i(4, "state"), t({";", "\t},", "\tbuilder: (context, state) {", "\t\treturn "}), i(5, "Container()"), t({";", "\t},", ")"}),
  }),
  s("bloclistener", {
    t("BlocListener<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {1}), t({"State>(", "\tlistener: (context, state) {", "\t\t"}), i(3, "// TODO: implement listener"), t({"", "\t},", "\tchild: "}), i(4, "Container()"), t({",", ")"}),
  }),
  s("multibloclistener", {
    t({"MultiBlocListener(", "\tlisteners: [", "\t\tBlocListener<"}), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {1}), t({"State>(", "\t\t\tlistener: (context, state) {", "\t\t\t\t"}), i(3, "// TODO: implement listener"), t({"", "\t\t\t},", "\t\t),", "\t\tBlocListener<"}), i(4, "Subject"), c(5, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {4}), t({"State>(", "\t\t\tlistener: (context, state) {", "\t\t\t\t"}), i(6, "// TODO: implement listener"), t({"", "\t\t\t},", "\t\t),", "\t],", "\tchild: "}), i(7, "Container()"), t({",", ")"}),
  }),
  s("blocconsumer", {
    t("BlocConsumer<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(", "), f(function(args) return args[1][1] end, {1}), t({"State>(", "\tlistener: (context, state) {", "\t\t"}), i(3, "// TODO: implement listener"), t({"", "\t},", "\tbuilder: (context, state) {", "\t\treturn "}), i(4, "Container()"), t({";", "\t},", ")"}),
  }),

  -- Shortcuts and imports for flutter_bloc
  s("blocof", { t("BlocProvider.of<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(">(context)") }),
  s("repoof", { t("RepositoryProvider.of<"), i(1, "Subject"), t(")>(context)") }),
  s("read", { t("context.read<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit"), t("Repository") }), t(">()") }),
  s("select", { t("context.select(("), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit") }), t(" "), i(3, "bloc"), t(") => "), i(4, "bloc.state"), t(")") }),
  s("watch", { t("context.watch<"), i(1, "Subject"), c(2, { t("Bloc"), t("Cubit"), t("Repository") }), t(">()") }),
  s("importflutterbloc", { t("import 'package:flutter_bloc/flutter_bloc.dart';") }),

  -- Freezed snippets
  s("fstate", {
    f(function(_, snip)
      local subject = pascal_case(snip.env.TM_FILENAME_BASE or "")
      if subject == "" then subject = "Subject" end
      return "const factory " .. subject .. "."
    end, {}), i(1, "stateName"), t("("), i(2), t(") = _"), f(function(args) return pascal_case(args[1][1]) end, {1}), t({";", ""}), i(3)
  }),
  s("fevent", {
    f(function(_, snip)
      local subject = pascal_case(snip.env.TM_FILENAME_BASE or "")
      if subject == "" then subject = "Subject" end
      return "const factory " .. subject .. "."
    end, {}), i(1, "eventName"), t("("), i(2), t(") = _"), f(function(args) return pascal_case(args[1][1]) end, {1}), t({";", ""}), i(3)
  }),
}



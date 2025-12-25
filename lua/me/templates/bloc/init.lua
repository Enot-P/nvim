local T = {}

local function to_snake_case(str)
  local s = str
  -- заменить все не-алфанум символы на подчёркивания
  s = s:gsub("[^%w]+", "_")
  -- вставить подчёркивание между aB → a_B
  s = s:gsub("(%l)(%u)", "%1_%2")
  -- разделить цифры и буквы по границам
  s = s:gsub("(%d)(%a)", "%1_%2")
  s = s:gsub("(%a)(%d)", "%1_%2")
  -- схлопнуть повторяющиеся и обрезать края
  s = s:gsub("_+", "_")
  s = s:gsub("^_+", ""):gsub("_+$", "")
  return s:lower()
end

function T.bloc_main(feature_name, class_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "import 'package:bloc/bloc.dart';",
    "import 'package:flutter/foundation.dart' show immutable;",
    "",
    "part '" .. name_snake .. "_event.dart';",
    "part '" .. name_snake .. "_state.dart';",
    "",
    "class " .. class_name .. "Bloc extends Bloc<" .. class_name .. "Event, " .. class_name .. "State> {",
    "  " .. class_name .. "Bloc() : super(" .. class_name .. "Initial()) {",
    "    on<" .. class_name .. "Event>((event, emit) {",
    "      // TODO: implement event handler",
    "    });",
    "  }",
    "}",
  }, "\n")
end

function T.bloc_event(class_name, feature_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "part of '" .. name_snake .. "_bloc.dart';",
    "",
    "@immutable",
    "sealed class " .. class_name .. "Event {}",
  }, "\n")
end

function T.bloc_state(class_name, feature_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "part of '" .. name_snake .. "_bloc.dart';",
    "",
    "@immutable",
    "sealed class " .. class_name .. "State {}",
    "",
    "final class " .. class_name .. "Initial extends " .. class_name .. "State {}",
  }, "\n")
end

function T.cubit_main(class_name)
  return table.concat({
    "import 'package:bloc/bloc.dart';",
    "import 'package:flutter/foundation.dart' show immutable;",
    "",
    "part '" .. to_snake_case(class_name) .. "_state.dart';",
    "",
    "class " .. class_name .. "Cubit extends Cubit<" .. class_name .. "State> {",
    "  " .. class_name .. "Cubit() : super(" .. class_name .. "Initial());",
    "}",
  }, "\n")
end

function T.cubit_state(class_name)
  return table.concat({
    "part of '" .. to_snake_case(class_name) .. "_cubit.dart';",
    "",
    "@immutable",
    "sealed class " .. class_name .. "State {}",
    "",
    "final class " .. class_name .. "Initial extends " .. class_name .. "State {}",
  }, "\n")
end

-- Freezed templates
function T.bloc_main_freezed(feature_name, class_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "import 'package:bloc/bloc.dart';",
    "import 'package:freezed_annotation/freezed_annotation.dart';",
    "",
    "part '" .. name_snake .. "_event.dart';",
    "part '" .. name_snake .. "_state.dart';",
    "part '" .. name_snake .. "_bloc.freezed.dart';",
    "",
    "class " .. class_name .. "Bloc extends Bloc<" .. class_name .. "Event, " .. class_name .. "State> {",
    "  " .. class_name .. "Bloc() : super(const " .. class_name .. "State.initial()) {",
    "    on<" .. class_name .. "Event>((event, emit) {",
    "      // TODO: implement event handler",
    "    });",
    "  }",
    "}",
  }, "\n")
end

function T.bloc_event_freezed(class_name, feature_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "part of '" .. name_snake .. "_bloc.dart';",
    "",
    "@freezed",
    "class " .. class_name .. "Event with _$" .. class_name .. "Event {",
    "  const factory " .. class_name .. "Event.started() = _" .. class_name .. "Started;",
    "}",
  }, "\n")
end

function T.bloc_state_freezed(class_name, feature_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "part of '" .. name_snake .. "_bloc.dart';",
    "",
    "@freezed",
    "class " .. class_name .. "State with _$" .. class_name .. "State {",
    "  const factory " .. class_name .. "State.initial() = _" .. class_name .. "Initial;",
    "  const factory " .. class_name .. "State.loading() = _" .. class_name .. "Loading;",
    "  const factory " .. class_name .. "State.loaded() = _" .. class_name .. "Loaded;",
    "  const factory " .. class_name .. "State.error(String message) = _" .. class_name .. "Error;",
    "}",
  }, "\n")
end

function T.cubit_main_freezed(class_name)
  return table.concat({
    "import 'package:bloc/bloc.dart';",
    "import 'package:freezed_annotation/freezed_annotation.dart';",
    "",
    "part '" .. to_snake_case(class_name) .. "_state.dart';",
    "part '" .. to_snake_case(class_name) .. "_cubit.freezed.dart';",
    "",
    "class " .. class_name .. "Cubit extends Cubit<" .. class_name .. "State> {",
    "  " .. class_name .. "Cubit() : super(const " .. class_name .. "State.initial());",
    "}",
  }, "\n")
end

function T.cubit_state_freezed(class_name)
  return table.concat({
    "part of '" .. to_snake_case(class_name) .. "_cubit.dart';",
    "",
    "@freezed",
    "class " .. class_name .. "State with _$" .. class_name .. "State {",
    "  const factory " .. class_name .. "State.initial() = _" .. class_name .. "Initial;",
    "  const factory " .. class_name .. "State.loading() = _" .. class_name .. "Loading;",
    "  const factory " .. class_name .. "State.loaded() = _" .. class_name .. "Loaded;",
    "  const factory " .. class_name .. "State.error(String message) = _" .. class_name .. "Error;",
    "}",
  }, "\n")
end

-- Equatable templates
function T.bloc_main_equatable(feature_name, class_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "import 'package:bloc/bloc.dart';",
    "import 'package:equatable/equatable.dart';",
    "",
    "part '" .. name_snake .. "_event.dart';",
    "part '" .. name_snake .. "_state.dart';",
    "",
    "class " .. class_name .. "Bloc extends Bloc<" .. class_name .. "Event, " .. class_name .. "State> {",
    "  " .. class_name .. "Bloc() : super(const " .. class_name .. "Initial()) {",
    "    on<" .. class_name .. "Event>((event, emit) {",
    "      // TODO: implement event handler",
    "    });",
    "  }",
    "}",
  }, "\n")
end

function T.bloc_event_equatable(class_name, feature_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "part of '" .. name_snake .. "_bloc.dart';",
    "",
    "abstract class " .. class_name .. "Event extends Equatable {",
    "  const " .. class_name .. "Event();",
    "",
    "  @override",
    "  List<Object> get props => [];",
    "}",
    "",
    "class " .. class_name .. "Started extends " .. class_name .. "Event {",
    "  const " .. class_name .. "Started();",
    "}",
  }, "\n")
end

function T.bloc_state_equatable(class_name, feature_name)
  local name_snake = to_snake_case(feature_name)
  return table.concat({
    "part of '" .. name_snake .. "_bloc.dart';",
    "",
    "abstract class " .. class_name .. "State extends Equatable {",
    "  const " .. class_name .. "State();",
    "",
    "  @override",
    "  List<Object> get props => [];",
    "}",
    "",
    "class " .. class_name .. "Initial extends " .. class_name .. "State {",
    "  const " .. class_name .. "Initial();",
    "}",
    "",
    "class " .. class_name .. "Loading extends " .. class_name .. "State {",
    "  const " .. class_name .. "Loading();",
    "}",
    "",
    "class " .. class_name .. "Loaded extends " .. class_name .. "State {",
    "  const " .. class_name .. "Loaded();",
    "}",
    "",
    "class " .. class_name .. "Error extends " .. class_name .. "State {",
    "  final String message;",
    "  const " .. class_name .. "Error(this.message);",
    "",
    "  @override",
    "  List<Object> get props => [message];",
    "}",
  }, "\n")
end

function T.cubit_main_equatable(class_name)
  return table.concat({
    "import 'package:bloc/bloc.dart';",
    "import 'package:equatable/equatable.dart';",
    "",
    "part '" .. to_snake_case(class_name) .. "_state.dart';",
    "",
    "class " .. class_name .. "Cubit extends Cubit<" .. class_name .. "State> {",
    "  " .. class_name .. "Cubit() : super(const " .. class_name .. "Initial());",
    "}",
  }, "\n")
end

function T.cubit_state_equatable(class_name)
  return table.concat({
    "part of '" .. to_snake_case(class_name) .. "_cubit.dart';",
    "",
    "abstract class " .. class_name .. "State extends Equatable {",
    "  const " .. class_name .. "State();",
    "",
    "  @override",
    "  List<Object> get props => [];",
    "}",
    "",
    "class " .. class_name .. "Initial extends " .. class_name .. "State {",
    "  const " .. class_name .. "Initial();",
    "}",
    "",
    "class " .. class_name .. "Loading extends " .. class_name .. "State {",
    "  const " .. class_name .. "Loading();",
    "}",
    "",
    "class " .. class_name .. "Loaded extends " .. class_name .. "State {",
    "  const " .. class_name .. "Loaded();",
    "}",
    "",
    "class " .. class_name .. "Error extends " .. class_name .. "State {",
    "  final String message;",
    "  const " .. class_name .. "Error(this.message);",
    "",
    "  @override",
    "  List<Object> get props => [message];",
    "}",
  }, "\n")
end

return T

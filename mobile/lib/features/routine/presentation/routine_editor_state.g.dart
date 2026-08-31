// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_editor_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutineEditorState _$RoutineEditorStateFromJson(Map<String, dynamic> json) =>
    _RoutineEditorState(
      routineId: json['routineId'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RoutineExercise>[],
      isSaving: json['isSaving'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$RoutineEditorStateToJson(_RoutineEditorState instance) =>
    <String, dynamic>{
      'routineId': instance.routineId,
      'name': instance.name,
      'description': instance.description,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'isSaving': instance.isSaving,
      'isSaved': instance.isSaved,
      'errorMessage': instance.errorMessage,
    };

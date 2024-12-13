// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      recipe: json['recipe'] as String,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'recipe': instance.recipe,
      'ingredients': instance.ingredients,
      'steps': instance.steps,
    };

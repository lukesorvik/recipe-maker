import 'package:json_annotation/json_annotation.dart';

// USED TO GENERATE AUTO GENERATED CODE
// See documentation here https://docs.flutter.dev/data-and-backend/serialization/json#creating-model-classes-the-json_serializable-way
// After changing this class, it is essential to run `dart run build_runner build --delete-conflicting-outputs` from the root of the project.

part 'response.g.dart';

// Class to represent the recipe response from Gemini Ai
// This class is used to parse the JSON response from the Gemini API
@JsonSerializable()
class Response {
  Response(
      {required this.recipe,
      this.ingredients = const [],
      this.steps = const []});

  final String recipe;
  final List<String> ingredients;
  final List<String> steps;

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseToJson(this);

  @override
  String toString() {
    return 'Response(recipe: $recipe, ingredients: $ingredients, steps: $steps)';
  }
}

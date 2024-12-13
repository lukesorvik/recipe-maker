import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:recipe_maker/models/response.dart';
import 'package:flutter/material.dart';

// Used to load environment variables (api key)
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Provider class for getting a recipe from the Gemini model
// Used to fetch a recipe from the Gemini model
// Stores the result in the _recipe field
// Stores the loading status in the _isLoading field
// Stores the error status in the _hasError field
class GeminiProvider extends ChangeNotifier {
  // Initializes to an empty recipe
  // Need to check _hasError to see if there was an error in generating recipe
  Response _recipe = Response(recipe: '', ingredients: [], steps: []);

  // Loading status
  // initialized to true
  // set to false when we have a recipe saved in provider
  bool _isLoading = true;

  // Error status
  // If error occurs then tell user to regenerate recipe
  bool _hasError = false;

  String CuisineType = '';
  String MealType = '';

  // Getters
  Response get recipe => _recipe;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  // Setter for cuisine type
  void setCuisineType(String cuisineType) {
    print('Cuisine Type: ' + cuisineType);
    CuisineType = cuisineType;
    notifyListeners();
  }

// Setter for meal type
  void setMealType(String mealType) {
    print('Meal Type: ' + mealType);
    MealType = mealType;
    notifyListeners();
  }

  // Fetches a recipe from the Gemini model
  // Sets _recipe to the generated recipe, _isLoading to false, and _hasError to false
  // If an error occurs, sets _hasError to true and _isLoading to false
  // Uses future void so we can do async operations
  //-------------------------------------------------
  // Parameters:
  // ingredients: a list of ingredients for the recipe
  // Named Optional Parameters (default optional unless specified required):
  // city: the city where the recipe is being generated (default is empty string)
  // country: the country where the recipe is being generated (default is empty string)

  Future<void> fetchGeminiRecipe(List<String> ingredients,
      {String city = '', String country = ''}) async {
    // Set loading status to true
    _isLoading = true;
    // set error status to false
    _hasError = false;

    // Load the .env file
    await dotenv.load(fileName: "APIKEY.env");

    // Get var from env file, could be null so check
    String? apiKey = dotenv.env['APIKEY'];

    // Check if the API key is null
    if (apiKey == null) {
      print('No \$API_KEY environment variable check if .env file is present');
      // Non zero = error code, exit the program, show error
      exit(1);
    }

    // If the city AND country was provided, add extra prompt to the request
    // else, extra prompt is empty
    final String extraPrompt = (city != '' && country != '')
        ? 'Make the recipe based on the local cuisine of $city, $country'
        : '';

    // Schema for the recipe response
    // Tells Gemini what the json response should look like
    final schema = Schema.object(
      description: 'Recipe response schema',
      properties: {
        'recipe': Schema.string(
          description: 'Name of the recipe.',
          nullable: false,
        ),
        'ingredients': Schema.array(
          description: 'List of ingredients.',
          items: Schema.string(
            description: 'An individual ingredient with quanity.',
            nullable: false,
          ),
        ),
        'steps': Schema.array(
          description: 'List of steps.',
          items: Schema.string(
            description: 'An individual step.',
            nullable: false,
          ),
        ),
      },
      requiredProperties: ['recipe'],
    );

    // Create the model
    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
            responseMimeType: 'application/json', responseSchema: schema));

    // Convert the list of ingredients to a string
    final ingredientPrompt = ingredients.toString();
    // Prompt for the Gemini model
    final prompt =
        'Give me a $CuisineType recipe for $MealType that uses any of the ingredients in this'
        ' list of any quantity, do not use all ingredients unless required: $ingredientPrompt  Generated recipe must not use any ingredients not in '
        'the ingredients list other than spices and water.  '
        ' $extraPrompt. Make the recipe in english.';
    // Debug print the prompt
    print('\n Prompt: ' + prompt);
    GenerateContentResponse response;

    try {
      response = await model.generateContent([Content.text(prompt)]);
      // Debug print the response from gemini
      print('\n Gemini Response : ' + response.text.toString());
    } catch (e) {
      print("Error generating content from Gemini: $e");
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return;
    }
    // Debug print the response from gemini
    print('\n Gemini Response : ' + response.text.toString());

    // Convert Gemini response to JSOn of Map<String, dynamic>
    // response.text ?? '' is used to handle null response.text
    final Map<String, dynamic> recipeJson;
    // Try to decode the JSON response, throw error if cannot (gemini response is not valid JSON)
    try {
      recipeJson = jsonDecode(response.text ?? '');
    } catch (e) {
      // Means there was an error decoding the JSON response
      print("Error decoding JSON response from Gemini");
      // Set error status to true
      // Means must regenerate recipe
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return;
    }
    // We have valid json yay!
    // Convert JSON to Response object using generated Response.fromJson method
    final Response recipe;
    try {
      recipe = Response.fromJson(recipeJson);
    } catch (e) {
      // Means there was an error converting the JSON to a Response object
      print("Error converting JSON to Response object");
      // Set error status to true
      // Means must regenerate recipe
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return;
    }
    // We have a valid recipe object yay!
    // Do not need to filter gemini response since we tested and it will always filter out dangerous recipes
    // Debug print the recipe
    print(recipe);

    // Check if any of the recipe fields are empty
    if (recipe.recipe.isEmpty ||
        recipe.ingredients.isEmpty ||
        recipe.steps.isEmpty) {
      // Set error status to true
      // Means must regenerate recipe
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return;
    }
    // Else no error, set error status to false
    else {
      _hasError = false;
      // Set loading status to false
      _isLoading = false;
      // Set local recipe to the generated recipe
      _recipe = recipe;
      // Tell listeners that the recipe has been updated
      notifyListeners();
    }
  }
}

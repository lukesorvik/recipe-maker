import 'package:flutter/material.dart';
import 'package:recipe_maker/models/ingredient_entry.dart';
import 'package:recipe_maker/providers/pantry_provider.dart';
import 'package:recipe_maker/providers/position_provider.dart';
import 'package:recipe_maker/views/main_view.dart';
import 'providers/gemini_recipe_provider.dart';
import 'package:provider/provider.dart';

// for isar
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // Make sure flutter is ready to interact with platform api's by ensuring binded
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([IngredientEntrySchema], directory: dir.path);

  // -----------------------------------------------
  // For Debugging providers && example usages (can be removed later)

  // final PositionProvider positionProvider = PositionProvider();
  // // Get gps location + city/country name using geocoding
  // // await is used to wait for the result of the async function
  // await positionProvider.updatePosition();
  // print('city country : ' +
  //     positionProvider.city +
  //     ' ' +
  //     positionProvider.country);
  // print('Latitude + Longitude : ' +
  //     positionProvider.latitude.toString() +
  //     ' ' +
  //     positionProvider.longitude.toString());
  // // Create a new instance of GeminiRecipeProvider

  // final recipeProvider = GeminiProvider();
  // recipeProvider.fetchGeminiRecipe(
  //     'dinner', ['eggs x2', 'bacon x4', 'flour x1 cup'],
  //     cuisineType: 'italian',
  //     city: positionProvider.city,
  //     country: positionProvider.country);

  // -----------------------------------------------
  // Run the app with 3 providers
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => PantryProvider(isar)),
      ChangeNotifierProvider(create: (context) => PositionProvider()),
      ChangeNotifierProvider(create: (context) => GeminiProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor that initializes isar

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Maker',
      home: const AllEntriesView(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'serif',
        //fontFamily: 'Roboto',
        primaryTextTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

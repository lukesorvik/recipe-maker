import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_maker/models/ingredient_entry.dart';
import 'package:recipe_maker/providers/gemini_recipe_provider.dart';
import 'package:recipe_maker/providers/pantry_provider.dart';
import 'package:recipe_maker/providers/position_provider.dart';
import 'package:recipe_maker/views/recipe_response.dart';

class AllEntriesView extends StatelessWidget {
  const AllEntriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the keyboard is open
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            toolbarHeight: 100,
            title: const Center(
              child: Text('Ingredients',
                  style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
            ),
            actions: <Widget>[
              IconButton(
                  iconSize: 48,
                  onPressed: () {
                    IngredientEntry entry =
                        IngredientEntry.fromText(text: '', quantity: 1);
                    print(entry.id);
                    // Add an entry when the button is pressed
                    PantryProvider provider =
                        Provider.of<PantryProvider>(context, listen: false);
                    provider.upsertPantryEntry(entry);
                  },
                  icon: const Icon(Icons.add),
                  splashColor: Theme.of(context).splashColor),
              IconButton(
                  iconSize: 48,
                  onPressed: () {
                    // Make this a clear button ////////////////////////////
                    Provider.of<PantryProvider>(context, listen: false).clear();
                  },
                  icon: const Icon(Icons.clear),
                  splashColor: Theme.of(context).splashColor),
            ]),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 10,
                // for each entry in the journal, create a list element
                // using the _createListElementForEntry method
                child: recipeListViewBuilder()),
            // If the user clicks on something to edit hide the generate buttons
            // since they get in the way
            if (!isKeyboardOpen) Spacer(flex: 1),
            if (!isKeyboardOpen) GenerateColumn(context),
            if (!isKeyboardOpen) Spacer(flex: 1),
          ],
        ));
  }

  Column GenerateColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BuildMealList(),
        const SizedBox(height: 10),
        BuildCuisineList(),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(minHeight: 45),
          child: ElevatedButton.icon(
            onPressed: () {
              _navigateToRecipeResponse(context);
            },
            icon: const Icon(Icons.food_bank, size: 25),
            label: const Text('Generate', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: BoxConstraints(minHeight: 45),
          child: ElevatedButton.icon(
            onPressed: () {
              _navigateToRecipeResponseLocation(context);
            },
            icon: const Icon(Icons.location_on, size: 25),
            label: const Text('Generate with Location',
                style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

// Builds the meal list for the user to select from
// updates gemini provider for when we generate
  Row BuildMealList() {
    List<String> meals = ['breakfast', 'lunch', 'dinner'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(meals.length, (index) {
        return Consumer<GeminiProvider>(
          builder: (context, geminiProvider, child) {
            bool isSelected = geminiProvider.MealType == meals[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.black,
                ),
                onPressed: () {
                  geminiProvider.setMealType(meals[index]);
                },
                child: Text(
                  meals[index],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          },
        );
      }),
    );
  }

// Builds the cuisine list for the user to select from
// updates gemini provider for when we generate
  SingleChildScrollView BuildCuisineList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) {
          // List of 10 cuisines : mexican, italian, chinese, indian, french, japanese, korean, thai, vietnamese, greek
          List<String> cuisines = [
            'mexican',
            'italian',
            'chinese',
            'indian',
            'french',
            'japanese',
            'korean',
            'thai',
            'vietnamese',
            'greek'
          ];
          return Consumer<GeminiProvider>(
            builder: (context, geminiProvider, child) {
              bool isSelected = geminiProvider.CuisineType == cuisines[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : Colors.black,
                  ),
                  onPressed: () {
                    geminiProvider.setCuisineType(cuisines[index]);
                  },
                  child: Text(
                    cuisines[index],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // create a ListView widget of all of the meal entries for the current date
  // @returns a List view widget
  Widget recipeListViewBuilder() {
    return Consumer<PantryProvider>(
      builder: (context, pantryProvider, child) {
        final entries = pantryProvider.getEntries();

        //return build the listview of cards with the entries
        return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) => _createListElementForEntry(
                context, entries[index], pantryProvider));
      },
    );
  }

// create a widget to be used in the list view
// @param context: the current context
// @param entry: the entry to create the list element for
// @returns a container widget with the list element
  Widget _createListElementForEntry(BuildContext context, IngredientEntry entry,
      PantryProvider pantryProvider) {
    final textController = TextEditingController.fromValue(
      TextEditingValue(
        text: entry.text,
        selection: TextSelection.collapsed(offset: entry.text.length),
      ),
    );

    final quantityController = TextEditingController.fromValue(
      TextEditingValue(
        text: entry.quantity.toString(),
        selection:
            TextSelection.collapsed(offset: entry.quantity.toString().length),
      ),
    );

    List<String> units = ['', 'cup', 'tbsp', 'tsp', 'oz', 'g', 'kg', 'ml', 'l'];

    return Dismissible(
      key: Key(entry.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        pantryProvider.removePantryEntry(entry);
      },
      child: ListTile(
        // name field
        title: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'insert a food',
            filled: false, // Set filled to false to remove grey background
          ),
          onChanged: (value) {
            pantryProvider.upsertPantryEntry(
                IngredientEntry.withUpdatedText(entry, value));
          },
          onEditingComplete: () {
            // Ensure the focus is removed when editing is done
            FocusScope.of(context).unfocus();
          },
        ),

        // edit quantity field
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                ),
                // if the quantity box is changed
                onChanged: (value) {
                  // if the box is now empty add 0 since cant store null
                  if (value.isEmpty) {
                    pantryProvider.upsertPantryEntry(
                        IngredientEntry.withUpdatedQuantity(entry, 0));
                  } else {
                    // they entered soemthing in the box
                    // check if int and greater than 0
                    final newQuantity = int.tryParse(value);
                    if (newQuantity != null && newQuantity >= 1) {
                      pantryProvider.upsertPantryEntry(
                          IngredientEntry.withUpdatedQuantity(
                              entry, newQuantity));
                    } else {
                      // reload text box with previous stored value since invalid value
                      pantryProvider.reload();
                    }
                  }
                },
                onEditingComplete: () {
                  // Ensure the focus is removed when editing is done
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              // use provider to get unit
              value: entry.unit,
              // if the dropdown is changed
              onChanged: (String? newValue) {
                if (newValue != null) {
                  pantryProvider.upsertPantryEntry(
                      IngredientEntry.withUpdatedUnit(entry, newValue));
                  // Update the entry with the selected unit if needed
                  // pantryProvider.upsertPantryEntry(
                  //     IngredientEntry.withUpdatedUnit(entry, selectedUnit));
                }
              },
              items: units.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // navigate to Response WITHOUT USING LOCATION
  // @param context: the current context
  // @returns a Future<void> to wait for the navigation to complete
  Future<void> _navigateToRecipeResponse(BuildContext context) async {
    GeminiProvider geminiProvider =
        Provider.of<GeminiProvider>(context, listen: false);
    PantryProvider pantryProvider =
        Provider.of<PantryProvider>(context, listen: false);

    // TODO: change to just navigate to RECIPE RESPONSE then call gemini there so can have loading symbol
    await geminiProvider.fetchGeminiRecipe(pantryProvider
        .getEntries()
        .map((entry) => '${entry.text} x ${entry.quantity} ${entry.unit}')
        .toList());

    //wait for the asynchroneous call to Navigator.push to return via pop then execute the code below
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecipeResponse(
                recipeName: geminiProvider.recipe.recipe,
                ingredients: geminiProvider.recipe.ingredients,
                directions: geminiProvider.recipe.steps)));

    if (!context.mounted) {
      //if the context is not mounted, we do not want to do anything
      //means that the widget is not in the widget tree
      // need to make sure that the widget is still in the widget tree
      //if it is not, we do not want to do anything
      //if current view is not in tree we do not want to update the state for the provider
      return;
    }
  }

  // navigate to Response WITHOUT USING LOCATION
  // @param context: the current context
  // @returns a Future<void> to wait for the navigation to complete
  Future<void> _navigateToRecipeResponseLocation(BuildContext context) async {
    GeminiProvider geminiProvider =
        Provider.of<GeminiProvider>(context, listen: false);
    PantryProvider pantryProvider =
        Provider.of<PantryProvider>(context, listen: false);

    PositionProvider positionProvider =
        Provider.of<PositionProvider>(context, listen: false);

    await positionProvider.updatePosition();
    print('city, country: ' +
        positionProvider.city +
        ' ' +
        positionProvider.country);

    // TODO: change to just navigate to RECIPE RESPONSE then call gemini there so can have loading symbol
    // Call with city and country from recipe provider
    await geminiProvider.fetchGeminiRecipe(
        pantryProvider
            .getEntries()
            .map((entry) => '${entry.text} x ${entry.quantity} ${entry.unit}')
            .toList(),
        city: positionProvider.city,
        country: positionProvider.country);

    //wait for the asynchroneous call to Navigator.push to return via pop then execute the code below
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecipeResponse(
                recipeName: geminiProvider.recipe.recipe,
                ingredients: geminiProvider.recipe.ingredients,
                directions: geminiProvider.recipe.steps)));

    if (!context.mounted) {
      //if the context is not mounted, we do not want to do anything
      //means that the widget is not in the widget tree
      // need to make sure that the widget is still in the widget tree
      //if it is not, we do not want to do anything
      //if current view is not in tree we do not want to update the state for the provider
      return;
    }
  }

  //TODO : Make a navigateTOResponseWITHLOCATION
}

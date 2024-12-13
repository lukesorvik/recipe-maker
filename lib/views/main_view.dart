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
                child: listViewBuilder()),
            Spacer(flex: 3)
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'generate',
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              onPressed: () {
                _navigateToRecipeResponse(context);
              },
              label: const Text('Generate'),
              icon: const Icon(Icons.food_bank, size: 25),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              heroTag: 'generate_with_location',
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              onPressed: () {
                _navigateToRecipeResponseLocation(context);
              },
              label: const Text('Generate with Location'),
              icon: const Icon(Icons.location_on, size: 25),
            ),
          ],
        ));
  }

  // create a ListView widget of all of the meal entries for the current date
  // @returns a List view widget
  Widget listViewBuilder() {
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
  // @param entry: the  entry to create the list element for
  // @returns a container widget with the list element
  Widget _createListElementForEntry(BuildContext context, IngredientEntry entry,
      PantryProvider pantryProvider) {
    return ListTile(
      // name field
      title: TextField(
        controller: TextEditingController(text: entry.text),
        decoration: const InputDecoration(
          hintText: 'insert a food',
          filled: false, // Set filled to false to remove grey background
        ),
        // TODO: figure out how to make it change without hitting "done" one keyboard
        // but also so it doesnt kick you out each time you type a letter
        onSubmitted: (value) => pantryProvider
            .upsertPantryEntry(IngredientEntry.withUpdatedText(entry, value)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // - button here
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              int newQuantity = entry.quantity - 1;
              if (newQuantity < 0) {
                return;
              }
              pantryProvider.upsertPantryEntry(
                  IngredientEntry.withUpdatedQuantity(
                      entry, entry.quantity - 1));
            },
          ),
          //quantity field
          SizedBox(
            width: 50,
            child: TextField(
              controller:
                  TextEditingController(text: entry.quantity.toString()),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              ),
              onSubmitted: (value) {
                final newQuantity = int.tryParse(value);
                if (newQuantity != null && newQuantity >= 0) {
                  pantryProvider.upsertPantryEntry(
                      IngredientEntry.withUpdatedQuantity(entry, newQuantity));
                } else {
                  // reload since invalid value
                  pantryProvider.reload();
                }
              },
            ),
          ),
          // + button here
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              pantryProvider.upsertPantryEntry(
                  IngredientEntry.withUpdatedQuantity(
                      entry, entry.quantity + 1));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              pantryProvider.removePantryEntry(entry);
            },
          )
        ],
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
    await geminiProvider.fetchGeminiRecipe(
        '',
        pantryProvider
            .getEntries()
            .map((entry) => '${entry.text} x ${entry.quantity}')
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
        '',
        pantryProvider
            .getEntries()
            .map((entry) => '${entry.text} x ${entry.quantity}')
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_maker/providers/gemini_recipe_provider.dart';

// TODO fix and clean this up
// - Use the gemini recipe Provider to call the gemini api here
// display loading text while waiting for response
// I made changes so it would run, dont know if it looks nice -luke
class RecipeResponse extends StatelessWidget {
  const RecipeResponse({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<GeminiProvider>(
        builder: (context, geminiProvider, child) {
          if (geminiProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // not loading
          else if (geminiProvider.hasError) {
            return const Center(
              child: Text('Error loading recipe. Please try again.'),
            );
          }
          // not loading and no error
          // have valid recipe
          else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        geminiProvider.recipe.recipe,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingredients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...geminiProvider.recipe.ingredients
                              .map((ingredient) => Text(
                                    ingredient,
                                    style: const TextStyle(fontSize: 16),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Directions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...geminiProvider.recipe.steps
                              .map((direction) => Text(
                                    direction,
                                    style: const TextStyle(fontSize: 16),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    // TODO: Get Regenerate button working

                    //  const SizedBox(height: 16),
                    //         Center(
                    //           child: ElevatedButton(
                    //             onPressed: () {},
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor: Colors.grey.shade300,
                    //             ),

                    //             child: const Text(
                    //               'Regenerate',
                    //               style: TextStyle(color: Colors.black),
                    //             ),
                    //           ),
                    //         ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

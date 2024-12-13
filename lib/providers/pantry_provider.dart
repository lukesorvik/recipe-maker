import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:recipe_maker/models/pantry.dart';
import 'package:recipe_maker/models/ingredient_entry.dart';

// Provider class for the pantry
// Used to add/remove an ingredient entry to the pantry
// Used to get a copy of the pantry to use to display the pantry
// specifically to get the list of ingredient entries
class PantryProvider extends ChangeNotifier {
  //instance of the isar database
  //used for dependency injection
  final Isar _isar;

  //declare late so we can initialize the final variable later in constructor
  late final Pantry _pantry;

  //constructor for the pantryProvider
  // @param isar: the isar database instance
  PantryProvider(Isar isar) : _isar = isar {
    //initialize isar using initialization list

    //initialize pantry using pantry constructor
    // pantrys constructor will populate the list of entries based on isar
    _pantry = Pantry(entries: [], isar: _isar);
  }

  // method to add a new journal entry to the list
  // if an entry with the same id already exists, it is replaced
  // else, the new entry is added to the list
  // calls to notify listeners
  void upsertPantryEntry(IngredientEntry entry) async {
    await _pantry.upsertEntry(entry); //upsert the entry
    notifyListeners(); //notify listeners to redraw
  }

  // method to remove a journal entry from the list
  // updates database to remove the entry (isar) using the entires id
  // calls to notify listeners  to redraw app
  void removePantryEntry(IngredientEntry entry) async {
    await _pantry.removeEntry(entry); //remove the entry
    notifyListeners(); //notify listeners to redraw
  }

  // Clears all entries from the pantry
  void clear() async {
    await _pantry.clear();
    notifyListeners();
  }

  // Gets entries from the provider
  // for some reason doing get pantry.entries was not working
  // Was causing some issue where the entries did not reflect what was actually there
  List<IngredientEntry> getEntries() {
    List<IngredientEntry> entries = _pantry.entries;
    //sort the entries by id, so entries that were created first are shown first
    entries.sort((entry1, entry2) {
      if (entry1.id == null && entry2.id == null) return 0;
      if (entry1.id == null) return -1; // Null IDs come first
      if (entry2.id == null) return 1;
      return entry1.id!.compareTo(entry2.id!);
    });

    return entries;
  }

  void reload() {
    notifyListeners();
  }
}

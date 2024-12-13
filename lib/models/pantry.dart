import 'package:isar/isar.dart';
import 'package:recipe_maker/models/ingredient_entry.dart';

class Pantry {
  // the list of ingredient entries, initialized as an empty list
  final List<IngredientEntry> _entries = [];

  //instance of the isar database
  final Isar _isar;

  // constructor for Pantry
  // @param entries: the list of ingredient entries to initialize the pantry with
  Pantry({required List<IngredientEntry> entries, required Isar isar})
      : _isar = isar {
    //use initalization list to set the isar instance

    //get all values in isar and make into a list
    //add each value to the list of ingredient entries _entries
    _isar.ingredientEntrys.where().findAllSync().forEach((element) {
      _entries.add(element);
    });
  }

  // getter for the list of ingredient entries
  // @returns a copy of the list of ingredient entries
  List<IngredientEntry> get entries =>
      List.from(_entries); // return a copy of the list

  // method to add a new ingredient entry to the list
  // if an entry with the same id already exists, it is replaced
  // else, the new entry is added to the list
  // @param entry: the ingredient entry to add
  Future<void> upsertEntry(IngredientEntry entry) async {
    _entries.removeWhere((e) =>
        e.id == entry.id); //remove the entry with the same id if it exists
    _entries.add(entry); //add the new entry

    //asynchronously write the entry to the isar database
    //this is done in a transaction to ensure that the write is asynchoronous
    //.put inserts or updates the entry if it exists
    //https://isar.dev/crud.html#modifying-the-database
    await _isar.writeTxn(() async {
      //isar will generate an id if the ID? is null or ISar.autoIncrement
      await _isar.ingredientEntrys.put(entry); // insert & update
    });
  }

  // method to remove a ingredient entry from the list
  // updates database to remove the entry (isar) using the entires id
  // @param entry: the ingredient entry to remove
  Future<void> removeEntry(IngredientEntry entry) async {
    //remove the entry from the list locally
    _entries.removeWhere((e) => e.id == entry.id);
    //remove the entry from the database
    await _isar.writeTxn(() async {
      //make sure the entry has an id before deleting
      if (entry.id != null) {
        await _isar.ingredientEntrys.delete(entry.id!); //delete the entry
      }
    });
  }

  // clone a Pantry object
  // @returns a new Pantry object with the same entries as the original
  Pantry clone() {
    return Pantry(
        entries: _entries,
        isar: _isar); //call the constructor with the current Pantry's fields
  }

  Future<void> clear() async {
    // get list of id's from the entries
    final List<int> ids = _entries.map((e) => e.id?.toInt() ?? 0).toList();

    // delete all entries that match id's in our entries
    await _isar.writeTxn(() async {
      await _isar.ingredientEntrys.deleteAll(ids);
    });
    // clear the list of entries
    _entries.clear();
  }
}

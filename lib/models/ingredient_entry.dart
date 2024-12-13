import 'package:isar/isar.dart';

// Part is the auto generated file
// run `flutter pub run build_runner build` to generate the file
part 'ingredient_entry.g.dart';

@Collection()
class IngredientEntry {
  // the id of the ingredient entry
  // use isar autoincrement to generate the id
  // https://isar.dev/schema.html#anatomy-of-a-collection
  Id? id;

  // the text of the ingredient entry
  final String text;

  // the quantity of the ingredient entry
  final int quantity;

  // the measurement unit of the ingredient entry
  final String unit;

  // factory constructor that creates a new IngredientEntry object from a text string
  // @param text: the text of the ingredient entry, default value is an empty string. optional named parameter
  // @param quantity: the quantity of the ingredient entry, default value is 0. optional named parameter
  // @param unit: the unit of the ingredient entry, default value is an '' SINCE IT HAS TO BE A VALUE PRESENT IN THE DROPDOWN MENU LIST OR ERROR
  //optional named parameter
  // @return a new IngredientEntry object
  factory IngredientEntry.fromText(
      {String text = '', int quantity = 0, unit = ''}) {
    return IngredientEntry(
        text: text,
        quantity: quantity,
        id: Isar.autoIncrement,
        unit: unit); // increment the new id
  }

  // constructor for IngredientEntry
  // @param text: the text of the ingredient entry
  // @param quantity: the quantity of the ingredient entry
  // @param id: the id of the ingredient entry, optional so that isar can generate the id for us
  IngredientEntry(
      {required this.text,
      required this.quantity,
      this.id,
      required this.unit});

  // method to update the text of an ingredient entry
  // @param entry: the ingredient entry to update
  // @param newText: the new text to replace the old text
  // @return a new IngredientEntry object with the updated text
  IngredientEntry.withUpdatedText(IngredientEntry entry, String newText)
      : id = entry.id,
        text = newText,
        quantity = entry.quantity,
        unit = entry.unit;

  // method to update the quantity of an ingredient entry
  // @param entry: the ingredient entry to update
  // @param newQuantity: the new quantity to replace the old quantity
  // @return a new IngredientEntry object with the updated quantity
  IngredientEntry.withUpdatedQuantity(IngredientEntry entry, int newQuantity)
      : id = entry.id,
        text = entry.text,
        quantity = newQuantity,
        unit = entry.unit;

  // with updated unit
  // method to update the unit of an ingredient entry
  // @param entry: the ingredient entry to update
  // @param newUnit: the new unit to replace the old unit
  // @return a new IngredientEntry object with the updated unit
  IngredientEntry.withUpdatedUnit(IngredientEntry entry, String newUnit)
      : id = entry.id,
        text = entry.text,
        quantity = entry.quantity,
        unit = newUnit;

  // method to update both the text and quantity of an ingredient entry
  // @param entry: the ingredient entry to update
  // @param newText: the new text to replace the old text
  // @param newQuantity: the new quantity to replace the old quantity
  // @return a new IngredientEntry object with the updated text and quantity
  IngredientEntry.withUpdatedTextAndQuantity(
      IngredientEntry entry, String newText, int newQuantity)
      : id = entry.id,
        text = newText,
        quantity = newQuantity,
        unit = entry.unit;
}

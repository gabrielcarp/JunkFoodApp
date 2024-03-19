import 'package:userapp/model/dish_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DishOfTheDayModel extends ChangeNotifier {
  final SupabaseClient database;
  DishOfTheDayModel({required this.database});
  List<DishModel> _dishOfTheDay = [];

  Future<void> fetchDishOfTheDay() async {
    Future.microtask(() async {
      var response = await database
          .from("Dish_Schedule")
          .select()
          .filter("date", "eq", DateTime.now().toIso8601String());
      if (response.isNotEmpty) {
        var dishOfTheDay = await database
            .from("Dishes")
            .select()
            .filter("id", "eq", response[0]["id"]);
        _dishOfTheDay = [DishModel.fromJson(dishOfTheDay[0])];
      } else {
        _dishOfTheDay = List.empty();
      }
      notifyListeners();
    });
  }

  List<DishModel> get dishOfTheDay {
    if (_dishOfTheDay.isNotEmpty) {
      return _dishOfTheDay;
    } else {
      return [DishModel(title: "There is no dish of the day")];
    }
  }

  Future<bool> get hasDishOfTheDay async {
    // await fetchDishOfTheDay();

    //THIS IS FOR LOCAL TESTING
    if (_dishOfTheDay.isEmpty) {
      _dishOfTheDay.add(DishModel(
        title: 'Test MainCourse',
        description: 'Test Description',
        calories: 200,
        imageUrl:
            'https://voresmad.dk/-/media/voresmad/recipes/f/flaeskesteg-af-svinekam-med-sproedt-svaer-og-traditionelt-tilbehoer2.jpg',
      ));
      _dishOfTheDay.add(DishModel(
        title: 'Test Dessert',
        description: 'Test Description',
        calories: 5000,
        imageUrl:
            'https://miro.medium.com/v2/resize:fit:1400/format:webp/1*9Lhb5e44WqRdM50iJ1T-XA.jpeg',
      ));
    }
    return _dishOfTheDay.isNotEmpty;
  }

  Future<int> postDishOfTheDay(
      String title, String description, int calories, String imageUrl) async {
    DishModel newDish = DishModel(
        title: title,
        description: description,
        calories: calories,
        imageUrl: imageUrl);
    var row = await database.from("Dishes").insert(newDish).select("id");
    var id = row[0]['id'];
    await database.from("Dish_Schedule").insert(
        {'id': id, 'date': DateTime.now().toIso8601String()}).select("id");
    return id;
  }
}

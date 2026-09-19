import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'overviewScreen.dart';

// Fetch all groups from the backend API.
Future<List<Group>> fetchGroups() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/groups'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    List<Group> groups = jsonResponse.map((data) => Group.fromJson(data)).toList();

    for (var group in groups) {
      print('Group ID: ${group.id}');
      print('Group Name: ${group.name}');
      print('Group Color: ${group.color}');
      print('Group Coins: ${group.coins}');
      print('Stable Level: ${group.stable.level}');
      print('Trainer Level: ${group.trainer.level}');
      print('---');
    }
    return groups;
  } else {
    throw Exception('Failed to load groups');
  }
}

// Fetch a single group by its identifier.
Future<Group> fetchGroupById(int groupId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/groups/$groupId'));

  if (response.statusCode == 200) {
    return Group.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load group');
  }
}

// Raise the stable level for the selected group.
Future<bool> levelUpStable(int groupId) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/stable/level-up');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to level up stable: ${response.body}");
    return false;
  }
}

// Raise the trainer level for the selected group.
Future<bool> levelUpTrainer(int groupId) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/trainer/level-up');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to level up trainer: ${response.body}");
    return false;
  }
}

// Create a new group in the backend.
Future<void> addGroup(String color, String name) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'color': color,
      'name': name,
    }),
  );

  if (response.statusCode == 200) {
    print('Group added successfully');
  } else {
    print('Failed to add group: ${response.body}');
  }
}

// Delete an existing group by ID.
Future<void> deleteGroup(int id) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$id');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('Group deleted successfully');
  } else {
    print('Failed to delete group: ${response.body}');
  }
}

// Add coins to the selected group's resource balance.
Future<void> addCoins(int groupId, int coinAmount) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/resources');
  try {
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coins': coinAmount,
      }),
    );

    if (response.statusCode == 200) {
      print('Coins added successfully');
    } else {
      print('Failed to add coins. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error adding coins: $e');
  }
}

// Buy water and wheat for the selected group.
Future<bool> buyResources(int groupId, int resourceAmount) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/buy-items');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'water': resourceAmount,
        'wheat': resourceAmount,
      }),
    );

    if (response.statusCode == 200) {
      print('Resources bought successfully');
      return true;
    } else {
      print('Failed to buy resources. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error buying resources: $e');
    return false;
  }
}

// Fetch all standings for the selected group.
Future<List<Standing>> fetchStandings(int groupId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/standings'));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    List<Standing> standings = jsonResponse.map((data) => Standing.fromJson(data)).toList();
    return standings;
  } else {
    throw Exception('Failed to load standings');
  }
}

// Raise the level of a standing.
Future<bool> levelUpStanding(int groupId, int standingId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/level-up');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to level up standing: ${response.body}");
    return false;
  }
}

// Insert a new horse into a standing.
Future<bool> insertHorse(int groupId, int standingId, int level,
    String name, int price_buy, String gender) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/horse');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'level': level,
      'name': name,
      'price_buy': price_buy,
      'gender': gender,
      'img_path': 'assets/horse.png',
      'food_per_day': 6,
      'water_per_day': 6,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to insert horse: ${response.body}");
    return false;
  }
}

// Start horse training for the selected standing.
Future<bool> levelUpHorse(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/train-horse');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to level up horse: ${response.body}");
    return false;
  }
}

// Release a horse from the selected standing.
Future<bool> releaseHorse(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/release-horse');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to release horse: ${response.body}");
    return false;
  }
}

// Sell a horse from the selected standing.
Future<bool> sellHorse(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/sell-horse');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to sell horse: ${response.body}");
    return false;
  }
}

// Feed wheat and water to a horse in the selected standing.
Future<bool> feedHorse(int groupId, int standingId, int wheat, int water) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/feed-horse');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'wheat': wheat,
      'water': water,
    }),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to feed horse: ${response.body}");
    return false;
  }
}

// Add a horse definition to the shop catalogue.
Future<bool> addHorseToShop(int level, String name, int priceBuy, String gender) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/shop');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'level': level,
      'name': name,
      'price_buy': priceBuy,
      'gender': gender,
      'img_path': "imgPath",
      'water_per_day': 6,
      'food_per_day': 6,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Failed to add horse to shop: ${response.body}");
    return false;
  }
}

// Fetch all available horse listings from the shop.
Future<List<ShopItem>> fetchShopItems() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/shop'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => ShopItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load shop items');
  }
}

// Buy a horse from the shop and place it into a standing.
Future<bool> buyHorseFromShop(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
    'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/horse-from-shop/$horseId',
  );

  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 404) {
    throw Exception('Horse not found');
  } else {
    throw Exception('Failed to buy horse');
  }
}

// Remove a horse definition from the shop catalogue.
Future<bool> deleteHorseFromShop(int horseId) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/shop/$horseId');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 404) {
    throw Exception('Horse not found');
  } else {
    throw Exception('Failed to delete horse');
  }
}

// Fetch the duplicate chance for a mating pair.
Future<DuplicateChance> getDuplicatingChance(int level1, int level2) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:5000/api/duplicating-chance/$level1/$level2'),
  );

  if (response.statusCode == 200) {
    return DuplicateChance.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load duplicating chance');
  }
}

class DuplicateChance {
  final String gender;
  final int level;

  DuplicateChance({required this.gender, required this.level});

  factory DuplicateChance.fromJson(Map<String, dynamic> json) {
    return DuplicateChance(
      gender: json['gender'],
      level: json['level'],
    );
  }
}

// Group data returned by the backend API.
class Group {
  int id;
  String name;
  String color;
  int coins;
  int water;
  int wheat;
  Stable stable;
  Trainer trainer;

  Group({
    required this.id,
    required this.name,
    required this.color,
    required this.coins,
    this.water = 0,
    this.wheat = 0,
    required this.stable,
    required this.trainer,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      coins: json['coins'],
      water: json['water'] ?? 0,
      wheat: json['wheat'] ?? 0,
      stable: Stable.fromJson(json['stable']),
      trainer: Trainer.fromJson(json['trainer']),
    );
  }
}

class Stable {
  int level;
  int level_up_cost;
  int number_of_full_standings;
  int number_of_standings;

  Stable({
    required this.level,
    required this.level_up_cost,
    required this.number_of_full_standings,
    required this.number_of_standings,
  });

  factory Stable.fromJson(Map<String, dynamic> json) {
    return Stable(
      level: json['level'],
      level_up_cost: json['level_up_price'] ?? 0,
      number_of_full_standings: json['number_of_full_standings'],
      number_of_standings: json['number_of_standings'],
    );
  }
}

class Standing {
  int id;
  int level;
  int level_up_price;
  int max_level_of_horse;
  int max_level_of_standing;
  Horse? horse;

  Standing({
    required this.id,
    required this.level,
    required this.level_up_price,
    required this.max_level_of_horse,
    required this.max_level_of_standing,
    this.horse,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      id: json['id'],
      level: json['level'],
      level_up_price: (json['level_up_price'] as num).toInt(),
      max_level_of_horse: (json['max_level_of_horse'] as num).toInt(),
      max_level_of_standing: (json['max_level_of_standing'] as num).toInt(),
      horse: json['horse'] != null ? Horse.fromJson(json['horse']) : null,
    );
  }
}

class Trainer {
  int level;
  int level_up_cost;
  int number_of_trained_horses;

  Trainer({
    required this.level,
    required this.level_up_cost,
    required this.number_of_trained_horses,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      level: json['level'],
      level_up_cost: json['level_up_price'] ?? 0,
      number_of_trained_horses: json['trained_today'] ?? 0,
    );
  }
}

class ShopItem {
  int id;
  String name;
  dynamic level;
  String gender;
  String img_path;
  dynamic price_buy;
  dynamic price_sell;
  dynamic food_per_day;
  dynamic water_per_day;
  dynamic food_eaten;
  dynamic water_drunk;

  ShopItem({
    required this.id,
    required this.name,
    required this.level,
    required this.gender,
    required this.img_path,
    required this.price_buy,
    required this.price_sell,
    required this.food_per_day,
    required this.water_per_day,
    required this.food_eaten,
    required this.water_drunk,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'] ?? '',
      level: json['level'],
      gender: json['gender'] ?? '',
      img_path: json['img_path'] ?? '',
      price_buy: json['price_buy'],
      price_sell: json['price_sell'],
      food_per_day: json['food_per_day'],
      water_per_day: json['water_per_day'],
      food_eaten: json['food_eaten'],
      water_drunk: json['water_drunk'],
    );
  }
}

class Horse {
  int id;
  String name;
  dynamic level;
  String gender;
  String img_path;
  dynamic price_buy;
  dynamic price_sell;
  dynamic food_per_day;
  dynamic water_per_day;
  dynamic food_eaten;
  dynamic water_drunk;

  Horse({
    required this.id,
    required this.name,
    required this.level,
    required this.gender,
    required this.img_path,
    required this.price_buy,
    required this.price_sell,
    required this.food_per_day,
    required this.water_per_day,
    required this.food_eaten,
    required this.water_drunk,
  });

  factory Horse.fromJson(Map<String, dynamic> json) {
    return Horse(
      id: _safeParseInt(json['id']),
      name: json['name'] ?? '',
      level: _safeParseInt(json['level']),
      gender: json['gender'] ?? '',
      img_path: json['img_path'] ?? '',
      price_buy: _safeParseInt(json['price_buy']),
      price_sell: _safeParseInt(json['price_sell']),
      food_per_day: _safeParseInt(json['food_per_day']),
      water_per_day: _safeParseInt(json['water_per_day']),
      food_eaten: _safeParseInt(json['food_eaten']),
      water_drunk: _safeParseInt(json['water_drunk']),
    );
  }

  // Safely convert backend values to integer values.
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

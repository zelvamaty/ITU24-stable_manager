import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'overviewScreen.dart';

//api request to get groups
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

//api request fetch group by id
Future<Group> fetchGroupById(int groupId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/groups/$groupId'));

  if (response.statusCode == 200) {
    return Group.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load group');
  }
}

//api post to level up stable
Future<bool> levelUpStable(int groupId) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/stable/level-up');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to level up stable: ${response.body}");
    return false; // Level up failed
  }
}

//api post to level up trainer
Future<bool> levelUpTrainer(int groupId) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$groupId/trainer/level-up');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to level up stable: ${response.body}");
    return false; // Level up failed
  }
}

//api POST request to add group
Future<void> addGroup(String color, String name) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups'); // Use 127.0.0.1 on a real device

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

//api DELETE request to delete group
Future<void> deleteGroup(int id) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/groups/$id'); // Update IP as needed

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('Group deleted successfully');
  } else {
    print('Failed to delete group: ${response.body}');
  }
}

//api PATCH request to add coins
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

//api POST request to buy water and wheat
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

//api GET request to get standings
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

//api POST request to level up standing
Future<bool> levelUpStanding(int groupId, int standingId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/level-up');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to level up standing: ${response.body}");
    return false; // Level up failed
  }
}

//api POST request to insert horse http://localhost:5000/api/groups/0/standings/0/horse
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
      'gender' : gender,
      'img_path': 'assets/horse.png',
      'food_per_day': 6,
      'water_per_day': 6,
    }),
  );
  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to insert horse: ${response.body}");
    return false; // Level up failed
  }
}



//api POST request to train horse
Future<bool> levelUpHorse(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/train-horse');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to level up horse: ${response.body}");
    return false; // Level up failed
  }
}

//api POST request to release horse /api/groups/<id>/standings/<standing_id>/release-horse
Future<bool> releaseHorse(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/release-horse');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to release horse: ${response.body}");
    return false; // Level up failed
  }
}

//api POST request to sell horse /api/groups/<id>/standings/<standing_id>/sell-horse
Future<bool> sellHorse(int groupId, int standingId, int horseId) async {
  final url = Uri.parse(
      'http://10.0.2.2:5000/api/groups/$groupId/standings/$standingId/sell-horse');
  final response = await http.post(url);

  if (response.statusCode == 200) {
    return true; // Successful level up
  } else {
    print("Failed to sell horse: ${response.body}");
    return false; // Level up failed
  }
}

//api request to feed horse app.route('/api/groups/<id>/standings/<standing_id>/feed-horse', methods=['POST'])
// def standing_feed_horse(id, standing_id):
//     data = request.json
//     response = model.standing_feed_horse(
//         int(id),
//         int(standing_id),
//         int(data['wheat']),
//         int(data['water']),
//         )

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
    return true; // Successful level up
  } else {
    print("Failed to feed horse: ${response.body}");
    return false; // Level up failed
  }
}

// api POST request to insert horse to shop
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
    return true; // Successful addition
  } else {
    print("Failed to add horse to shop: ${response.body}");
    return false; // Addition failed
  }
}

//api request to fetch shop items
Future<List<ShopItem>> fetchShopItems() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/shop'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => ShopItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load shop items');
  }
}

//api request to buy horse from shop
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

//api request to delete horse from shop
Future<bool> deleteHorseFromShop(int horseId) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/shop/$horseId');

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return true; // Successful deletion
  } else if (response.statusCode == 404) {
    throw Exception('Horse not found');
  } else {
    throw Exception('Failed to delete horse');
  }
}

//api request to calculate mating stuff
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





//class to hold the group data
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
  // void _navigateToOverviewScreen(BuildContext context, Group group) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => OverviewScreen(group: group),
  //     ),
  //   );
  // }
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
        number_of_standings: json['number_of_standings']


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

  // Helper method to safely parse to int
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
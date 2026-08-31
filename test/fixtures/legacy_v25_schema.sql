PRAGMA user_version = 25;

CREATE TABLE Goals(id INTEGER PRIMARY KEY AUTOINCREMENT, daily_calories INTEGER NOT NULL, carb_percentage INTEGER NOT NULL, protein_percentage INTEGER NOT NULL, fat_percentage INTEGER NOT NULL, sugar_percentage INTEGER NOT NULL, auto_calorie_mode INTEGER NOT NULL DEFAULT 0, custom_percent_per_month REAL NOT NULL DEFAULT 1.0, use_custom_start_calories INTEGER NOT NULL DEFAULT 0, user_start_calories INTEGER NOT NULL DEFAULT 2000, user_age INTEGER NOT NULL DEFAULT 30, user_activity_level REAL NOT NULL DEFAULT 1.3, last_monday_check TEXT, first_week_initialized INTEGER NOT NULL DEFAULT 0, user_height REAL NOT NULL DEFAULT 170, use_protein_per_kg INTEGER NOT NULL DEFAULT 0, protein_per_kg REAL NOT NULL DEFAULT 2.0, target_weight REAL, target_date TEXT, target_weekly_change REAL);
CREATE TABLE ConsumedFoods(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, meal_name TEXT NOT NULL, food_id INTEGER NOT NULL, quantity INTEGER NOT NULL);
CREATE TABLE SavedMeals(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, default_meal_name TEXT NOT NULL, created_at TEXT NOT NULL, recipe_total_weight INTEGER);
CREATE TABLE SavedMealIngredients(id INTEGER PRIMARY KEY AUTOINCREMENT, saved_meal_id INTEGER NOT NULL, food_id INTEGER NOT NULL, quantity INTEGER NOT NULL, FOREIGN KEY(saved_meal_id) REFERENCES SavedMeals(id) ON DELETE CASCADE);
CREATE TABLE FavoriteFoods(food_id INTEGER PRIMARY KEY, created_at TEXT NOT NULL);
CREATE TABLE FoodUsage(food_id INTEGER PRIMARY KEY, last_used_quantity INTEGER NOT NULL, last_used_at TEXT NOT NULL, use_count INTEGER NOT NULL DEFAULT 0);
CREATE TABLE OfflineQueue(id INTEGER PRIMARY KEY AUTOINCREMENT, action_type TEXT NOT NULL, payload TEXT NOT NULL, created_at TEXT NOT NULL, last_error TEXT);
CREATE TABLE LocalFoods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, brand TEXT NOT NULL, barcode TEXT, calories_per_100g INTEGER NOT NULL, fat_per_100g REAL NOT NULL, carbs_per_100g REAL NOT NULL, sugar_per_100g REAL NOT NULL, protein_per_100g REAL NOT NULL, created_at TEXT NOT NULL, last_used_quantity INTEGER NOT NULL DEFAULT 100, source TEXT NOT NULL DEFAULT "ai", is_verified INTEGER NOT NULL DEFAULT 0);
CREATE TABLE Settings(id INTEGER PRIMARY KEY AUTOINCREMENT, dark_mode INTEGER NOT NULL DEFAULT 0, reminder_weigh_enabled INTEGER NOT NULL DEFAULT 0, reminder_weigh_time TEXT NOT NULL DEFAULT '08:00', reminder_weigh_time2 TEXT NOT NULL DEFAULT '09:00', reminder_supplement_enabled INTEGER NOT NULL DEFAULT 0, reminder_supplement_time TEXT NOT NULL DEFAULT '10:00', reminder_supplement_time2 TEXT NOT NULL DEFAULT '11:00', reminder_meals_enabled INTEGER NOT NULL DEFAULT 0, reminder_breakfast TEXT NOT NULL DEFAULT '07:00', reminder_lunch TEXT NOT NULL DEFAULT '12:30', reminder_dinner TEXT NOT NULL DEFAULT '19:00');
CREATE TABLE WeightEntries(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, weight REAL NOT NULL);

INSERT INTO Goals(id, daily_calories, carb_percentage, protein_percentage, fat_percentage, sugar_percentage) VALUES (1, 2100, 45, 30, 25, 20);
INSERT INTO Settings(id, dark_mode) VALUES (1, 1);
INSERT INTO LocalFoods(id, name, brand, barcode, calories_per_100g, fat_per_100g, carbs_per_100g, sugar_per_100g, protein_per_100g, created_at, source, is_verified) VALUES (42, 'Haferflocken', 'Fixture', 'abc-123', 370, 7, 60, 1.2, 13, '2026-08-01T08:00:00.000Z', 'ai', 1);
INSERT INTO ConsumedFoods(id, date, meal_name, food_id, quantity) VALUES (7, '2026-08-31T00:00:00.000', 'Frühstück', 42, 125);
INSERT INTO WeightEntries(id, date, weight) VALUES (5, '2026-08-31T00:00:00.000', 78.4);
INSERT INTO SavedMeals(id, name, default_meal_name, created_at, recipe_total_weight) VALUES (3, 'Porridge', 'Frühstück', '2026-08-31T10:15:30.000Z', 250);
INSERT INTO SavedMealIngredients(id, saved_meal_id, food_id, quantity) VALUES (4, 3, 42, 125);
INSERT INTO FavoriteFoods(food_id, created_at) VALUES (42, '2026-08-31T10:15:30.000Z');
INSERT INTO FoodUsage(food_id, last_used_quantity, last_used_at, use_count) VALUES (42, 125, '2026-08-31T10:15:30.000Z', 2);
INSERT INTO OfflineQueue(id, action_type, payload, created_at) VALUES (9, 'food_upsert', '{"name":"Fixture"}', '2026-08-31T10:15:30.000Z');

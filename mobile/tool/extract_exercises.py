import re
import json

sql_path = 'backend/src/main/resources/db/migration/V8__seed_exercises.sql'
with open(sql_path, 'r', encoding='utf-8') as f:
    sql = f.read()

# Parse exercises
ex_part = sql.split('INSERT INTO exercise_muscle_groups')[0]
pattern = re.compile(r"\('([a-f0-9\-]+)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'([A-Z_]+)',\s*'([A-Z_]+)',\s*(FALSE|TRUE)\)")
ex_matches = pattern.findall(ex_part)

exercises = {}
for ex_id, name, desc, cat, eq, custom in ex_matches:
    exercises[ex_id] = {
        'id': ex_id,
        'name': name.replace("''", "'"),
        'description': desc.replace("''", "'"),
        'category': cat,
        'equipment': eq,
        'isCustom': custom.upper() == 'TRUE',
        'muscleGroups': []
    }

# Parse exercise_muscle_groups
mg_part = sql.split('INSERT INTO exercise_muscle_groups')[1]
mg_pattern = re.compile(r"\('([a-f0-9\-]+)',\s*'([a-f0-9\-]+)',\s*'([a-f0-9\-]+)',\s*'([A-Z]+)'\)")
mg_matches = mg_pattern.findall(mg_part)

for link_id, ex_id, mg_id, role in mg_matches:
    if ex_id in exercises:
        exercises[ex_id]['muscleGroups'].append({
            'muscleGroupId': mg_id,
            'role': role
        })

ex_list = list(exercises.values())
print(f'Parsed {len(ex_list)} exercises')
with open('mobile/assets/data/exercises.json', 'w', encoding='utf-8') as f:
    json.dump(ex_list, f, indent=2)


import json

input_file_path = '/Users/happinessncube/Documents/code/local_game/assets/resources/proccessed_word_groups.json'
output_file_path = '/Users/happinessncube/Documents/code/local_game/assets/resources/processed_word_groups_filtered.json'

def filter_long_words(data):
    filtered_data = []
    for word_group in data:
        new_group = [word for word in word_group if len(word) <= 7]
        if new_group:
            filtered_data.append(new_group)
    return filtered_data

with open(input_file_path, 'r') as f:
    word_groups = json.load(f)

filtered_words = filter_long_words(word_groups)

with open(output_file_path, 'w') as f:
    json.dump(filtered_words, f, indent=2)

print(f"Filtered {len(word_groups) - len(filtered_words)} groups with long words.")
print(f"Saved filtered data to {output_file_path}")

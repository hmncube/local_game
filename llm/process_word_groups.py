import os
import json
import random

def process_word_groups():
    """
    Reads word_groups.json, breaks down large groups, shuffles sub-words,
    and creates a new flat list format for the game levels.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_file_path = os.path.join(script_dir, 'word_groups.json')
    output_file_path = os.path.join(script_dir, 'game_levels.json')

    try:
        with open(input_file_path, 'r', encoding='utf-8') as f:
            word_groups = json.load(f)
    except FileNotFoundError:
        print(f"Error: Input file not found at {input_file_path}")
        print("Please run generate_word_groups.py first.")
        return

    game_levels = []
    chunk_size = 3

    for group in word_groups:
        main_word = group['main_word']
        sub_words = group['sub_words']

        # Shuffle the sub-words to mix up their lengths and order
        random.shuffle(sub_words)

        # Break the list of sub-words into chunks of 3
        for i in range(0, len(sub_words), chunk_size):
            chunk = sub_words[i:i + chunk_size]
            # We only want full groups of 3 sub-words for consistency
            if len(chunk) == chunk_size:
                # Create the new flat list format: [main_word, sub1, sub2, sub3]
                game_levels.append([main_word] + chunk)

    try:
        with open(output_file_path, 'w', encoding='utf-8') as f:
            json.dump(game_levels, f, ensure_ascii=False, indent=2)
        print(f"Successfully processed and created {len(game_levels)} game levels.")
        print(f"Output saved to {output_file_path}")
    except IOError as e:
        print(f"Error writing to JSON file: {e}")

if __name__ == "__main__":
    process_word_groups()

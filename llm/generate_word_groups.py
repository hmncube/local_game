import os
import json
from collections import Counter

def can_form_word(word, main_word_counter):
    """Checks if a word can be formed from the letters in main_word_counter."""
    word_counter = Counter(word)
    # Check if every character in the word is present in the main word's counter
    # with a sufficient count.
    for char, count in word_counter.items():
        if main_word_counter[char] < count:
            return False
    return True

def generate_word_groups():
    """
    Reads words, groups them into a main word and sub-words,
    and saves them to a JSON file.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    words_file_path = os.path.join(script_dir, 'shona_words.txt')
    output_file_path = os.path.join(script_dir, 'word_groups.json')

    try:
        with open(words_file_path, 'r', encoding='utf-8') as f:
            # Read words and filter out words with less than 3 letters
            all_words = [line.strip() for line in f if len(line.strip()) > 2]
    except FileNotFoundError:
        print(f"Error: Word list file not found at {words_file_path}")
        print("Please ensure 'shona_words.txt' exists in the 'llm' directory.")
        return

    # Potential main words must have 5 or more letters
    potential_main_words = [w for w in all_words if len(w) >= 5]
    word_groups = []

    for main_word in potential_main_words:
        main_word_counter = Counter(main_word)
        sub_words = []
        # To find sub-words, we iterate through the full list of words loaded from the file.
        for word in all_words:
            # A sub-word must be shorter than the main word and be formable from its letters.
            if len(word) < len(main_word) and can_form_word(word, main_word_counter):
                sub_words.append(word)

        # We only want to keep groups that are interesting enough for a game
        if len(sub_words) >= 3:
            word_groups.append({
                "main_word": main_word,
                # Sort sub-words by length for a better gameplay experience
                "sub_words": sorted(sub_words, key=len)
            })

    # Sort the groups by the number of sub-words they have, descending
    word_groups.sort(key=lambda g: len(g['sub_words']), reverse=True)

    try:
        with open(output_file_path, 'w', encoding='utf-8') as f:
            json.dump(word_groups, f, ensure_ascii=False, indent=2)
        print(f"Successfully generated {len(word_groups)} word groups and saved to {output_file_path}")
    except IOError as e:
        print(f"Error writing to JSON file: {e}")

if __name__ == "__main__":
    generate_word_groups()

import os

def clean_and_sort_words():
    """
    Reads words from shona_words.txt, cleans them, removes duplicates,
    sorts them alphabetically, and writes them back to the file.
    """
    # Get the directory of the current script to locate shona_words.txt
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, 'shona_words.txt')

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
        return

    # Clean words: keep only alphabetic, strip whitespace, make lowercase
    # Use a set to automatically handle duplicates
    words = set()
    for line in lines:
        word = line.strip().lower()
        if word and word.isalpha():
            words.add(word)

    # Sort the unique words alphabetically
    sorted_words = sorted(list(words))

    # Write the cleaned and sorted words back to the file
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            for word in sorted_words:
                f.write(word + '\n')
        print(f"Successfully cleaned, sorted, and wrote {len(sorted_words)} unique words to {file_path}")
    except IOError as e:
        print(f"Error writing to file {file_path}: {e}")

if __name__ == "__main__":
    clean_and_sort_words()

File 1: sorts.py
Tasks 4, 5, 11, 12, 13: This module defines the core sorting routines, refactored to accept a custom comparison_function to work on dictionary object abstractions instead of raw numeric configurations.

Python
import random

def bubble_sort(arr, comparison_function):
    swaps = 0
    for i in range(len(arr)):
        for idx in range(len(arr) - 1):
            # Task 5: Use dynamic comparison abstraction instead of '>'
            if comparison_function(arr[idx], arr[idx + 1]):
                arr[idx], arr[idx + 1] = arr[idx + 1], arr[idx]
                swaps += 1
    return swaps

def quicksort(list, start, end, comparison_function):
    # Tasks 11 & 12: In-place recursive quicksort with function pointers
    if start >= end:
        return

    pivot_idx = random.randint(start, end)
    pivot_element = list[pivot_idx]
    list[end], list[pivot_idx] = list[pivot_idx], list[end]

    less_than_pointer = start

    for i in range(start, end):
        # Task 13: Evaluate item properties against the pivot using the comparator
        if comparison_function(pivot_element, list[i]):
            list[i], list[less_than_pointer] = list[less_than_pointer], list[i]
            less_than_pointer += 1

    list[end], list[less_than_pointer] = list[less_than_pointer], list[end]
    
    # Recursive partitioning calls
    quicksort(list, start, less_than_pointer - 1, comparison_function)
    quicksort(list, less_than_pointer + 1, end, comparison_function)
File 2: utils.py
Task 3: Updates your internal ingestion data pipeline to enforce case-insensitive sorting by adding standardized lowercase attributes to the dictionaries.

Python
import csv

def load_books(filename):
    bookshelf = []
    with open(filename, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Task 3: Lowercase caching to protect lexicographical checks from ASCII imbalances
            row['author_lower'] = row['author'].lower()
            row['title_lower'] = row['title'].lower()
            bookshelf.append(row)
    return bookshelf
File 3: script.py
Tasks 1, 2, 6-10, 14-19: This driver file operates your testbenches, runs target snapshots, and benchmarks execution speeds across your datasets.

Python
#!/usr/bin/env python3
import utils
import sorts

# Task 1: Initialize baseline bookshelf tracking array
bookshelf = utils.load_books('books_small.csv')

print("--- Task 1: Current Raw Bookshelf Structure ---")
for book in bookshelf:
    print(book['title'])

# Task 2: Analyze Unicode Character Mapping Points
print("\n--- Task 2: Character Code Point Analysis ---")
print(f"Code point of 'a': {ord('a')}")
print(f"Code point of ' ': {ord(' ')}")
print(f"Code point of 'A': {ord('A')}")

# Task 6: Custom ascending title sorting logic
def by_title_ascending(book_a, book_b):
    return book_a['title_lower'] > book_b['title_lower']

# Task 7: Execute first validation sort loop on minor shifts
print("\n--- Task 7: Executing Bubble Sort (By Title) ---")
bookshelf_title_sort = bookshelf.copy()
bubble_swaps_1 = sorts.bubble_sort(bookshelf_title_sort, by_title_ascending)
print(f"Bubble Sort completed in {bubble_swaps_1} physical index swaps.")

# Task 8: Custom ascending author sorting logic
def by_author_ascending(book_a, book_b):
    return book_a['author_lower'] > book_b['author_lower']

# Task 9 & 10: Deep reference isolation clone
print("\n--- Task 10: Executing Bubble Sort (By Author) ---")
bookshelf_v1 = bookshelf.copy()
bubble_swaps_2 = sorts.bubble_sort(bookshelf_v1, by_author_ascending)
print(f"Author Bubble Sort completed in {bubble_swaps_2} physical index swaps.")

# Task 14 & 15: Run structural in-place partition swaps
print("\n--- Task 15: Executing Quicksort (By Author) ---")
bookshelf_v2 = bookshelf.copy()
sorts.quicksort(bookshelf_v2, 0, len(bookshelf_v2) - 1, by_author_ascending)
print("Quicksort complete. Order confirmation:")
for book in bookshelf_v2:
    print(f"  > {book['author']}")

# Task 16: Custom absolute word length calculation comparison
def by_total_length(book_a, book_b):
    len_a = len(book_a['title']) + len(book_a['author'])
    len_b = len(book_b['title']) + len(book_b['author'])
    return len_a > len_b

# Task 17: Scale data inputs up to stress-test your system
long_bookshelf = utils.load_books('books_large.csv')

# Task 18: Evaluating computational limits on heavy datasets
print("\n--- Task 18 & 19: Large Dataset Profiling ---")
print("[INFO] Skipping Bubble Sort trial for 'books_large.csv' as it locks execution frames at O(N^2)...")
# sorts.bubble_sort(long_bookshelf, by_total_length) # Un-comment to test structural lag

# Task 19: High-efficiency pipeline processing
long_bookshelf_quick = long_bookshelf.copy()
print("Starting Quicksort over large dataset using 'by_total_length'...")
sorts.quicksort(long_bookshelf_quick, 0, len(long_bookshelf_quick) - 1, by_total_length)
print("Quicksort evaluation completed cleanly on the large dataset.")
Step 4: Run the Final Testbench
To see your bookshop sorting routines run in your terminal, use this command:

Bash
python3 script.py
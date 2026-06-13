# Task 1: Create toppings list
toppings = ["pepperoni", "pineapple", "cheese", "sausage", "olives", "anchovies", "mushrooms"]

# Task 2: Create prices list
prices = [2, 6, 1, 3, 2, 7, 2]

# Task 3: Count number of $2 slices
num_two_dollar_slices = prices.count(2)
print(f"Number of $2 slices: {num_two_dollar_slices}")

# Task 4: Find length of toppings list
num_pizzas = len(toppings)

# Task 5: Print number of pizzas
print(f"We sell {num_pizzas} different kinds of pizza!")

# Task 6: Create two-dimensional list pizza_and_prices
pizza_and_prices = [
    [2, "pepperoni"],
    [6, "pineapple"],
    [1, "cheese"],
    [3, "sausage"],
    [2, "olives"],
    [7, "anchovies"],
    [2, "mushrooms"]
]

# Task 7: Print pizza_and_prices
print("Original pizza_and_prices:")
print(pizza_and_prices)

# Task 8: Sort pizza_and_prices by price (ascending)
pizza_and_prices.sort()
print("\nSorted pizza_and_prices:")
print(pizza_and_prices)

# Task 9: Store cheapest pizza
cheapest_pizza = pizza_and_prices[0]
print(f"\nCheapest pizza: {cheapest_pizza}")

# Task 10: Store most expensive pizza
priciest_pizza = pizza_and_prices[-1]
print(f"Priciest pizza: {priciest_pizza}")

# Task 11: Remove priciest pizza (anchovies)
pizza_and_prices.pop()
print(f"\nAfter removing priciest pizza:")
print(pizza_and_prices)

# Task 12: Add new peppers pizza
pizza_and_prices.append([2.5, "peppers"])
pizza_and_prices.sort()
print(f"\nAfter adding peppers pizza:")
print(pizza_and_prices)

# Task 13: Slice the 3 lowest cost pizzas
three_cheapest = pizza_and_prices[:3]

# Task 14: Print the three cheapest pizzas
print(f"\nThree cheapest pizzas:")
print(three_cheapest)
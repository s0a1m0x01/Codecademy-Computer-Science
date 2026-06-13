hairstyles = ["bouffant", "pixie", "dreadlocks", "crew", "bowl", "bob", "mohawk", "flattop"]
prices = [30, 25, 40, 20, 20, 35, 50, 35]
last_week = [2, 3, 5, 8, 4, 4, 6, 2]

# Prices and Cuts
total_price = 0
for price in prices:
    total_price += price

average_price = total_price / len(prices)
print(f"Average Haircut Price: {average_price}")

# Apply $5 discount
new_prices = [price - 5 for price in prices]
print(f"New prices after $5 discount: {new_prices}")

# Revenue calculation
total_revenue = 0
for i in range(len(hairstyles)):
    total_revenue += prices[i] * last_week[i]
    print(f"{hairstyles[i]}: ${prices[i]} × {last_week[i]} sales = ${prices[i] * last_week[i]}")

print(f"\nTotal Revenue: ${total_revenue}")

# Average daily revenue
average_daily_revenue = total_revenue / 7
print(f"Average Daily Revenue: ${average_daily_revenue:.2f}")

# Find cuts under $30 after discount
cuts_under_30 = [hairstyles[i] for i in range(len(new_prices)) if new_prices[i] < 30]
print(f"\nHaircuts under $30 after discount: {cuts_under_30}")
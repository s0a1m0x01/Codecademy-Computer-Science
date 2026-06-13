daily_sales = \
"""Edith Mcbride   ;,;$1.21   ;,;   white ;,; 
09/15/17   ,Herbert Tran   ;,;   $7.29;,; 
white&blue;,;   09/15/17 ,Paul Clarke ;,;$12.52 
;,;   white&blue ;,; 09/15/17 ,Lucille Caldwell   
;,;   $5.13   ;,; white   ;,; 09/15/17,
Eduardo George   ;,;$20.39;,; white&yellow 
;,;09/15/17   ,   Danny Mclaughlin;,;$30.82;,;   
purple ;,;09/15/17 ,Stacy Vargas;,; $1.85   ;,; 
purple&yellow ;,;09/15/17,   Shaun Brock;,; 
$53.15;,;   yellow&green ;,; 09/15/17 ,   Erick Howell 
;,;$13.36 ;,; yellow&green ;,; 09/15/17 ,   Leanna Goodman 
;,;$21.14;,;   purple&yellow 09/15/17 ,   Krista Phillips 
;,;$39.44 ;,;   green&yellow   ;,; 09/15/17 ,   Kevin Martinez 
;,;$48.88 ;,;   purple&yellow   09/15/17 ,   
Adrienne Evans ;,;$25.35 ;,;   yellow ;,; 09/15/17 ,   
Shannon Buckley ;,;$18.34 ;,;   purple&yellow   09/15/17 ,\
"""

# Task 2: Replace ;,; with a different character (using '|')
daily_sales_replaced = daily_sales.replace(";,;", "|")

# Task 3: Split into individual transactions
daily_transactions = daily_sales_replaced.split(',')

# Task 4: Print daily_transactions (commented out to avoid clutter)
# print(daily_transactions)

# Task 5: Create empty list for split transactions
daily_transactions_split = []

# Task 6: Split each transaction into its data points
for transaction in daily_transactions:
    daily_transactions_split.append(transaction.split('|'))

# Task 7: Print daily_transactions_split
# print(daily_transactions_split)

# Task 8: Clean up whitespace
transactions_clean = []
for transaction in daily_transactions_split:
    clean_transaction = []
    for data_point in transaction:
        clean_transaction.append(data_point.strip())
    transactions_clean.append(clean_transaction)

# Task 9: Print cleaned transactions
# print(transactions_clean)

# Task 10: Create empty lists for customers, sales, and thread_sold
customers = []
sales = []
thread_sold = []

# Task 11: Populate the three lists
for transaction in transactions_clean:
    customers.append(transaction[0])
    sales.append(transaction[1])
    thread_sold.append(transaction[2])

# Task 12: Print the lists
print("Customers:", customers)
print("Sales:", sales)
print("Thread sold:", thread_sold)

# Task 13: Calculate total sales
total_sales = 0

# Task 14: Sum up all sales
for sale in sales:
    # Remove $ sign and convert to float
    sale_amount = float(sale.strip('$'))
    total_sales += sale_amount

# Task 15: Print total sales
print(f"\nTotal sales today: ${total_sales:.2f}")

# Task 16: Print thread_sold for inspection
print("\nThread sold list:", thread_sold)

# Task 17: Create empty list for split thread colors
thread_sold_split = []

# Task 18: Split multi-color entries
for item in thread_sold:
    if '&' in item:
        # Split multiple colors by &
        colors = item.split('&')
        for color in colors:
            thread_sold_split.append(color.strip())
    else:
        thread_sold_split.append(item.strip())

# Task 19: Define color_count function
def color_count(color):
    count = 0
    for item in thread_sold_split:
        if item == color:
            count += 1
    return count

# Task 20: Test color_count function
print(f"\nWhite thread count: {color_count('white')}")

# Task 21: Define colors list
colors = ['red', 'yellow', 'green', 'white', 'black', 'blue', 'purple']

# Task 22 with f-strings (more modern approach)
print("\n" + "="*40)
print("THREAD SHED - DAILY SALES REPORT")
print("="*40)

print(f"\n💰 Total Sales: ${total_sales:.2f}")

print("\n🧵 Thread Sales Breakdown:")
for color in colors:
    count = color_count(color)
    if count > 0:
        print(f"   {color.capitalize()}: {count} thread(s) sold")

print("\n👥 Customer Count:", len(customers))

# Optional: Show customer list
print("\n📋 Customers served today:")
for i, customer in enumerate(customers, 1):
    print(f"   {i}. {customer}")
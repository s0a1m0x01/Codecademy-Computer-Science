# Weight of the package
weight = 41.5  # You can change this to test different weights

# Ground Shipping
print("Ground Shipping")
if weight <= 2:
    cost_ground = weight * 1.50 + 20.00
elif weight <= 6:
    cost_ground = weight * 3.00 + 20.00
elif weight <= 10:
    cost_ground = weight * 4.00 + 20.00
else:
    cost_ground = weight * 4.75 + 20.00
print(f"${cost_ground:.2f}")

# Ground Shipping Premium
ground_premium_cost = 125.00
print(f"Ground Shipping Premium: ${ground_premium_cost:.2f}")

# Drone Shipping
print("Drone Shipping")
if weight <= 2:
    cost_drone = weight * 4.50
elif weight <= 6:
    cost_drone = weight * 9.00
elif weight <= 10:
    cost_drone = weight * 12.00
else:
    cost_drone = weight * 14.25
print(f"${cost_drone:.2f}")

# Find the cheapest method
print("\n--- Cheapest Shipping Method ---")
if cost_ground < ground_premium_cost and cost_ground < cost_drone:
    print(f"Ground Shipping is cheapest: ${cost_ground:.2f}")
elif ground_premium_cost < cost_ground and ground_premium_cost < cost_drone:
    print(f"Ground Shipping Premium is cheapest: ${ground_premium_cost:.2f}")
else:
    print(f"Drone Shipping is cheapest: ${cost_drone:.2f}")
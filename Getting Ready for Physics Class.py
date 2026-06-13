# Provided variables
train_mass = 22680
train_acceleration = 10
train_distance = 100
bomb_mass = 1

# Temperature conversion functions
def f_to_c(f_temp):
    """Convert Fahrenheit to Celsius"""
    return (f_temp - 32) * 5/9

def c_to_f(c_temp):
    """Convert Celsius to Fahrenheit"""
    return c_temp * (9/5) + 32

# Force function (Newton's Second Law: F = ma)
def get_force(mass, acceleration):
    """Calculate force using F = ma"""
    return mass * acceleration

# Energy function (Einstein's Mass-Energy Equivalence: E = mc²)
def get_energy(mass, c=3*10**8):
    """Calculate energy using E = mc²"""
    return mass * c ** 2

# Work function (Work = Force × Distance)
def get_work(mass, acceleration, distance):
    """Calculate work using W = F × d, where F = ma"""
    force = get_force(mass, acceleration)
    return force * distance

# Testing the functions
print("=== Temperature Conversions ===")
f100_in_celsius = f_to_c(100)
c0_in_fahrenheit = c_to_f(0)
print(f"100°F = {f100_in_celsius:.2f}°C")
print(f"0°C = {c0_in_fahrenheit:.1f}°F")

print("\n=== Force Calculation ===")
train_force = get_force(train_mass, train_acceleration)
print(f"The GE train supplies {train_force:,} Newtons of force.")

print("\n=== Energy Calculation ===")
bomb_energy = get_energy(bomb_mass)
print(f"A 1kg bomb supplies {bomb_energy:,} Joules.")

print("\n=== Work Calculation ===")
train_work = get_work(train_mass, train_acceleration, train_distance)
print(f"The GE train does {train_work:,} Joules of work over {train_distance} meters.")
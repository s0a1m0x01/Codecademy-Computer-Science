-- ============================================
-- TASK 1: Inspect the first 10 rows of parts
-- ============================================

SELECT * FROM parts LIMIT 10;

-- Also check other tables available
SELECT * FROM manufacturers LIMIT 5;
SELECT * FROM locations LIMIT 5;
SELECT * FROM reorder_options LIMIT 5;

-- ============================================
-- TASKS 2-5: Improving Parts Tracking
-- ============================================

-- Task 2: Add UNIQUE and NOT NULL constraints to code column
-- First, check for existing NULL or duplicate values
SELECT code, COUNT(*) 
FROM parts 
GROUP BY code 
HAVING COUNT(*) > 1;

-- Add constraints to code column
ALTER TABLE parts
ADD CONSTRAINT unique_code UNIQUE (code);

ALTER TABLE parts
ALTER COLUMN code SET NOT NULL;

-- Task 3: Fill missing description values
-- First, check which rows have NULL descriptions
SELECT id, description, code 
FROM parts 
WHERE description IS NULL;

-- Update NULL descriptions with a default value
UPDATE parts 
SET description = 'No description provided' 
WHERE description IS NULL;

-- Task 4: Add NOT NULL constraint to description
ALTER TABLE parts
ALTER COLUMN description SET NOT NULL;

-- Task 5: Test constraint with attempted insert (will fail)
-- This insert will be rejected because description is empty
INSERT INTO parts (id, description, code, manufacturer_id) 
VALUES (54, '', 'V1-009', 9);

-- Correct insert with proper description
INSERT INTO parts (id, description, code, manufacturer_id) 
VALUES (54, 'Standard mechanical bolt, grade 8', 'V1-009', 9);

-- Verify the insert worked
SELECT * FROM parts WHERE id = 54;

-- ============================================
-- TASKS 6-9: Improving Reorder Options
-- ============================================

-- Task 6: Ensure price_usd and quantity are NOT NULL
ALTER TABLE reorder_options
ALTER COLUMN price_usd SET NOT NULL,
ALTER COLUMN quantity SET NOT NULL;

-- Task 7: Ensure price_usd and quantity are positive
-- As a single constraint
ALTER TABLE reorder_options
ADD CONSTRAINT positive_price_quantity 
CHECK (price_usd > 0 AND quantity > 0);

-- Alternative: As two separate constraints
ALTER TABLE reorder_options
ADD CONSTRAINT positive_price CHECK (price_usd > 0);

ALTER TABLE reorder_options
ADD CONSTRAINT positive_quantity CHECK (quantity > 0);

-- Task 8: Add constraint for price per unit range (0.02 to 25.00)
-- Price per unit = price_usd / quantity
ALTER TABLE reorder_options
ADD CONSTRAINT price_per_unit_range 
CHECK (price_usd / quantity BETWEEN 0.02 AND 25.00);

-- Task 9: Ensure reorder_options references valid parts
-- First, check for orphaned records
SELECT DISTINCT part_id 
FROM reorder_options 
WHERE part_id NOT IN (SELECT id FROM parts);

-- Add foreign key constraint
ALTER TABLE reorder_options
ADD CONSTRAINT fk_reorder_options_part 
FOREIGN KEY (part_id) REFERENCES parts(id);

-- ============================================
-- TASKS 10-12: Improving Location Tracking
-- ============================================

-- Task 10: Ensure qty is greater than 0
ALTER TABLE locations
ADD CONSTRAINT positive_quantity 
CHECK (qty > 0);

-- Task 11: Ensure unique combination of location and part
-- First, check for duplicates
SELECT part_id, location, COUNT(*) 
FROM locations 
GROUP BY part_id, location 
HAVING COUNT(*) > 1;

-- Add unique constraint on part_id and location combination
ALTER TABLE locations
ADD CONSTRAINT unique_part_location 
UNIQUE (part_id, location);

-- Task 12: Ensure locations reference valid parts
-- First, check for orphaned records
SELECT DISTINCT part_id 
FROM locations 
WHERE part_id NOT IN (SELECT id FROM parts);

-- Add foreign key constraint
ALTER TABLE locations
ADD CONSTRAINT fk_locations_part 
FOREIGN KEY (part_id) REFERENCES parts(id);

-- ============================================
-- TASKS 13-15: Improving Manufacturer Tracking
-- ============================================

-- Task 13: Ensure all parts have valid manufacturer references
-- First, check for NULL manufacturer_ids
SELECT id, code, manufacturer_id 
FROM parts 
WHERE manufacturer_id IS NULL;

-- Add foreign key constraint
ALTER TABLE parts
ADD CONSTRAINT fk_parts_manufacturer 
FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id);

-- Make manufacturer_id NOT NULL if not already
ALTER TABLE parts
ALTER COLUMN manufacturer_id SET NOT NULL;

-- Task 14: Create new manufacturer after merger
INSERT INTO manufacturers (id, name, address, phone, contact_email)
VALUES (11, 'Pip-NNC Industrial', '456 Industrial Way, Chicago, IL', '312-555-9876', 'contact@pip-nnc.com');

-- Verify insert
SELECT * FROM manufacturers WHERE id = 11;

-- Task 15: Update old manufacturers' parts to reference new company
-- First, see which parts need updating
SELECT p.id, p.code, p.manufacturer_id, m.name
FROM parts p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name IN ('Pip Industrial', 'NNC Manufacturing');

-- Update parts from 'Pip Industrial' and 'NNC Manufacturing' to new manufacturer
UPDATE parts 
SET manufacturer_id = 11
WHERE manufacturer_id IN (
    SELECT id FROM manufacturers 
    WHERE name IN ('Pip Industrial', 'NNC Manufacturing')
);

-- Verify the update
SELECT p.id, p.code, p.manufacturer_id, m.name
FROM parts p
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.name = 'Pip-NNC Industrial';

-- Optional: Archive or remove old manufacturer records
-- UPDATE manufacturers SET active = false WHERE id IN (9, 10);
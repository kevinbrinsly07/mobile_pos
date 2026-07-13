-- Seed additional categories safely
insert into categories (store_id, name, sort_order)
select s.id, c.name, c.sort_order
from stores s
cross join (values 
  ('Beverages', 1), 
  ('Snacks', 2), 
  ('Household', 3),
  ('Bakery', 4),
  ('Dairy', 5),
  ('Produce', 6),
  ('Frozen Foods', 7),
  ('Meat & Seafood', 8)
) as c(name, sort_order)
where s.name = 'Main Store'
on conflict (store_id, name) do nothing;

-- Seed additional products safely
insert into products (store_id, name, sku, barcode, category_id, price, cost, tax_rate, stock_qty, low_stock_threshold, unit, is_active)
select
  s.id,
  p.name,
  p.sku,
  p.barcode,
  c.id,
  p.price,
  p.cost,
  800, -- 8% tax rate default
  p.stock_qty,
  10,
  'each',
  true
from stores s
join categories c on c.store_id = s.id
join (
  values
    -- Beverages
    ('Cola 330ml', 'BEV-001', '1001001001', 'Beverages', 250, 120, 120),
    ('Orange Juice 1L', 'BEV-002', '1001001002', 'Beverages', 450, 230, 80),
    ('Mineral Water 500ml', 'BEV-003', '1001001003', 'Beverages', 150, 60, 150),
    ('Green Tea 500ml', 'BEV-004', '1001001004', 'Beverages', 200, 90, 100),
    ('Energy Drink 250ml', 'BEV-005', '1001001005', 'Beverages', 350, 180, 75),
    ('Coffee Latte 240ml', 'BEV-006', '1001001006', 'Beverages', 300, 130, 60),

    -- Snacks
    ('Potato Chips', 'SNK-001', '1002001001', 'Snacks', 300, 140, 60),
    ('Chocolate Bar 100g', 'SNK-002', '1002001002', 'Snacks', 200, 100, 120),
    ('Gummy Bears 150g', 'SNK-003', '1002001003', 'Snacks', 250, 110, 90),
    ('Salted Peanuts 200g', 'SNK-004', '1002001004', 'Snacks', 180, 80, 110),
    ('Chocolate Chip Cookies', 'SNK-005', '1002001005', 'Snacks', 350, 170, 80),

    -- Household
    ('Dish Soap', 'HOU-001', '1003001001', 'Household', 700, 350, 40),
    ('Laundry Detergent 1L', 'HOU-002', '1003001002', 'Household', 1200, 600, 30),
    ('Paper Towels 2-pack', 'HOU-003', '1003001003', 'Household', 250, 100, 50),
    ('Trash Bags 30L', 'HOU-004', '1003001004', 'Household', 400, 180, 40),
    ('All-Purpose Cleaner', 'HOU-005', '1003001005', 'Household', 650, 300, 35),

    -- Bakery
    ('White Bread 500g', 'BAK-001', '1004001001', 'Bakery', 220, 100, 40),
    ('Whole Wheat Bread 500g', 'BAK-002', '1004001002', 'Bakery', 260, 120, 30),
    ('Butter Croissant', 'BAK-003', '1004001003', 'Bakery', 180, 70, 25),
    ('Blueberry Muffin', 'BAK-004', '1004001004', 'Bakery', 200, 80, 20),

    -- Dairy
    ('Fresh Milk 1L', 'DY-001', '1005001001', 'Dairy', 290, 150, 50),
    ('Cheddar Cheese 200g', 'DY-002', '1005001002', 'Dairy', 490, 250, 35),
    ('Greek Yogurt 500g', 'DY-003', '1005001003', 'Dairy', 380, 190, 40),
    ('Salted Butter 250g', 'DY-004', '1005001004', 'Dairy', 420, 210, 30),

    -- Produce
    ('Red Apples 1kg', 'PRD-001', '1006001001', 'Produce', 390, 200, 45),
    ('Bananas 1kg', 'PRD-002', '1006001002', 'Produce', 220, 100, 60),
    ('Fresh Tomatoes 1kg', 'PRD-003', '1006001003', 'Produce', 320, 150, 50),
    ('Organic Spinach 200g', 'PRD-004', '1006001004', 'Produce', 250, 120, 25),

    -- Frozen Foods
    ('Frozen Pizza Pepperoni', 'FRZ-001', '1007001001', 'Frozen Foods', 850, 450, 20),
    ('Vanilla Ice Cream 1L', 'FRZ-002', '1007001002', 'Frozen Foods', 600, 300, 25),
    ('Frozen French Fries 1kg', 'FRZ-003', '1007001003', 'Frozen Foods', 450, 200, 30),

    -- Meat & Seafood
    ('Chicken Breast 1kg', 'MET-001', '1008001001', 'Meat & Seafood', 1100, 650, 15),
    ('Ribeye Steak 300g', 'MET-002', '1008001002', 'Meat & Seafood', 1800, 1100, 10),
    ('Fresh Salmon Fillet 200g', 'MET-003', '1008001003', 'Meat & Seafood', 1400, 850, 12)
) as p(name, sku, barcode, category_name, price, cost, stock_qty)
  on p.category_name = c.name
where s.name = 'Main Store'
  and not exists (
    select 1 
    from products pr 
    where pr.store_id = s.id 
      and (pr.sku = p.sku or pr.barcode = p.barcode)
  );

-- Grow the master crop catalogue beyond the original five (Pechay, Corn, Rice,
-- Tomato, Eggplant) to the crops Filipino farmers commonly grow, with the ones
-- Davao del Sur is known for first. Additive and idempotent: existing crops and
-- every Farmer's saved Main Crops are left untouched.
--
-- Rollback (only if no Farmer has chosen these yet, otherwise their saved
-- Main Crops cascade away):
--   delete from public.crops where crop_name in (<the names below>);

insert into public.crops (crop_name, optimal_conditions) values
-- Davao del Sur plantation and fruit crops
('Banana', '{"temperature_range": "26-30°C", "soil": "Deep, fertile, well-drained loam", "watering": "Regular, never waterlogged"}'::jsonb),
('Coconut', '{"temperature_range": "27-32°C", "soil": "Sandy loam, well-drained", "watering": "Rainfed; irrigate in long dry spells"}'::jsonb),
('Cacao', '{"temperature_range": "21-32°C", "soil": "Deep, humus-rich, well-drained", "watering": "Evenly moist, under partial shade"}'::jsonb),
('Coffee', '{"temperature_range": "18-28°C", "soil": "Deep, fertile, well-drained, slightly acidic", "watering": "Regular during flowering and fruit set"}'::jsonb),
('Durian', '{"temperature_range": "24-32°C", "soil": "Deep, rich, well-drained loam", "watering": "Regular; avoid waterlogging"}'::jsonb),
('Pomelo', '{"temperature_range": "23-32°C", "soil": "Deep, fertile, well-drained loam", "watering": "Regular, more at flowering and fruiting"}'::jsonb),
('Mango', '{"temperature_range": "24-34°C", "soil": "Deep, well-drained loam", "watering": "Light; dry spell helps flowering"}'::jsonb),
('Pineapple', '{"temperature_range": "22-32°C", "soil": "Light, sandy, well-drained, acidic", "watering": "Moderate; tolerates short dry spells"}'::jsonb),
('Papaya', '{"temperature_range": "25-32°C", "soil": "Light, fertile, well-drained", "watering": "Regular; never waterlogged"}'::jsonb),
('Mangosteen', '{"temperature_range": "25-32°C", "soil": "Deep, humus-rich, well-drained", "watering": "Evenly moist all year"}'::jsonb),
('Rambutan', '{"temperature_range": "24-32°C", "soil": "Deep, fertile, well-drained", "watering": "Regular, especially in dry months"}'::jsonb),
('Lanzones', '{"temperature_range": "24-30°C", "soil": "Deep, humus-rich, moist but well-drained", "watering": "Evenly moist, under partial shade"}'::jsonb),
('Jackfruit', '{"temperature_range": "24-33°C", "soil": "Deep, well-drained loam", "watering": "Moderate; avoid waterlogging"}'::jsonb),
('Calamansi', '{"temperature_range": "23-32°C", "soil": "Loam, well-drained, pH 5.5-6.5", "watering": "Regular; avoid waterlogging"}'::jsonb),
('Abaca', '{"temperature_range": "22-32°C", "soil": "Fertile, well-drained volcanic loam", "watering": "Evenly distributed rainfall"}'::jsonb),
('Sugarcane', '{"temperature_range": "24-34°C", "soil": "Deep, fertile, well-drained loam", "watering": "High during growth, dry before harvest"}'::jsonb),
-- Root crops, legumes and other field crops
('Cassava', '{"temperature_range": "25-32°C", "soil": "Light, sandy loam, well-drained", "watering": "Low; drought tolerant once established"}'::jsonb),
('Camote', '{"temperature_range": "21-30°C", "soil": "Light, sandy loam, well-drained", "watering": "Light; avoid waterlogging"}'::jsonb),
('Gabi', '{"temperature_range": "21-30°C", "soil": "Rich, moist or lightly flooded loam", "watering": "High; keep soil wet"}'::jsonb),
('Ube', '{"temperature_range": "25-30°C", "soil": "Deep, loose, well-drained loam", "watering": "Moderate; avoid waterlogging"}'::jsonb),
('Peanut', '{"temperature_range": "25-30°C", "soil": "Loose, sandy loam, well-drained", "watering": "Moderate; critical at pegging"}'::jsonb),
('Mung Bean', '{"temperature_range": "25-35°C", "soil": "Well-drained loam, pH 6.0-7.0", "watering": "Light; sensitive to waterlogging"}'::jsonb),
-- Vegetables
('Ampalaya', '{"temperature_range": "24-32°C", "soil": "Fertile, well-drained loam, with trellis", "watering": "Regular, avoid wetting leaves"}'::jsonb),
('Sitaw', '{"temperature_range": "20-32°C", "soil": "Fertile, well-drained loam, with trellis", "watering": "Regular; critical at flowering"}'::jsonb),
('Okra', '{"temperature_range": "24-35°C", "soil": "Fertile, well-drained loam", "watering": "Moderate and regular"}'::jsonb),
('Squash', '{"temperature_range": "20-32°C", "soil": "Fertile, well-drained loam, rich in organic matter", "watering": "Regular; reduce near harvest"}'::jsonb),
('Cucumber', '{"temperature_range": "20-30°C", "soil": "Light, fertile, well-drained loam", "watering": "Regular, avoid wetting leaves"}'::jsonb),
('Upo', '{"temperature_range": "22-32°C", "soil": "Fertile, well-drained loam, with trellis", "watering": "Regular and moderate"}'::jsonb),
('Patola', '{"temperature_range": "24-32°C", "soil": "Fertile, well-drained loam, with trellis", "watering": "Regular and moderate"}'::jsonb),
('Kangkong', '{"temperature_range": "25-35°C", "soil": "Wet, rich soil or shallow water", "watering": "High; keep soil saturated"}'::jsonb),
('Mustard', '{"temperature_range": "15-27°C", "soil": "Fertile, well-drained loam", "watering": "Regular, keep moist"}'::jsonb),
('Cabbage', '{"temperature_range": "15-24°C", "soil": "Fertile, well-drained loam, pH 6.0-6.8", "watering": "Regular and even"}'::jsonb),
('Lettuce', '{"temperature_range": "15-24°C", "soil": "Light, fertile, well-drained loam", "watering": "Frequent, light watering"}'::jsonb),
('Carrot', '{"temperature_range": "15-25°C", "soil": "Deep, loose, stone-free loam", "watering": "Even moisture"}'::jsonb),
('Radish', '{"temperature_range": "15-25°C", "soil": "Loose, well-drained sandy loam", "watering": "Regular and even"}'::jsonb),
('Onion', '{"temperature_range": "15-30°C", "soil": "Well-drained sandy loam, pH 6.0-7.0", "watering": "Light and frequent; stop before harvest"}'::jsonb),
('Garlic', '{"temperature_range": "15-28°C", "soil": "Loose, well-drained loam", "watering": "Light; stop before harvest"}'::jsonb),
('Ginger', '{"temperature_range": "25-30°C", "soil": "Loose, rich, well-drained loam", "watering": "Regular; avoid waterlogging"}'::jsonb),
('Chili Pepper', '{"temperature_range": "22-32°C", "soil": "Fertile, well-drained loam", "watering": "Moderate; avoid waterlogging"}'::jsonb),
('Bell Pepper', '{"temperature_range": "18-27°C", "soil": "Fertile, well-drained loam, pH 6.0-6.8", "watering": "Regular and even"}'::jsonb),
('Moringa', '{"temperature_range": "25-35°C", "soil": "Light, well-drained sandy loam", "watering": "Low; drought tolerant"}'::jsonb)
on conflict (crop_name) do nothing;

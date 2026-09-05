-- Non-retail QoL: Allow guild-shop crafting kits (levels 5-50) to synth on Live.
-- Live uses ENABLE_SOA=0 + RESTRICT_CONTENT=1; SOA-tagged kit recipes fail while
-- shops still sell the kits (xi.shop.generalGuildStock has no content check).
-- Outputs are classic pre-SoA goods. Higher RoV kits (55+) are not in guild shops
-- and stay gated. Do not flip ENABLE_SOA for this.

UPDATE synth_recipes
SET content_tag = NULL
WHERE Ingredient2 = 0
  AND content_tag IN ('SOA', 'ROV')
  AND Ingredient1 IN (
    -- Woodworking Kit 5-50
    8805, 8806, 8807, 8808, 8809, 8810, 8811, 8812, 8813, 8814,
    -- Smithing Kit 5-50
    8819, 8820, 8821, 8822, 8823, 8824, 8825, 8826, 8827, 8828,
    -- Goldsmithing Kit 5-50
    8833, 8834, 8835, 8836, 8837, 8838, 8839, 8840, 8841, 8842,
    -- Clothcraft Kit 5-50
    8847, 8848, 8849, 8850, 8851, 8852, 8853, 8854, 8855, 8856,
    -- Leathercraft Kit 5-50
    8861, 8862, 8863, 8864, 8865, 8866, 8867, 8868, 8869, 8870,
    -- Bonecraft Kit 5-50
    8875, 8876, 8877, 8878, 8879, 8880, 8881, 8882, 8883, 8884,
    -- Alchemy Kit 5-50
    8889, 8890, 8891, 8892, 8893, 8894, 8895, 8896, 8897, 8898,
    -- Cooking Kit 5-50
    8903, 8904, 8905, 8906, 8907, 8908, 8909, 8910, 8911, 8912
  );

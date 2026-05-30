package com.mbcms.model;

import java.math.BigDecimal;

/**
 * FoodItem - map bang `food_items` (menu F&B).
 * category: SNACK | DRINK | COMBO
 */
public class FoodItem {

    public static final String CATEGORY_SNACK = "SNACK";
    public static final String CATEGORY_DRINK = "DRINK";
    public static final String CATEGORY_COMBO = "COMBO";

    private long foodId;
    private String name;
    private String description;
    private BigDecimal price;
    private String category;
    private String imageUrl;
    private boolean active = true;

    public FoodItem() {}

    public long getFoodId() { return foodId; }
    public void setFoodId(long foodId) { this.foodId = foodId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}

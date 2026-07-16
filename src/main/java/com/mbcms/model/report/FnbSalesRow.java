package com.mbcms.model.report;

import java.math.BigDecimal;

public class FnbSalesRow {
    private String itemName;
    private String category;
    private int qtySold;
    private BigDecimal revenue;

    public FnbSalesRow() {}

    public FnbSalesRow(String itemName, String category, int qtySold, BigDecimal revenue) {
        this.itemName = itemName;
        this.category = category;
        this.qtySold = qtySold;
        this.revenue = revenue;
    }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getQtySold() { return qtySold; }
    public void setQtySold(int qtySold) { this.qtySold = qtySold; }

    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
}

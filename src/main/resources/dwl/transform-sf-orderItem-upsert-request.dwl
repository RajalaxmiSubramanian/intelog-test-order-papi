%dw 2.0
output application/json
var region = vars.giftJson.region
---
{
  "allOrNone": true,
  "records": payload map (lineItem, index) -> {
      "attributes": {
        "type": "OrderItem__c"
      },
      "SKU__c": lineItem.sku,
      "Shopify_Id__c": lineItem.id,
      "Name": lineItem.variant_title,
      "Quantity__c": lineItem.quantity,
      "Amount__c": lineItem.price,
      "Type__c": lineItem.'type',
      "SKU_GAU__c": lineItem.sku_gau,
      "Order_Opportunity__c": vars.sf_opportunity_id,
      "CurrencyIsoCode__c": if (region == "USA") "USD" else if (region == "CAN") "CAD" else ""
  }
}
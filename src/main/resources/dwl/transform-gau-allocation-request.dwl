%dw 2.0
output application/json
var oppRef = "@{newOpportunity.id}"
var USATransactionId= p("salesforce.gau.transactionFeesId.USA")
var CANTransactionId= p("salesforce.gau.transactionFeesId.CAN")
var USAMerchandiseId = p("salesforce.gau.merchandiseId.USA")
var CANMerchandiseId = p("salesforce.gau.merchandiseId.CAN")
var groupedGAU =
    vars.giftJson.line_items
        groupBy $.sku_gau
        pluck ((items, gau) -> {
            "npsp_Amount__c": (items map ($.gau_amount as Number)) reduce ($$ + $),
            "npsp_General_Accounting_Unit__c": gau,
            "External_ID__c": gau ++ oppRef 
        })

var fmvAllocation =
    if (vars.giftJson.pay.fmv != 0.00)
        
           [ {
                "npsp_Amount__c": vars.giftJson.pay.fmv,
                "npsp_General_Accounting_Unit__c":
                    if (vars.giftJson.region == "USA")
                        USAMerchandiseId
                    else
                        CANMerchandiseId,
                "External_ID__c":
                    (
                        if (vars.giftJson.region == "USA")
                            USAMerchandiseId
                        else
                            CANMerchandiseId
                    ) ++ oppRef,
                "Revenue_Category_Flag__c": "IJM Merchandise"
            }]
        
    else []

var transactionFeeAllocation =
    if (vars.giftJson.pay.transaction_fee_amount != 0.00)
        [
            {
                "npsp_Amount__c": 0,
                "npsp_General_Accounting_Unit__c":
                    if (vars.giftJson.region == "USA")
                        USATransactionId
                    else
                        CANTransactionId,
                "External_ID__c":
                    (
                        if (vars.giftJson.region == "USA")
                            USATransactionId
                        else
                            CANTransactionId
                    ) ++ oppRef,
                "Revenue_Category_Flag__c": "true",

                ("WorkDay_Currency__c": vars.giftJson.pay.transaction_fee_amount) if (vars.giftJson.region == "USA"),
                ("Quickbook_Currency__c": vars.giftJson.pay.transaction_fee_amount) if (vars.giftJson.region == "CAN")
            }
        ]
    else []

---
groupedGAU ++ fmvAllocation ++ transactionFeeAllocation
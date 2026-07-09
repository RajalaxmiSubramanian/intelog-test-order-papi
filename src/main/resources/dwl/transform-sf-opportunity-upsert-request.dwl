%dw 2.0
output application/json
import getOpportunityStatusInfo, getOpportunityType 
from modules::lookups::opportunityLookup

var CurrencyIsoCode = upper(vars.giftJson.pay.currency)

fun getDefaultOwner(currencyIsoCode: String) = if(currencyIsoCode == "CAD") p('salesforce.ownerId.CAN') else p('salesforce.ownerId.USA')

fun getShopifyReceiptId(transactionId, gatewayName) =
    if (gatewayName == "Shopify CAN" or gatewayName == "Shopify USA") transactionId else ""


fun determineBillingAddress(contactCity, contactCountry, contactState, contactStreet, contactZip,
                           billingCity, billingCountry, billingState, billingStreet, billingZip) = {
    billingCity: billingCity default contactCity default "",
    billingCountry: billingCountry default contactCountry default "",
    billingState: billingState default contactState default "",
    billingStreet: billingStreet default contactStreet default "",
    billingZip: billingZip default contactZip default ""
}

fun determineShippingAddress(billingCity, billingCountry, billingZip, billingState, billingStreet,
                            shippingCity, shippingCountry, shippingZip, shippingState, shippingStreet) = {
    shippingCity: shippingCity default billingCity default "",
    shippingCountry: shippingCountry default billingCountry default "",
    shippingZip: shippingZip default billingZip default "",
    shippingState: shippingState default billingState default "",
    shippingStreet: shippingStreet default billingStreet default ""
}



var billingAddress = determineBillingAddress(
    vars.giftJson.person.city, vars.giftJson.person.country, vars.giftJson.person.state, vars.giftJson.person.street, vars.giftJson.person.postal_code,
    vars.giftJson.billing_address.billing_city, vars.giftJson.billing_address.billing_country, vars.giftJson.billing_address.billing_state,
    vars.giftJson.billing_address.billing_street, vars.giftJson.billing_address.billing_postalcode
)

var shippingAddress = determineShippingAddress(
    vars.giftJson.billing_address.billing_city, vars.giftJson.billing_address.billing_country, vars.giftJson.billing_address.billing_postalcode,
    vars.giftJson.billing_address.billing_state, vars.giftJson.billing_address.billing_street,
    vars.giftJson.shipping_address.shipping_city, vars.giftJson.shipping_address.shipping_country, vars.giftJson.shipping_address.shipping_postalcode,
    vars.giftJson.shipping_address.shipping_state, vars.giftJson.shipping_address.shipping_street
)

---
{
    Opportunity: {

    Amount: vars.giftJson.pay.gift_amount as Number default 0.0, 

    CloseDate: vars.giftJson.pay.gift_date default now(),

    Name: if (vars.opportunityName != null and vars.opportunityName !="") vars.opportunityName else (vars.giftJson.pay.external_transaction_id default ""),

    "Type": getOpportunityType(vars.giftJson.event_type default ""), 

    
    StageName: getOpportunityStatusInfo(vars.giftJson.pay.charge_status default "").StageName, 
    RecordTypeId__c: getOpportunityStatusInfo(vars.giftJson.pay.charge_status default "").RecordTypeId,
    Post_Status__c: getOpportunityStatusInfo(vars.giftJson.pay.charge_status default "").Post_Status__c, 
    //CampaignId: vars.giftJson.sf_ids.sf_campaign_id default "",

    
    OwnerId: getDefaultOwner(upper(vars.giftJson.pay.currency default "")), // hardcoded for developer account
    Order_Id__c: vars.giftJson.shopify_order_number default "",
   "Premium_Amount__c" : vars.giftJson.pay.fmv default 0.00,

    
    Payment_Method__c: vars.giftJson.pay.paymethod_type default "",

    Transaction_Id__c: vars.giftJson.pay.external_transaction_id,

    Gateway_Transaction_ID__c: vars.giftJson.pay.gateway_transaction_id default "",

    Financial_Provider__c: vars.giftJson.financial_provider default "",
    Payment_Gateway_Name__c: vars.giftJson.gateway_name default "",
    Gift_Processor__c: vars.giftJson.gift_processor default "",

    
    Credit_Card_Type__c: vars.giftJson.pay.credit_card_type default "",
    Last_4__c: vars.giftJson.pay.last_4 default "",
    Exp_Month__c: vars.giftJson.pay.exp_month default "",
    Exp_Year__c: vars.giftJson.pay.exp_year default "",
    Cardholder_Name__c: vars.giftJson.pay.cardholder_name default "", 
    Bank_Name__c: vars.giftJson.pay.bank_name default "", 
    Check_Number__c: vars.giftJson.pay.check_number default "",

    
    Transaction_Fee_Amount__c: vars.giftJson.pay.transaction_fee_amount as Number default 0.0,
    Cover_Transaction_Fees__c: vars.giftJson.pay.transaction_fee_covered default false,
    Currency__c: upper(vars.giftJson.pay.currency) default "",
    CurrencyIsoCode__c: upper(vars.giftJson.pay.currency) default "",

    
    Receipt_Status__c: vars.giftJson.pay.receipt_status default "",
    Receipt_Id__c: getShopifyReceiptId(vars.giftJson.pay.external_transaction_id, vars.giftJson.gateway_name),
    Order__c: vars.giftJson.shopify_order_number default "",
    Financial_Provider_Account__c: vars.giftJson.financial_provider default "",

    
    Donor_Id__c: vars.giftJson.person.external_donor_id default "",

    
    Version__c: vars.giftJson.marketing_tags.version,

    Response_Channel__c: vars.giftJson.marketing_tags.response_channel,

    Source_Channel__c: vars.giftJson.marketing_tags.source_channel,

    Form_Ask_Level__c: vars.giftJson.marketing_tags.donation_level,
    Organization_Soft_Credit__c: "",

    
    Primary_GAU__c: (vars.giftJson.line_items.*line_item map ((item, index) ->
        item.sku_gau
    ))[0] default "",

   
    Billing_City__c: billingAddress.billingCity,
    Billing_Country__c: billingAddress.billingCountry,
    Billing_State__c: billingAddress.billingState,
    Billing_Street__c: billingAddress.billingStreet,
    Billing_Zip__c: billingAddress.billingZip,

    
    ShippingCity__c: shippingAddress.shippingCity,
    ShippingCountry__c: shippingAddress.shippingCountry,
    ShippingPostalCode__c: shippingAddress.shippingZip,
    ShippingState__c: shippingAddress.shippingState,
    ShippingStreet__c: shippingAddress.shippingStreet
    }
}
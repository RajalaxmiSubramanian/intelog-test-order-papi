%dw 2.0
output application/json

var region=vars.region

// Custom function to build full name from first and last name
fun buildFullName(firstName: String, lastName: String) =
    if (firstName != null and lastName != null)
        "$(firstName) $(lastName)"
    else if (firstName != null)
        firstName
    else if (lastName != null)
        lastName
    else ""

// Custom function to get channels from note and tags
fun getChannels(note: String, tags: String) = do {
    var noteParts = if (note != null) note splitBy "," else []
    var srcChannel = if (sizeOf(noteParts) > 0) noteParts[0] replace "src__" with "" else ""
    var rspFromNote = if (sizeOf(noteParts) > 1) noteParts[1] replace "rsp__" with "" else ""
    var rspFromTags = if (tags != null and (tags contains "mailed order")) "Mail"
                     else if (tags != null and (tags contains "phone order")) "Phone Inbound"
                     else rspFromNote
    var ver = if (sizeOf(noteParts) > 2) noteParts[2] replace "ver__" with "" else ""
    ---
    {
        source_channel: srcChannel,
        response_channel: rspFromTags,
        version: ver
    }
}

// Custom function to determine gift type
fun determineType(cardValue: String, tags: String) =
    if (cardValue == "Mailed Card") "Mailed Card"
    else if (cardValue == "E-card or Print at Home") "E-card"
    else if (tags != null and (tags contains "mailed card")) "Mailed Card"
    else "E-Card" // default

fun defaultSelect(defaultvalue: String, additionalValue: String) =
    if(defaultvalue != null and defaultvalue != "") defaultvalue else additionalValue

fun buildAddressDetails(Address1: String, Address2: String) =
    if (Address2 != null and Address2 != "") (Address1 ++ " \n " ++ Address2)
                 else Address1


// Custom function to build shipping name
fun buildShippingName(shippingName: String, shippingFirstName: String, shippingLastName: String) =
    if (shippingName != null and shippingName != "") shippingName else buildFullName(shippingFirstName, shippingLastName)



// Custom function to calculate GAU amount
fun calculateGAUAmount(price: Number, quantity: Number, productId: Number) =
    (price * quantity) as String {format: "0.00"}

// Custom function to get gateway name from currency
fun getGatewayName(currency: String) =
    if (currency == "USD") "Shopify USA"
    else if(currency == "CAD") "Shopify CAN"
    else "" // default

// Custom function to get campaign ID (placeholder)


fun getCampaignId() =
    if (region == "USA") p('salesforce.campaignId.USA')
    else if(region == "CAN") p('salesforce.campaignId.CAN')
    else "" // default

// Custom function to get receipt status (placeholder)
fun getReceiptStatus() = 
    if (region == "USA") "Receipted"
    else if(region == "CAN") "Not Receipted"
    else "" // default

// Custom function to extract order number from name
fun extractOrderNumber(orderName: String) =
    if (orderName != null) orderName replace "#" with "" else ""

// Custom function to get last 4 digits of credit card
fun getLast4Digits(cardNumber: String) =
    if (cardNumber != null and cardNumber != "")
        (cardNumber splitBy "-")[3]
    else ""
    
fun getSkuGau(name) = (vars.gauData filter ($.Name == name))[0].Id default
        (if (vars.region == "CAN") p('salesforce.gau.recordTypeId.CAN')
         else if (vars.region == "USA") p('salesforce.gau.recordTypeId.USA')
         else null)

var paymentTransactions =(vars.currentOrder.order.transactions default []) filter ($.status == "SUCCESS" and ($.kind == "SALE" or $.kind == "CAPTURE" or $.kind == "AUTHORIZE"))
// Main transformation
---
{
    
    context_id: vars.currentOrder.order.id,  
    gateway_name: getGatewayName(vars.currentOrder.order.currencyCode default "USD"),
    shopify_order_number: extractOrderNumber(vars.currentOrder.order.name default ""),
    event_type: "eStore Card",
    financial_provider: "Stripe",
    person: {
        first_name: vars.currentOrder.order.customer.firstName,
        last_name: vars.currentOrder.order.customer.lastName,
        email: vars.currentOrder.order.email,
        created_date: vars.currentOrder.customer.createdAt,
        phone: vars.currentOrder.order.customer.defaultAddress.phone,

              street: buildAddressDetails(defaultSelect(
          vars.currentOrder.order.customer.defaultAddress.address1 default "",
            vars.currentOrder.order.customer.addressesV2[0].address1 default ""
        ),defaultSelect(vars.currentOrder.order.customer.defaultAddress.address2 default "",
            vars.currentOrder.order.customer.addressesV2[0].address2 default "") ),  

        city: defaultSelect(
            
            vars.currentOrder.order.customer.defaultAddress.city default "",
            vars.currentOrder.order.customer.addressesV2[0].city default ""
        ),  
        
          postal_code: defaultSelect( vars.currentOrder.order.customer.defaultAddress.zip default "", vars.currentOrder.order.customer.addressesV2[0].zip default ""), 
       
       country: defaultSelect(vars.currentOrder.order.customer.defaultAddress.country default "",vars.currentOrder.order.customer.addressesV2[0].country default ""),

    state: defaultSelect(vars.currentOrder.order.customer.defaultAddress.province default "",vars.currentOrder.order.customer.addressesV2[0].province default ""), 

        external_donor_id: vars.currentOrder.order.customer.id,
        email_optout: "0" // STATIC VALUE OF 0
    },
    account: {
        name: buildFullName(vars.currentOrder.order.customer.firstName, vars.currentOrder.order.customer.lastName)
    },
    pay: {
        gift_amount: vars.currentOrder.order.totalPriceSet.shopMoney.amount,
        gift_date: if (vars.currentOrder.order.updatedAt != null and vars.currentOrder.order.updatedAt != "") (vars.currentOrder.order.updatedAt as DateTime as String {format: "yyyy-MM-dd'T'HH:mm:ssZ"})
                   else now() as DateTime as String {format: "yyyy-MM-dd'T'HH:mm:ssZ"},
        fmv: sum(vars.currentOrder.order.lineItems map( $.quantity * ($.product.variants.inventoryItem.unitCost[0] default 0.00 ) )),  
        transaction_fee_amount: ((paymentTransactions flatMap $.fees)[0].amount.amount)/100 default 0.00, //TO BE TESTED with proper data
        external_transaction_id: vars.currentOrder.order.id,
        exp_month: paymentTransactions[0].paymentDetails.expirationMonth default null,
        exp_year: paymentTransactions[0].paymentDetails.expirationYear default null,
        credit_card_type: paymentTransactions[0].paymentDetails.company default null,
        last_4: if (paymentTransactions[0].paymentDetails.number != null) paymentTransactions[0].paymentDetails.number[-4 to -1] else null,
        currency: vars.currentOrder.order.currencyCode,
        receipt_status: getReceiptStatus(),
        charge_status: "succeeded",
        paymethod_type: "Credit Card Stripe Visa"
    },
    marketing_tags: getChannels(vars.currentOrder.order.note default "", (vars.currentOrder.order.tags joinBy ",") default ""),
    line_items: vars.currentOrder.order.lineItems map ((lineItem, index) ->{
    
        sku: lineItem.sku,
        id: lineItem.id,
        variant_title: lineItem.variantTitle,
        price: lineItem.originalTotalSet.shopMoney.amount, //to be verified
        quantity: if(lineItem.quantity < 1) 1 else lineItem.quantity,

        "type": determineType(
            if ((lineItem.customAttributes filter ($.key == "Card Type"))[0] != null)
                (lineItem.customAttributes filter ($.key == "Card Type"))[0].value
            else "",
            (vars.currentOrder.order.tags joinBy ",") default ""
        ),

        sku_gau: getSkuGau(lineItem.product.variants[0].barcode),

       gau_amount: ((lineItem.originalTotalSet.shopMoney.amount default 0) as Number * if (lineItem.quantity < 1) 1 else lineItem.quantity) -
             ((lineItem.product.variants.inventoryItem.unitCost[0] default 0) as Number * if (lineItem.quantity < 1) 1 else lineItem.quantity) as String {format: "0.00"} //to be verified
    }),
    billing_address: {
        billing_street: buildAddressDetails(
            vars.currentOrder.order.billingAddress.address1 default "",
            vars.currentOrder.order.billingAddress.address2 default ""
        ),
        billing_city: vars.currentOrder.order.billingAddress.city,
        billing_state: vars.currentOrder.order.billingAddress.province,
        billing_postalcode: vars.currentOrder.order.billingAddress.zip,
        billing_country: vars.currentOrder.order.billingAddress.country
    },
    shipping_address: {
        shipping_street: buildAddressDetails(
            vars.currentOrder.order.shippingAddress.address1 default "",
            vars.currentOrder.order.shippingAddress.address2 default ""
        ),
        shipping_city: vars.currentOrder.order.shippingAddress.city,
        shipping_state: vars.currentOrder.order.shippingAddress.province,
        shipping_postalcode: vars.currentOrder.order.shippingAddress.zip,
        shipping_country: vars.currentOrder.order.shippingAddress.country,
        shipping_name:(buildShippingName(
            vars.currentOrder.order.shippingAddress.name default "",
            vars.currentOrder.order.shippingAddress.firstName default "",
            vars.currentOrder.order.shippingAddress.lastName default ""
        )
    ) replace "&" with "and"
    },
    sf_ids: {
        sf_campaign_id: getCampaignId()
    }

}
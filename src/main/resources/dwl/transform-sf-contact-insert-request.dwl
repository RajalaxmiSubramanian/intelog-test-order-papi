%dw 2.0
output application/json
var CurrencyIsoCode = upper(vars.giftJson.pay.currency)
fun determineStateandCountry(inputVal: String) = do {

    var trimmedInput = if (sizeOf(inputVal) >= 2) inputVal[0 to 1]  else inputVal  
    var inputValCode = if (inputVal == trimmedInput) inputVal else ""
    var inputValName = if (inputVal != trimmedInput) inputVal else  ""
---
    {
        inputVal_code: inputValCode,
        inputVal_name: inputValName
    }
}

fun getDefaultOwner(currencyIsoCode: String) = if(currencyIsoCode == "CAD") p('salesforce.ownerId.CAN') else p('salesforce.ownerId.USA')

var fullContact = {
    FirstName: vars.giftJson.person.first_name default "",
    LastName: vars.giftJson.person.last_name default "",

    Email: vars.giftJson.person.email default "",
    npe01_HomeEmail__c: vars.giftJson.person.email default "",

    Phone: vars.giftJson.person.phone default "",
    MobilePhone: vars.giftJson.person.phone default "",

    MailingStreet__c: vars.giftJson.person.street default "",
    MailingCity__c: vars.giftJson.person.city default "",
    MailingState__c: determineStateandCountry(vars.giftJson.person.state default "").inputVal_name,
    MailingStateCode__c: determineStateandCountry(vars.giftJson.person.state default "").inputVal_code,
    MailingPostalCode__c: vars.giftJson.person.postal_code default "",
    MailingCountry__c: determineStateandCountry(vars.giftJson.person.country default "").inputVal_name,
    MailingCountryCode__c: determineStateandCountry(vars.giftJson.person.country default "").inputVal_code,

    RecordTypeId__c: p('salesforce.contact.recordTypeId'),
    AccountId: p('salesforce.default.accountId'),

    
    Original_Created_Date__c: vars.giftJson.person.created_date default "",

    OwnerId: getDefaultOwner(upper(vars.giftJson.pay.currency default "")), // hardcoded for developer account

    CurrencyIsoCode__c: CurrencyIsoCode,
    Ways_to_Give__c: if(payload.person.email_optout == "0")"1" else "1"
}

var patchContact = {
    Ways_to_Give__c: if(payload.person.email_optout == "0")"1" else "1"
}
---
{
 Contact:
   if(vars.sfContactId != "")
      patchContact
   else
      fullContact
}
%dw 2.0
fun getOpportunityStatusInfo(chargeStatus) =
   
    (([{
    	Gateway_Status: "pending",
    	Opp_Stage: "Pending",
        Opp_PostStatus: "Do Not Post",
        RecordTypeId: "012o0000001AMWGAA4"
    },
    {
        Gateway_Status: "succeeded",
        Opp_Stage: "Closed Won",
        Opp_PostStatus: "Not Posted",
        RecordTypeId: "012o0000001AMWGAA4"
    },
    {
        Gateway_Status: "failed",
        Opp_Stage: "Closed Lost",
        Opp_PostStatus: "Do Not Post",
        RecordTypeId: "0121J000001DahGQAS"
    },
    {
        Gateway_Status: "Approved",
        Opp_Stage: "Closed Won",
        Opp_PostStatus: "Not Posted",
        RecordTypeId: "012o0000001AMWGAA4"
    },
    {
        Gateway_Status: "Refunded",
        Opp_Stage: "refunded",
        Opp_PostStatus: "Do Not Post",
        RecordTypeId: "0121J000001DahGQAS"
    },
    {
        Gateway_Status: "Refund",
        Opp_Stage: "refunded",
        Opp_PostStatus: "Do Not Post",
        RecordTypeId: "0121J000001DahGQAS"
    },
    {
        Gateway_Status: "refunded",
        Opp_Stage: "refunded",
        Opp_PostStatus: "Do Not Post",
        RecordTypeId: "0121J000001DahGQAS"
    },
    {
        Gateway_Status: "RE Received",
        Opp_Stage: "Closed Won",
        Opp_PostStatus: "Do Not Post",
        RecordTypeId: "012o0000001AMWGAA4"
    },
    {
        Gateway_Status: "ShopifyOrder",
        Opp_Stage: "Closed Won",
        Opp_PostStatus: "Not Posted",
        RecordTypeId: "012o0000000Ik8RAAS"
    }]) filter ((item) -> lower(item.Gateway_Status) == lower(chargeStatus)))[0] match {
        case statusRecord if (statusRecord != null) -> {
            StageName: statusRecord.Opp_Stage,
            Post_Status__c: statusRecord.Opp_PostStatus,
            RecordTypeId: statusRecord.RecordTypeId
        }
        else -> {
            StageName: "Qualification",
            Post_Status__c: "Not Posted",
            RecordTypeId: "012000000000000AAA"
        }
    }
    
    
fun getOpportunityType(eventType) = (([
    {
        EventType: "Single_Gift",
        Opportunity_Type: "Standard Gift"
    },
    {
        EventType: "Recurring_Gift",
        Opportunity_Type: "Recurring Gift"
    },
    {
        EventType: "Event Transaction",
        Opportunity_Type: "Standard Gift"
    },
    {
        EventType: "RE_Recurring_Gift",
        Opportunity_Type: "Recurring Gift"
    },
    {
        EventType: "eStore Card",
        Opportunity_Type: "eStore Card"
    }
]) filter ((item) -> lower(item.EventType) == lower(eventType)))[0].Opportunity_Type
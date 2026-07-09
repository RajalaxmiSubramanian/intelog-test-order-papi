%dw 2.0
fun getOrdersAndTransactionDetails() = 
"query orders(\$pageSize: Int!, \$queryString: String!) { 
    orders(first: \$pageSize, query: \$queryString) {
        edges {
            cursor
            node {
                    id
                    note
					email
					name
					updatedAt
					tags
					phone
					sourceName
					currencyCode
					customerAcceptsMarketing 
                    displayFinancialStatus
                    customAttributes{
                        key
                        value
                    }					
					totalPriceSet {
                        shopMoney {
                            amount
                        }
                    }
					customer {
                        displayName
                        firstName
                        lastName
                        id
                        createdAt
                        defaultAddress {
                            address1
                            address2
                            city
                            province
                            zip
                            country
                            phone
                        }
                        addressesV2(first: \$pageSize) {
                            edges{
                                node{
                                    address1
                                    address2
                                    city
                                    province
                                    zip
                                    country
                                    phone
                                }
                            }
                            
                        }                        
                    }
					lineItems(first: \$pageSize) {
                        edges {
                            node {
                              id
                              sku
                              variantTitle
                              quantity
							  variant{
                                id
                              }
                              product{
                                id
                              }
                              originalTotalSet{
                                shopMoney{
                                    amount
                                }
                              }
                            }
                        }
                    } 
					billingAddress {
                        address1
                        address2
                        city
                        province
                        zip
                        country
                    }
					shippingAddress {
                        address1
                        address2
                        city
                        province
                        zip
                        country
                        firstName
                        lastName
                        name
                    }
                    transactions(first:\$pageSize) {        
                        createdAt
                        errorCode
                        id
                        gateway
                        kind
                        receiptJson
                        status
                        test
						fees{
                            amount{
                                amount
                            }
                        }
                        paymentDetails{  
                           __typename
                            ... on CardPaymentDetails{
                                company
                                expirationMonth
                                expirationYear
                                number
                            } 
                        }
                        
                        parentTransaction {
                            id
                        }
                        order {
                            id
                        }
                        amountSet {
                        shopMoney {
                            amount
                            currencyCode
                        }
                        presentmentMoney{
                            amount
                        }
                        }  
                    }	
                } 
            } pageInfo { hasNextPage hasPreviousPage startCursor endCursor } 
        } 
}"
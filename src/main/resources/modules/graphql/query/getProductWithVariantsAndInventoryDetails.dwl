%dw 2.0
fun getProductWithVariantsAndInventoryDetails() = "query getProductWithVariantsAndInventoryDetails(\$productId: ID! , \$pageSize: Int!) {
	product(id: \$productId) {
		id
		title
		handle
		createdAt
		updatedAt
		productType
		publishedAt
		tags
		templateSuffix
		vendor
		options(first: \$pageSize) {
			name
			id
			position
			values
		}
		variants(first: \$pageSize) {
			edges {
				node {
					id
					title
					displayName
					sku
					price
					compareAtPrice
					availableForSale
					barcode
					createdAt
					updatedAt
					
					inventoryPolicy
					position
					taxable
                    selectedOptions {
                        value
                    }

					image {
						id
						url
						altText
					}
					inventoryItem {
						id
						sku
						tracked
						countryCodeOfOrigin
						createdAt
						updatedAt
                        requiresShipping
						unitCost {
							amount
						}
                        measurement {
                            weight {
                                value
                                unit
                            }
                        }
					}
					product {
						id
						title
						handle
					}
				}
			}
		}
	}
}"
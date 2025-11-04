# Delivery Information Integration

## Overview
The `CreateOrder` and `UpdateOrder` mutations now support delivery information. When creating or updating an order, you can optionally include delivery details that will be:
- Saved to the database
- Included in payment confirmation emails
- Associated with both the order and user

## CreateOrder Mutation

### New Arguments
All delivery fields are optional:
- `country: String` - Country name
- `province: String` - Province/State
- `city: String` - City name
- `street: String` - Street address
- `branggay: String` - Barangay/District
- `unit: String` - Unit number
- `floor: String` - Floor number
- `building: String` - Building name
- `landmark: String` - Nearby landmark
- `remarks: String` - Special delivery instructions

### Example Usage

```graphql
mutation CreateOrderWithDelivery {
  createOrder(
    productId: "1"
    orderQuantity: 2
    paymentMethod: "Cash on Delivery"
    # Delivery Information
    country: "Philippines"
    province: "Metro Manila"
    city: "Quezon City"
    street: "123 Aurora Blvd"
    branggay: "Barangay South Triangle"
    unit: "Unit 5A"
    floor: "5th Floor"
    building: "Sunrise Tower"
    landmark: "Near Quezon Memorial Circle"
    remarks: "Please call upon arrival"
  ) {
    order {
      id
      orderQuantity
      totalAmount
      paymentMethod
      user {
        firstName
        lastName
      }
    }
    errors
  }
}
```

### Minimal Example (Order Only)
```graphql
mutation CreateOrderMinimal {
  createOrder(
    productId: "1"
    orderQuantity: 1
  ) {
    order {
      id
      totalAmount
    }
    errors
  }
}
```

## UpdateOrder Mutation

### New Arguments
Same delivery fields as CreateOrder (all optional)

### Example Usage

```graphql
mutation UpdateOrderWithDelivery {
  updateOrder(
    id: "13"
    status: PENDING
    # Add or update delivery information
    country: "Philippines"
    province: "Metro Manila"
    city: "Manila"
    street: "456 Rizal Avenue"
    branggay: "Barangay 123"
    landmark: "Near City Hall"
    remarks: "Weekday delivery preferred"
  ) {
    order {
      id
      status
      totalAmount
    }
    errors
  }
}
```

## Behavior

### CreateOrder
- If **any** delivery field is provided, a `Delivery` record is created
- Both `Order` and `Delivery` are saved in a database transaction
- If delivery save fails, the entire transaction rolls back (no order is created)

### UpdateOrder
- Finds or creates a `Delivery` record associated with the order
- Updates only the delivery fields that are provided (sparse update)
- Existing delivery data is preserved if not explicitly updated
- Uses database transaction to ensure consistency

## Email Integration

When sending payment confirmation emails via the `sendOrderEmails` mutation, the delivery information is automatically included:

```
🚚 Delivery Information
Address:
  5th Floor, Unit 5A, Sunrise Tower
  123 Aurora Blvd, Barangay South Triangle
  Quezon City, Metro Manila
  Philippines
Landmark: Near Quezon Memorial Circle
Remarks: Please call upon arrival
```

## Database Schema

The `deliveries` table includes:
- `order_id` - Foreign key to orders
- `user_id` - Foreign key to users
- `country` - String
- `province` - String
- `city` - String
- `street` - String
- `branggay` - String
- `unit` - String
- `floor` - String
- `building` - String
- `landmark` - String
- `remarks` - String
- `created_at` - Timestamp
- `updated_at` - Timestamp

## Frontend Integration

### Vue Example (CreateOrder with Delivery)

```javascript
const createOrderWithDelivery = async (orderData, deliveryData) => {
  const mutation = `
    mutation CreateOrder(
      $productId: ID!,
      $orderQuantity: Int!,
      $paymentMethod: String,
      $country: String,
      $province: String,
      $city: String,
      $street: String,
      $branggay: String,
      $unit: String,
      $floor: String,
      $building: String,
      $landmark: String,
      $remarks: String
    ) {
      createOrder(
        productId: $productId
        orderQuantity: $orderQuantity
        paymentMethod: $paymentMethod
        country: $country
        province: $province
        city: $city
        street: $street
        branggay: $branggay
        unit: $unit
        floor: $floor
        building: $building
        landmark: $landmark
        remarks: $remarks
      ) {
        order {
          id
          totalAmount
          paymentMethod
        }
        errors
      }
    }
  `;

  const variables = {
    productId: orderData.productId,
    orderQuantity: orderData.orderQuantity,
    paymentMethod: orderData.paymentMethod,
    ...deliveryData // spread delivery fields
  };

  const response = await fetch('http://localhost:3000/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ query: mutation, variables })
  });

  return response.json();
};

// Usage
const result = await createOrderWithDelivery(
  {
    productId: '1',
    orderQuantity: 2,
    paymentMethod: 'Cash on Delivery'
  },
  {
    country: 'Philippines',
    province: 'Metro Manila',
    city: 'Quezon City',
    street: '123 Aurora Blvd',
    branggay: 'Barangay South Triangle',
    unit: '5A',
    floor: '5th',
    building: 'Sunrise Tower',
    landmark: 'Near QC Circle',
    remarks: 'Call before delivery'
  }
);
```

## Testing

### Test CreateOrder with Delivery
```bash
cd /home/lorieta/POS
rails console
```

```ruby
# In Rails console
user = User.first
product = Product.first

# GraphQL context
context = { current_user: user }

# Execute mutation
result = PosSchema.execute(
  "mutation {
    createOrder(
      productId: \"#{product.id}\"
      orderQuantity: 2
      country: \"Philippines\"
      city: \"Manila\"
      street: \"Test St\"
    ) {
      order { id }
      errors
    }
  }",
  context: context
)

puts result.to_json

# Verify delivery was created
order = Order.last
delivery = Delivery.find_by(order_id: order.id)
puts delivery.inspect
```

## Notes

- All delivery fields are **optional**
- Delivery is only created if at least one field has a value
- The delivery record is linked to both the order and the user
- Use `UpdateOrder` to add delivery information to existing orders
- Email templates automatically show delivery info when available

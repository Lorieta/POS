module Types
  class OrderStatusEnum < Types::BaseEnum
    value "PENDING", value: "pending"
    value "FOR_DELIVERY", value: "for_delivery"
    value "COMPLETED", value: "completed"
    value "CANCELLED", value: "cancelled"
    value "REFUND", value: "refund"
  end
end

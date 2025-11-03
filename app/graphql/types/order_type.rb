module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :order_date, GraphQL::Types::ISO8601Date, null: true
    field :order_quantity, Integer, null: true
    field :payment_method, String, null: true
    field :product, Types::ProductType, null: false
    field :user, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :product_photo, String, null: true
    field :product_price, Float, null: true
    field :product_type, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

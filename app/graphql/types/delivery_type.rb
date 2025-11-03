module Types
  class DeliveryType < Types::BaseObject
    field :id, ID, null: false
    field :branggay, String, null: true
    field :building, String, null: true
    field :city, String, null: true
    field :country, String, null: true
    field :floor, String, null: true
    field :landmark, String, null: true
    field :order, Types::OrderType, null: false
    field :province, String, null: true
    field :remarks, String, null: true
    field :street, String, null: true
    field :unit, String, null: true
    field :user, Types::UserType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

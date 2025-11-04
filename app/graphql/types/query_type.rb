# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :users, [ Types::UserType ], null: false, description: "Returns a list of users"
    field :products, [ Types::ProductType ], null: false, description: "Returns a list of products"
    field :orders, [ Types::OrderType ], null: false, description: "Returns a list of products"
    field :all_products, [ Types::ProductType ], null: false, description: "Returns all products"
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def users
      User.where(status: "user")
    end

    def products
      Product.includes(:user)
    end

    def orders
      Order.all
    end

    def all_products
      Product.all
    end
  end
end

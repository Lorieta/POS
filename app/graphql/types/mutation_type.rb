# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # TODO: remove me
    field :create_user, mutation: Mutations::CreateUser
    field :sigin_in_user, mutation: Mutations::SignInUser
    field :logout_user, mutation: Mutations::LogoutUser
    field :create_product, mutation: Mutations::CreateProduct
    field :create_direct_upload, mutation: Mutations::CreateDirectUpload
    field :update_product, mutation: Mutations::UpdateProduct
    field :create_order, mutation: Mutations::CreateOrder
  end
end

# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
  # TODO: remove me
  field :create_user, mutation: Mutations::CreateUser
  field :sign_in_user, mutation: Mutations::SignInUser
    field :logout_user, mutation: Mutations::LogoutUser
    field :create_product, mutation: Mutations::CreateProduct
    field :create_direct_upload, mutation: Mutations::CreateDirectUpload
    field :update_product, mutation: Mutations::UpdateProduct
    field :create_order, mutation: Mutations::CreateOrder
    field :update_order, mutation: Mutations::UpdateOrder
    field :send_payment_confirmation, mutation: Mutations::SendPaymentConfirmation
    field :send_order_emails, mutation: Mutations::SendOrderEmails
  end
end

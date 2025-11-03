module Mutations
  class CreateUser < BaseMutation
    # We'll use the input object type we defined earlier.
    # This keeps the mutation's argument list clean.
    argument :credentials, Types::AuthProviderCredentialsInput, required: true

    # The mutation will return a UserType
    type Types::UserType

    def resolve(credentials:)
  user_attributes = credentials.to_h
  user_attributes[:status] ||= User.statuses.fetch("user")
      User.create!(user_attributes)
    end
  end
end

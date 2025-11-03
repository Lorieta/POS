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
        user = User.new(user_attributes)
        user.save!
        user
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError.new(
          e.record.errors.full_messages.to_sentence,
          extensions: {
            code: "USER_INPUT_ERROR",
            attributes: e.record.errors.to_hash(true)
          }
        )
    end
  end
end

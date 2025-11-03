module Mutations
  class SignInUser < BaseMutation
    null true

    # For sign-in we only need email + password (no large input object)
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(email:, password:)
      user = User.find_by(email: email)

      raise build_error("Account does not exist") unless user
      raise build_error("Incorrect password") unless user.authenticate(password)

      # use ActiveSupport::MessageEncryptor to build a token
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base.byteslice(0..31))
      token = crypt.encrypt_and_sign("user-id:#{user.id}")

      { user: user, token: token }
    end

    private

    def build_error(message)
      GraphQL::ExecutionError.new(
        message,
        extensions: {
          code: "AUTHENTICATION_ERROR"
        }
      )
    end
  end
end

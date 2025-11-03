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

      # ensure we have the correct user and the password matches
      return unless user
      return unless user.authenticate(password)

      # use ActiveSupport::MessageEncryptor to build a token
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base.byteslice(0..31))
      token = crypt.encrypt_and_sign("user-id:#{user.id}")

      { user: user, token: token }
    end
  end
end

module Types
  # Corrected class name
  class AuthProviderCredentialsInput < Types::BaseInputObject
    graphql_name "AUTH_PROVIDER_CREDENTIALS"

    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    # Use :password, not :password_digest
    argument :password, String, required: true
    # It's also best practice to include a password_confirmation field
    argument :password_confirmation, String, required: true
    argument :phone_number, String, required: true
    argument :status, String, required: false
  end
end

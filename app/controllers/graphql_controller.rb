# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # Use null_session for API endpoints so requests from external clients
  # (cURL, mobile apps, or third-party clients) that don't include the
  # Rails CSRF authenticity token are handled safely.
  # For API access we treat GraphQL as an API endpoint. We nullify the session
  # to avoid raising on missing CSRF tokens, and explicitly skip the
  # verify_authenticity_token before_action so Rails doesn't log the
  # "Can't verify CSRF token authenticity" message for token-authenticated
  # requests. Authentication is handled via the Authorization header.
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      request: request,
      url_options: { host: request.host, port: request.port, protocol: request.protocol },
      current_user: current_user_from_token
    }

    result = ActiveStorage::Current.set(url_options: context[:url_options]) do
      PosSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    end
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [ { message: e.message, backtrace: e.backtrace } ], data: {} }, status: 500
  end

  def current_user_from_token
    auth_header = request.headers["Authorization"]
    return nil unless auth_header.present?

    scheme, token = auth_header.split(" ", 2)
    return nil unless scheme == "Bearer" && token.present?

    key_base = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
    return nil unless key_base.present?

    crypt = ActiveSupport::MessageEncryptor.new(key_base.byteslice(0..31))
    decrypted = crypt.decrypt_and_verify(token)
    user_id = decrypted.split(":").last
    User.find_by(id: user_id)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage, ArgumentError
    nil
  end
end

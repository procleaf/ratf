module ApiAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_request!
  end

  private

  def authenticate_api_request!
    token = request.headers["Authorization"]&.gsub("Bearer ", "")
    unless token && valid_token?(token)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def valid_token?(token)
    t = ApiToken.active.find_by("token_digest IS NOT NULL")
    return false unless t
    BCrypt::Password.new(t.token_digest) == token
  rescue BCrypt::Errors::InvalidHash
    false
  end
end

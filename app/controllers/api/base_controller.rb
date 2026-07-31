module Api
  class BaseController < ActionController::API
    include ApiAuthenticable
  end
end

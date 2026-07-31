module Api
  module V1
    class HealthController < Api::BaseController
      skip_before_action :authenticate_api_request!

      def show
        db_ok = begin; ActiveRecord::Base.connection.active?; rescue; false; end
        render json: {
          status: db_ok ? "healthy" : "degraded",
          version: "1.0.0",
          timestamp: Time.now.iso8601,
          jobs_running: Job.where(status: :running).count
        }
      end
    end
  end
end

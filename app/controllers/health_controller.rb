class HealthController < ApplicationController
  # Enhanced health check — returns JSON with system status
  def show
    db_ok = begin
      ActiveRecord::Base.connection.active?
    rescue => e
      false
    end


    render json: {
      status: db_ok ? "healthy" : "degraded",
      timestamp: Time.now.iso8601,
      database: db_ok ? "connected" : "error",
      },
      jobs: {
        running: Job.where(status: :running).count,
        queued: Job.where(status: :queued).count
      },
      cloud: {
        providers: CloudProvider.connected.count,
        instances: CloudInstance.running.count
      },
      version: "1.0.0"
    }
  end
end

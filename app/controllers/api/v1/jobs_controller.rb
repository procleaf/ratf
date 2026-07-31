module Api
  module V1
    class JobsController < Api::BaseController
      def index
        jobs = Job.recent.limit(params[:limit] || 20)
        render json: jobs.as_json(include: :created_by, methods: [:success_rate, :progress_percentage])
      end

      def show
        job = Job.find(params[:id])
        render json: job.as_json(
          methods: [:success_rate, :progress_percentage, :total_runtime]
        )
      end

      def create
        job = Job.new(job_params)
        job.created_by = current_api_user
        if job.save
          render json: job, status: :created
        else
          render json: { errors: job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def current_api_user
        @current_api_user ||= User.first # fallback
      end

      def job_params
        params.require(:job).permit(:name, :description, :priority, definition: {})
      end
    end
  end
end

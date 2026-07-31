module Api
  module V1
    class ResultsController < Api::BaseController
      def index
        results = TestResult.order(created_at: :desc).limit(params[:limit] || 50)
        results = results.where(status: params[:status]) if params[:status]
        render json: results.as_json(include: { test_case: { only: [:id, :name] }, test_suite: { only: [:id, :name] } })
      end

      def show
        result = TestResult.find(params[:id])
        render json: result.as_json(include: [:test_case, :test_suite, :job_run])
      end
    end
  end
end

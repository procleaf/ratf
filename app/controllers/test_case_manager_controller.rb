class TestCaseManagerController < ApplicationController
  include RatfController

  before_action :set_suite, only: %i[editor export import_preview import clone batch_edit batch_update]

  # ── Editor ──────────────────────────────────────────────────
  def index
    @suites = TestSuite.includes(:project).order(name: :asc)
  end

  def editor
    @test_cases = @suite.test_cases.order(name: :asc)
  end

  # ── Batch Edit ──────────────────────────────────────────────
  def batch_edit
    @test_cases = @suite.test_cases.order(name: :asc)
  end

  def batch_update
    count = 0
    params[:test_cases]&.each do |id, attrs|
      tc = @suite.test_cases.find_by(id: id)
      next unless tc
      tc.update!(
        name: attrs[:name],
        description: attrs[:description],
        priority: attrs[:priority],
        test_type: attrs[:test_type],
        definition: {
          steps: attrs[:steps].to_s.split("\n").map(&:strip).reject(&:empty?),
          preconditions: attrs[:preconditions].to_s.split("\n").map(&:strip).reject(&:empty?),
          expected_results: attrs[:expected_results].to_s.split("\n").map(&:strip).reject(&:empty?)
        }
      )
      count += 1
    end
    redirect_to editor_test_case_manager_index_path(suite_id: @suite.id), notice: "#{count} test case(s) updated."
  end

  # ── Export ──────────────────────────────────────────────────
  def export
    yaml = @suite.export_yaml
    send_data yaml,
      filename: "#{@suite.name.parameterize}-#{@suite.version}.yml",
      type: "application/x-yaml",
      disposition: "attachment"
  end

  # ── Import ──────────────────────────────────────────────────
  def import_preview
    if request.post?
      yaml = params[:yaml_content].to_s
      if yaml.present?
        @parsed = begin
          YAML.safe_load(yaml, permitted_classes: [Symbol])
        rescue => e
          nil
        end
        if @parsed.is_a?(Hash) && @parsed["test_cases"].present?
          @preview = @parsed
          session[:import_yaml] = yaml
          session[:import_suite_id] = @suite.id
        else
          flash.now[:alert] = "Invalid YAML format. Expected test_cases array."
        end
      end
    end
  end

  def import
    yaml = session[:import_yaml]
    suite = TestSuite.find_by(id: session[:import_suite_id])
    if yaml.present? && suite
      count = suite.import_from_yaml!(yaml, user: current_user)
      session.delete(:import_yaml)
      session.delete(:import_suite_id)
      redirect_to editor_test_case_manager_index_path(suite_id: suite.id), notice: "#{count} test case(s) imported."
    else
      redirect_to test_case_manager_index_path, alert: "Import failed."
    end
  end

  # ── Clone ───────────────────────────────────────────────────
  def clone
    new_suite = @suite.clone_with_cases!(
      name: params[:new_name].presence || "#{@suite.name} (Copy)",
      user: current_user
    )
    redirect_to test_case_manager_index_path, notice: "Suite cloned as '#{new_suite.name}' with #{new_suite.test_cases.count} case(s)."
  rescue => e
    redirect_to test_case_manager_index_path, alert: "Clone failed: #{e.message}"
  end

  private

  def set_suite
    @suite = TestSuite.find(params[:suite_id])
  end
end

src = File.read("app/controllers/cloud_providers_controller.rb")
src.sub!("  private\n", "  def ecs_run\n    tc = TestCase.find(params[:test_case_id])\n    provider = CloudProvider.find(params[:id])\n    result = EcsTestExecutor.run(test_case: tc, cloud_provider: provider)\n    if result&.status == \"passed\"\n      redirect_to tc, notice: \"ECS test passed in #{result.duration_seconds}s.\"\n    else\n      redirect_to tc, alert: \"ECS test failed.\"\n    end\n  rescue => e\n    redirect_to test_cases_path, alert: \"ECS error: #{e.message}\"\n  end\n\n  private\n")
File.write("app/controllers/cloud_providers_controller.rb", src)
puts "Done: #{File.read("app/controllers/cloud_providers_controller.rb").include?("ecs_run")}"

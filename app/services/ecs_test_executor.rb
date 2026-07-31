# frozen_string_literal: true
# Spins up an Aliyun ECS instance, runs a test case on it, and tears it down.
# This is the full lifecycle: provision → execute → collect results → terminate.
class EcsTestExecutor
  Result = Struct.new(:instance_id, :status, :test_result, :logs, :duration_seconds, :cost, keyword_init: true)

  # Run a test case on a freshly created Aliyun ECS instance.
  # Returns a Result struct with all execution data.
  def self.run(test_case:, cloud_provider:)
    config = cloud_provider.config || {}
    client = AliyunEcsClient.new(
      access_key: config["access_key"],
      secret_key: config["secret_key"],
      region: cloud_provider.region
    )

    start_time = Time.current
    instance = nil
    result_data = nil

    begin
      # Phase 1: Provision
      instance = create_test_instance(client, test_case)
      AuditLog.track!(nil, "ecs.provision", instance, changes: instance)

      # Phase 2: Wait for running
      wait_for_running(client, instance[:instance_id])

      # Phase 3: Execute test via SSH
      test_result = execute_remote_test(instance, test_case)

      # Phase 4: Collect logs
      log_content = build_log(test_case, instance, test_result, start_time)

      result_data = Result.new(
        instance_id: instance[:instance_id],
        status: test_result[:passed] ? "passed" : "failed",
        test_result: test_result,
        logs: log_content,
        duration_seconds: (Time.current - start_time).round,
        cost: estimate_cost(instance[:instance_type], (Time.current - start_time).round)
      )
    ensure
      # Phase 5: Terminate instance (always cleanup)
      begin
        client.stop_instance(instance[:instance_id]) if instance
      rescue => e
        Rails.logger.warn "Failed to terminate ECS #{instance&.dig(:instance_id)}: #{e.message}"
      end
    end

    # Persist results to RATF
    if result_data
      TestResult.create!(
        name: "#{test_case.name} — ECS Run",
        test_case: test_case,
        test_suite: test_case.test_suite,
        status: result_data.status == "passed" ? :passed : :failed,
        execution_time: result_data.duration_seconds,
        message: result_data.test_result[:output] || result_data.test_result[:error],
        metadata: {
          runner: "aliyun_ecs",
          instance_id: result_data.instance_id,
          cost: result_data.cost,
          public_ip: instance&.dig(:public_ip)
        },
        started_at: start_time,
        ended_at: Time.current
      )
      Log.create!(content: result_data.logs)
    end

    result_data
  end

  private

  def self.create_test_instance(client, test_case)
    specs = test_case.definition&.dig("ecs_specs") || {}
    client.create_instance(
      instance_name: "ratf-test-#{test_case.id}-#{Time.current.to_i}",
      instance_type: specs["instance_type"] || "ecs.t6-c1m1.large",
      image_id: specs["image_id"] || "centos_7_9_x64_20G_alibase_20220125.vhd",
      security_group_id: specs["security_group_id"] || "",
      vswitch_id: specs["vswitch_id"] || ""
    )
  rescue => e
    raise "Failed to create ECS instance: #{e.message}"
  end

  def self.wait_for_running(client, instance_id, timeout: 120)
    deadline = Time.current + timeout.seconds
    loop do
      instances = client.describe_instances
      inst = instances.find { |i| i[:instance_id] == instance_id }
      return if inst&.dig(:status) == :running
      raise "Instance #{instance_id} in failed state: #{inst&.dig(:status)}" if inst&.dig(:status) == :unknown
      raise "Timeout waiting for instance #{instance_id}" if Time.current > deadline
      sleep 5
    end
  end

  def self.execute_remote_test(instance, test_case)
    steps = Array(test_case.definition&.dig("steps") || test_case.definition&.dig(:steps))
    ip = instance[:public_ip] || instance[:private_ip]
    return { passed: false, error: "No IP available" } unless ip

    output_lines = []
    passed = true

    steps.each do |step|
      result = TestCaseRunner.run_command(step)
      output_lines << "$ #{step}"
      output_lines << "  stdout: #{result.stdout}" if result.stdout.present?
      output_lines << "  stderr: #{result.stderr}" if result.stderr.present?
      output_lines << "  exit: #{result.exit_code}"
      passed = false unless result.exit_code == 0
    end

    { passed: passed, output: output_lines.join("\n"), ip: ip }
  end

  def self.build_log(test_case, instance, test_result, start_time)
    lines = []
    lines << "=== ECS Test Execution ==="
    lines << "Test Case: #{test_case.name} (##{test_case.id})"
    lines << "Instance: #{instance[:instance_id]} | Type: #{instance[:instance_type]}"
    lines << "IP: #{instance[:public_ip] || instance[:private_ip]}"
    lines << "Started: #{start_time}"
    lines << "Duration: #{(Time.current - start_time).round}s"
    lines << ""
    lines << test_result[:output] if test_result[:output]
    lines << test_result[:error] if test_result[:error]
    lines << "=== #{test_result[:passed] ? 'PASSED' : 'FAILED'} ==="
    lines.join("\n")
  end

  def self.estimate_cost(instance_type, seconds)
    rates = { "ecs.t6-c1m1.large" => 0.02, "ecs.t6-c1m2.large" => 0.03, "ecs.t5-lc1m2.large" => 0.05 }
    rate = rates[instance_type] || 0.03
    ((seconds / 60.0 + 1) * rate).round(4)
  end
end

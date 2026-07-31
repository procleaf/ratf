#!/usr/bin/env ruby
# frozen_string_literal: true
# RATF CLI — Thor-based command-line interface
require "thor"
require_relative "ratf_cli/formatting"

class RatfCli < Thor
  include RatfCli::Formatting
  package_name "RATF"

  def self.exit_on_failure?; true; end

  desc "dashboard", "Show dashboard summary"
  def dashboard
    stats = DashboardStat.get_stats
    puts color("RATF Dashboard", :bold)
    puts
    kv({
      "Total Jobs"   => stats[:total_jobs],
      "Running"      => color(stats[:running_jobs].to_s, :blue),
      "Queued"       => color(stats[:queued_jobs].to_s, :yellow),
      "Workers"      => "#{color(stats[:active_workers].to_s, :green)} / #{stats[:total_workers]} active",
      "Success Rate" => "#{stats[:success_rate]}%",
      "Avg Duration" => "#{stats[:avg_duration] || '—'}s"
    })

    # Recent activity
    if stats[:recent_activity].any?
      section "Recent Activity"
      activity = stats[:recent_activity].first(5)
      table %w[Job Status Duration], activity.map { |r|
        [truncate(r[:job_name], 30), status(r[:status]), r[:duration] ? "#{r[:duration]}s" : "—"]
      }
    end

    # Flaky tests
    flaky = stats[:flaky_tests].select { |t| t[:pass_rate] < 90 }
    if flaky.any?
      section "Flaky Tests"
      table %w[Test Pass% Runs], flaky.first(5).map { |t|
        [truncate(t[:name], 40), color("#{t[:pass_rate]}%".rjust(6), t[:pass_rate] >= 80 ? :yellow : :red), t[:total_runs].to_s]
      }
    end
  end

  # ── Jobs ──────────────────────────────────────────────────
  desc "jobs", "List recent jobs"
  option :limit, type: :numeric, default: 20, aliases: "-n"
  option :status, type: :string, aliases: "-s"
  def jobs
    scope = Job.recent
    scope = scope.by_status(options[:status]) if options[:status]
    records = scope.limit(options[:limit])

    heading "Jobs (#{records.size})"
    table %w[ID Name Status Priority Created], records.map { |j|
      [j.id.to_s, truncate(j.name, 30), status(j.status), j.priority.humanize, j.created_at.strftime("%m-%d %H:%M")]
    }
  end

  desc "jobs:show ID", "Show job details"
  def jobs_show(id)
    j = Job.find(id)
    kv({
      "ID"          => j.id,
      "Name"        => j.name,
      "Description" => j.description || "—",
      "Status"      => status(j.status),
      "Priority"    => j.priority.humanize,
      "Created By"  => j.created_by&.username || "—",
      "Success Rate"=> "#{j.success_rate}%",
      "Avg Runtime" => j.average_runtime ? "#{j.average_runtime}s" : "—",
      "Created"     => j.created_at.strftime("%Y-%m-%d %H:%M"),
      "Started"     => j.started_at&.strftime("%Y-%m-%d %H:%M") || "—",
      "Completed"   => j.completed_at&.strftime("%Y-%m-%d %H:%M") || "—",
    })

    if j.job_runs.any?
      section "Job Runs"
      table %w[ID Worker Status Duration], j.job_runs.order(created_at: :desc).map { |r|
        [r.id.to_s, r.worker&.name || "—", status(r.status), r.duration ? "#{r.duration}s" : "—"]
      }
    end
  end

  desc "jobs:create", "Create a new job (interactive)"
  def jobs_create
    puts color("Create New Job", :bold)
    name = ask("Name:")
    desc = ask("Description:")
    priority = ask("Priority (low/normal/high/critical):", default: "normal")
    steps = ask("Steps (comma-separated):", default: "")

    job = Job.create!(
      name: name,
      description: desc,
      priority: priority,
      definition: { steps: steps.split(",").map(&:strip).reject(&:empty?) },
      created_by: User.first
    )
    puts color("✓ Job ##{job.id} created: #{job.name}", :green)
  rescue => e
    puts color("✗ #{e.message}", :red)
  end

  # ── Workers ───────────────────────────────────────────────
  desc "workers", "List workers"
  def workers
    records = Worker.order(:status, :name)
    heading "Workers (#{records.size})"
    table %w[ID Name Host Status Parallel Heartbeat], records.map { |w|
      [
        w.id.to_s, w.name, w.host,
        status(w.status),
        w.parallel_jobs.to_s,
        w.last_heartbeat_at ? "#{((Time.now - w.last_heartbeat_at) / 60).round}m ago" : "never"
      ]
    }
  end

  # ── Test Suites ───────────────────────────────────────────
  desc "suites", "List test suites"
  def suites
    records = TestSuite.order(:name)
    heading "Test Suites (#{records.size})"
    table %w[ID Name Version Status Cases], records.map { |s|
      [s.id.to_s, truncate(s.name, 30), s.version || "—", status(s.status), s.test_cases.count.to_s]
    }
  end

  desc "suites:show ID", "Show test suite with cases"
  def suites_show(id)
    s = TestSuite.find(id)
    kv({
      "Name"        => s.name,
      "Version"     => s.version || "—",
      "Status"      => status(s.status),
      "Project"     => s.project&.name || "—",
      "Test Cases"  => s.test_cases.count,
      "Success Rate"=> "#{s.success_rate}%",
      "Last Run"    => s.last_run ? "#{s.last_run.created_at.strftime("%Y-%m-%d %H:%M")}" : "never"
    })

    if s.test_cases.any?
      section "Test Cases"
      table %w[ID Name Type Priority Status], s.test_cases.map { |tc|
        [tc.id.to_s, truncate(tc.name, 35), tc.test_type.humanize, tc.priority.humanize, status(tc.status)]
      }
    end
  end

  # ── Test Results ──────────────────────────────────────────
  desc "results", "Recent test results"
  option :limit, type: :numeric, default: 20, aliases: "-n"
  option :status, type: :string, aliases: "-s"
  def results
    scope = TestResult.order(created_at: :desc)
    scope = scope.where(status: options[:status]) if options[:status]
    records = scope.limit(options[:limit])

    heading "Test Results (#{records.size})"
    table %w[ID Name Status Time Suite], records.map { |r|
      [
        r.id.to_s, truncate(r.name, 30),
        status(r.status),
        r.execution_time ? "#{r.execution_time}s" : "—",
        truncate(r.test_suite&.name || "—", 20)
      ]
    }
  end

  desc "results:failed", "Show recent failures"
  def results_failed
    records = TestResult.where(status: [:failed, :error]).order(created_at: :desc).limit(20)
    heading "Recent Failures (#{records.size})"
    records.each do |r|
      puts "  #{color("✗", :red)} #{r.name}"
      puts "     #{color(r.message, :gray)}" if r.message.present?
      puts "     Suite: #{r.test_suite&.name} | #{r.created_at.strftime("%Y-%m-%d %H:%M")}"
      puts
    end
  end

  # ── Issues ────────────────────────────────────────────────
  desc "issues", "List open issues"
  def issues
    records = Issue.open_issues.order(severity: :desc, created_at: :desc).limit(20)
    heading "Open Issues (#{records.size})"
    table %w[ID Title Severity Assigned], records.map { |i|
      [i.id.to_s, truncate(i.title, 40), status(i.severity), i.assigned_to&.username || "unassigned"]
    }
  end

  # ── Health ────────────────────────────────────────────────
  desc "health", "System health check"
  def health
    db_ok = begin; ActiveRecord::Base.connection.active?; rescue; false; end
    puts color("System Health", :bold)
    puts
    kv({
      "Database"  => db_ok ? color("✓ connected", :green) : color("✗ error", :red),
      "Workers"   => "#{Worker.where(status: [:idle, :busy]).count} active / #{Worker.count} total",
      "Jobs"      => "#{color(Job.where(status: :running).count.to_s, :blue)} running, #{color(Job.where(status: :queued).count.to_s, :yellow)} queued",
      "Cloud"     => "#{CloudProvider.connected.count} providers, #{CloudInstance.running.count} instances",
      "DB Size"   => "#{ActiveRecord::Base.connection.tables.size} tables"
    })
  end

  # ── Cloud ─────────────────────────────────────────────────
  desc "cloud", "Cloud providers and instances"
  def cloud
    heading "Cloud Providers"
    providers = CloudProvider.all
    if providers.any?
      table %w[ID Name Type Region Status Instances Cost/mo], providers.map { |p|
        [
          p.id.to_s, p.name, p.provider_type.upcase, p.region,
          status(p.status),
          p.cloud_instances.count.to_s,
          "$#{sprintf("%.2f", p.monthly_estimated_cost)}"
        ]
      }
    else
      puts color("  No providers configured.", :gray)
    end

    heading "Cloud Instances"
    instances = CloudInstance.running.recent.limit(10)
    if instances.any?
      table %w[ID Name Type Status IP Cost/hr], instances.map { |ci|
        [
          ci.id.to_s, ci.name, ci.instance_type,
          status(ci.status),
          ci.public_ip || "—",
          "$#{sprintf("%.4f", ci.hourly_cost || 0)}"
        ]
      }
    else
      puts color("  No running instances.", :gray)
    end
  end

  # ── Stats ─────────────────────────────────────────────────
  desc "stats", "Quick statistics overview"
  def stats
    puts color("RATF Stats", :bold)
    puts
    kv({
      "Jobs"        => "#{Job.count} total, #{Job.where(status: :running).count} running, #{Job.where(status: :queued).count} queued",
      "Job Runs"    => "#{JobRun.count} total, #{JobRun.where(status: :completed).count} completed, #{JobRun.where(status: :failed).count} failed",
      "Workers"     => "#{Worker.count} total, #{Worker.where(status: :idle).count} idle, #{Worker.where(status: :busy).count} busy",
      "Test Cases"  => TestCase.count,
      "Test Results"=> "#{TestResult.count} total, #{TestResult.where(status: :passed).count} passed, #{TestResult.where(status: :failed).count} failed",
      "Issues"      => "#{Issue.count} total, #{Issue.open_issues.count} open",
      "Schedules"   => Schedule.count,
      "Cloud"       => "#{CloudProvider.count} providers, #{CloudInstance.count} instances"
    })
  end

  # ── Schedules ─────────────────────────────────────────────
  desc "schedules", "List scheduled jobs"
  def schedules
    records = Schedule.includes(:job).order(:name)
    heading "Schedules (#{records.size})"
    table %w[ID Name Job Cron Enabled Next Run], records.map { |s|
      [
        s.id.to_s, truncate(s.name, 25), truncate(s.job&.name || "—", 20),
        s.cron_expression, s.enabled? ? color("yes", :green) : color("no", :gray),
        s.next_run_at&.strftime("%Y-%m-%d %H:%M") || "—"
      ]
    }
  end

  # ── Search ────────────────────────────────────────────────
  desc "search QUERY", "Search across jobs, tests, issues"
  def search(query)
    like = "%#{query}%"
    results = {
      "Jobs"        => Job.where("name LIKE ?", like).limit(5),
      "Test Suites" => TestSuite.where("name LIKE ?", like).limit(5),
      "Test Cases"  => TestCase.where("name LIKE ?", like).limit(5),
      "Issues"      => Issue.where("title LIKE ?", like).limit(5),
      "Workers"     => Worker.where("name LIKE ?", like).limit(5),
    }

    total = results.values.sum(&:count)
    heading "Search: \"#{query}\" (#{total} results)"

    results.each do |label, records|
      next if records.empty?
      section "#{label} (#{records.size})"
      records.each do |r|
        name = r.respond_to?(:title) ? r.title : r.name
        puts "  #{color("##{r.id}", :gray)} #{name}"
      end
    end

    puts color("\n  No results found.", :gray) if total == 0
  end

  private

  def truncate(str, len)
    return "" unless str
    str.length > len ? "#{str[0...len-3]}..." : str
  end
end

RatfCli.start(ARGV) if __FILE__ == $PROGRAM_NAME

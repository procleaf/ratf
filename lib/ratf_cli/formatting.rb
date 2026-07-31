# frozen_string_literal: true
# CLI formatting helpers — colors, tables, status badges
module RatfCli
  module Formatting
    COLORS = {
      red:    "\e[31m",
      green:  "\e[32m",
      yellow: "\e[33m",
      blue:   "\e[34m",
      cyan:   "\e[36m",
      gray:   "\e[90m",
      bold:   "\e[1m",
      reset:  "\e[0m"
    }.freeze

    STATUS_COLORS = {
      "passed"    => :green,  "completed"  => :green,  "active"   => :green,
      "idle"      => :green,  "running"    => :blue,   "busy"     => :blue,
      "pending"   => :yellow, "queued"     => :yellow, "in_progress" => :yellow,
      "failed"    => :red,    "error"      => :red,    "offline"     => :red,
      "cancelled" => :gray,   "skipped"    => :gray,   "terminated"  => :gray,
      "closed"    => :gray,   "deprecated" => :gray
    }.freeze

    module_function

    def color(str, name)
      code = COLORS[name] || ""
      "#{code}#{str}#{COLORS[:reset]}"
    end

    def status(str)
      c = STATUS_COLORS[str.to_s] || :gray
      color(str.to_s.ljust(12), c)
    end

    def heading(str)
      "\n#{color(str, :bold)}#{color(":", :bold)}\n"
    end

    def table(headers, rows)
      return puts(color("  (empty)", :gray)) if rows.empty?

      widths = headers.map.with_index { |h, i|
        [h.length, *rows.map { |r| (r[i] || "").to_s.length }].max
      }

      # Header
      header_line = headers.map.with_index { |h, i|
        color(h.ljust(widths[i]), :bold)
      }.join("  ")
      puts "  #{header_line}"
      puts "  #{headers.map.with_index { |_, i| "─" * widths[i] }.join("  ")}"

      # Rows
      rows.each do |row|
        line = row.map.with_index { |cell, i|
          (cell || "—").to_s.ljust(widths[i])
        }.join("  ")
        puts "  #{line}"
      end
    end

    def kv(hash, indent: 2)
      pad = " " * indent
      max_key = hash.keys.map(&:length).max
      hash.each do |k, v|
        key = color(k.to_s.ljust(max_key), :gray)
        puts "#{pad}#{key}  #{v}"
      end
    end

    def section(title)
      puts color("\n── #{title} ──", :bold)
    end
  end
end

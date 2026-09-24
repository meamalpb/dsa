# frozen_string_literal: true

module Srs
  # Tables shared by `setup` and (later) `status`.
  module Report
    module_function

    def coverage(problems, state, out)
      progress = Progress.new(problems, state)
      bar_head = 'Progress'.ljust(Charts::BAR_WIDTH)
      out.puts "\n#{'Topic'.ljust(17)} #{'Seen'.rjust(7)}  E+M seen   #{bar_head}  E / M / H     Status"
      Topics::ROADMAP.each_key do |topic|
        all = progress.in_topic(topic).keys
        seen = "#{all.count { |s| progress.seen?(s) }}/#{all.size}"
        counts = %w[Easy Medium Hard].map { |d| progress.in_topic(topic, [d]).size }.join(' / ')
        pct = "#{(progress.core_ratio(topic) * 100).round}%"
        open = progress.open?(topic)
        status = open ? 'open' : "locked (needs #{Topics.prereqs(topic).join(' + ')})"
        bar = Charts.bar(progress.core_ratio(topic))
        out.puts "#{topic.ljust(17)} #{seen.rjust(7)}  #{pct.rjust(8)}   #{bar}  #{counts.ljust(13)} #{status}"
      end
    end

    def premium(problems, out)
      paid = problems.select { |_, p| p['paid_only'] }
      return if paid.empty?

      out.puts "\nPremium problems (#{paid.size}):"
      paid.each { |slug, p| out.puts "  #{p['name'].ljust(45)} #{p['alt_link'] || "NO FREE LINK for #{slug}"}" }
    end
  end
end

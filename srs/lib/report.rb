# frozen_string_literal: true

module Srs
  # Tables shared by `setup` and (later) `status`.
  module Report
    module_function

    def coverage(problems, state, out)
      progress = Progress.new(problems, state)
      bar_head = 'Progress'.ljust(Charts::BAR_WIDTH)
      counted = "#{Srs.config.dig('unlock', 'topic_counts').map { |d| d[0] }.join('+')} seen"
      out.puts "\n#{'Topic'.ljust(17)} #{'Seen'.rjust(7)}  #{counted.rjust(8)}   #{bar_head}  E / M / H     Status"
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

    # Every problem whose next_review has passed, most overdue first.
    def overdue(problems, state, today, out)
      rows = state['problems'].filter_map do |slug, card|
        next unless problems.key?(slug)
        next unless card['next_review'] <= today

        [slug, card]
      end
      return out.puts "\nNothing overdue." if rows.empty?

      rows.sort_by! { |_, card| card['next_review'] }
      name_width = rows.map { |slug, _| problems[slug]['name'].size }.max
      out.puts "\nOverdue (#{rows.size}):"
      out.puts "#{'Problem'.ljust(name_width)} #{'Topic'.ljust(14)} #{'Diff'.ljust(7)} " \
               "#{'Overdue'.rjust(7)}  Last done   Reps  Ease"
      rows.each do |slug, card|
        p = problems[slug]
        days = (today - card['next_review']).to_i
        out.puts "#{p['name'].ljust(name_width)} #{p['topic'].ljust(14)} #{p['difficulty'].ljust(7)} " \
                 "#{"#{days}d".rjust(7)}  #{card['last_reviewed']}  #{card['reps'].to_s.rjust(4)}  #{card['ease']}"
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

# frozen_string_literal: true

module Srs
  # Per-topic coverage and the unlock rules from DESIGN.md §6; thresholds from srs/config.yml.
  class Progress
    def initialize(problems, state, config: Srs.config)
      @problems = problems
      @state = state
      @unlock = config['unlock']
    end

    def seen?(slug)
      @state['problems'].key?(slug)
    end

    def in_topic(topic, difficulties = nil)
      @problems.select do |_, p|
        p['topic'] == topic && (difficulties.nil? || difficulties.include?(p['difficulty']))
      end
    end

    # Share of the topic's problems at these difficulties that have been seen.
    # A topic with no such problems counts as complete.
    def ratio(topic, difficulties)
      slugs = in_topic(topic, difficulties).keys
      return 1.0 if slugs.empty?

      slugs.count { |s| seen?(s) }.fdiv(slugs.size)
    end

    # Coverage that counts toward unlocking the next topics (Easy + Medium by default).
    def core_ratio(topic)
      ratio(topic, @unlock['topic_counts'])
    end

    def open?(topic)
      Topics.prereqs(topic).all? { |t| core_ratio(t) >= @unlock['topic_ratio'] } ||
        in_topic(topic).keys.any? { |s| seen?(s) }
    end

    def hards_unlocked?(topic)
      ratio(topic, %w[Medium]) >= @unlock['hard_ratio']
    end
  end
end

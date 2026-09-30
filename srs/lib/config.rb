# frozen_string_literal: true

module Srs
  # The tunable rules: srs/config.yml over these defaults — DESIGN.md §12.
  # A missing file, or a setting left out of it, means the default.
  module Config
    DEFAULTS = {
      'session' => {
        'slots' => { 'A' => 'easy', 'B' => 'medium_hard' },
        'bonus' => { 'pool' => 'easy', 'unlock_on' => ['easy'], 'max' => 1 },
        'new_every_days' => 2,
        'review_order' => 'most_overdue',
        'learning_days' => 14
      },
      'pools' => { 'easy' => %w[Easy], 'medium_hard' => %w[Medium Hard] },
      'unlock' => { 'topic_ratio' => 0.8, 'topic_counts' => %w[Easy Medium], 'hard_ratio' => 0.8 },
      'sm2' => { 'first_intervals' => [1, 6], 'start_ease' => 2.5, 'min_ease' => 1.3, 'max_interval' => nil },
      'display' => { 'heatmap_weeks' => 26 }
    }.freeze

    # Maps you give in full rather than key by key: setting `slots: { A: easy }`
    # means only slot A, not A plus the default B.
    REPLACED_WHOLE = %w[slots pools].freeze
    REVIEW_ORDERS = %w[most_overdue learning_first].freeze
    DIFFICULTIES = %w[Easy Medium Hard].freeze
    GRADES = %w[again hard good easy].freeze

    module_function

    def load(path)
      build(File.exist?(path) ? Store.load(path, {}) : {}, path)
    end

    def build(overrides, source = 'config')
      config = merge(DEFAULTS, overrides || {}, source, [])
      validate(config, source)
      config
    end

    def merge(defaults, overrides, source, path)
      raise Error, "#{source}: `#{path.join('.')}` should be a map of settings." unless overrides.is_a?(Hash)

      overrides.each_key do |key|
        raise Error, "#{source}: unknown setting `#{(path + [key]).join('.')}`." unless defaults.key?(key)
      end
      defaults.to_h do |key, default|
        next [key, default] unless overrides.key?(key)

        value = overrides[key]
        nested = default.is_a?(Hash) && !REPLACED_WHOLE.include?(key)
        [key, nested ? merge(default, value, source, path + [key]) : value]
      end
    end

    def validate(config, source)
      problems = errors(config)
      raise Error, "#{source}:\n  #{problems.join("\n  ")}" unless problems.empty?
    end

    def errors(config)
      session, pools, unlock, sm2 = config.values_at('session', 'pools', 'unlock', 'sm2')
      bonus = session['bonus']
      errors = []
      pools.each do |name, diffs|
        errors << "pools.#{name} must list difficulties from #{DIFFICULTIES.join(', ')}" unless
          diffs.is_a?(Array) && !diffs.empty? && (diffs - DIFFICULTIES).empty?
      end
      errors << 'session.slots needs at least one slot' if session['slots'].to_h.empty?
      session['slots'].to_h.each do |slot, pool|
        errors << "session.slots: `#{slot}` must be one capital letter" unless slot.to_s.match?(/\A[A-Z]\z/)
        errors << "session.slots.#{slot}: no pool named `#{pool}`" unless pools.key?(pool)
      end
      errors << "session.bonus.pool: no pool named `#{bonus['pool']}`" unless pools.key?(bonus['pool'])
      errors << "session.bonus.unlock_on must list grades from #{GRADES.join(', ')}" unless
        Array(bonus['unlock_on']).all? { |g| GRADES.include?(g) }
      errors << 'session.bonus.max must be 0 or more' unless whole?(bonus['max'], min: 0)
      errors << 'session.new_every_days must be 1 or more' unless whole?(session['new_every_days'], min: 1)
      errors << "session.review_order must be one of #{REVIEW_ORDERS.join(', ')}" unless
        REVIEW_ORDERS.include?(session['review_order'])
      errors << 'session.learning_days must be 1 or more' unless whole?(session['learning_days'], min: 1)
      %w[topic_ratio hard_ratio].each do |key|
        ratio = unlock[key]
        errors << "unlock.#{key} must be between 0 and 1" unless ratio.is_a?(Numeric) && ratio.between?(0, 1)
      end
      errors << "unlock.topic_counts must list difficulties from #{DIFFICULTIES.join(', ')}" unless
        unlock['topic_counts'].is_a?(Array) && (unlock['topic_counts'] - DIFFICULTIES).empty?
      errors << 'sm2.first_intervals must be two whole numbers of days, like [1, 6]' unless
        sm2['first_intervals'].is_a?(Array) && sm2['first_intervals'].size == 2 &&
        sm2['first_intervals'].all? { |d| whole?(d, min: 1) }
      errors << 'sm2.min_ease must be a number above 1' unless sm2['min_ease'].is_a?(Numeric) && sm2['min_ease'] > 1
      errors << 'sm2.start_ease must be at least sm2.min_ease' unless
        sm2['start_ease'].is_a?(Numeric) && sm2['min_ease'].is_a?(Numeric) && sm2['start_ease'] >= sm2['min_ease']
      errors << 'sm2.max_interval must be empty or 1 or more' unless
        sm2['max_interval'].nil? || whole?(sm2['max_interval'], min: 1)
      errors << 'display.heatmap_weeks must be 1 or more' unless whole?(config.dig('display', 'heatmap_weeks'), min: 1)
      errors
    end

    def whole?(value, min:)
      value.is_a?(Integer) && value >= min
    end
  end

  CONFIG_PATH = ENV.fetch('SRS_CONFIG', File.join(ROOT, 'srs', 'config.yml'))

  def self.config
    @config ||= Config.load(CONFIG_PATH)
  end

  # Tests swap in their own settings; nil goes back to the file.
  def self.config=(config)
    @config = config
  end
end

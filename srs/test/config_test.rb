# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/srs'

class ConfigTest < Minitest::Test
  def build(overrides)
    Srs::Config.build(overrides)
  end

  def test_missing_file_means_defaults
    assert_equal Srs::Config::DEFAULTS, Srs::Config.load('/nonexistent/config.yml')
  end

  def test_empty_file_means_defaults
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'config.yml')
      File.write(path, '')
      assert_equal Srs::Config::DEFAULTS, Srs::Config.load(path)
    end
  end

  def test_settings_left_out_keep_their_default
    config = build('session' => { 'new_every_days' => 3, 'bonus' => { 'max' => 2 } })
    assert_equal 3, config.dig('session', 'new_every_days')
    assert_equal 2, config.dig('session', 'bonus', 'max')
    assert_equal 'easy', config.dig('session', 'bonus', 'pool')
    assert_equal 'most_overdue', config.dig('session', 'review_order')
    assert_equal 0.8, config.dig('unlock', 'topic_ratio')
  end

  def test_slots_and_pools_are_replaced_whole
    config = build('session' => { 'slots' => { 'A' => 'medium_hard' } })
    assert_equal({ 'A' => 'medium_hard' }, config.dig('session', 'slots'))
  end

  def test_your_config_file_is_valid
    Srs::Config.load(File.join(Srs::ROOT, 'srs', 'config.yml')) # raises on a typo or bad value
  end

  def test_unknown_setting_is_refused
    error = assert_raises(Srs::Error) { build('session' => { 'new_evry_days' => 3 }) }
    assert_match 'session.new_evry_days', error.message
  end

  def test_bad_values_are_all_reported
    error = assert_raises(Srs::Error) do
      build('session' => { 'slots' => { 'A' => 'hardish' }, 'review_order' => 'random' },
            'unlock' => { 'topic_ratio' => 80 },
            'sm2' => { 'first_intervals' => [1] })
    end
    %w[session.slots.A session.review_order unlock.topic_ratio sm2.first_intervals].each do |key|
      assert_match key, error.message
    end
  end
end

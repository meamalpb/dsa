# frozen_string_literal: true

require 'date'

# Spaced repetition over the NeetCode 150 sheet. See srs/DESIGN.md.
module Srs
  ROOT = File.expand_path('../..', __dir__)
  PROBLEMS_PATH = File.join(ROOT, 'srs', 'problems.yml')
  # SRS_STATE / SRS_TODAY let you try things out without touching your real history.
  STATE_PATH = ENV.fetch('SRS_STATE', File.join(ROOT, 'srs', 'state.yml'))

  # A problem with what the user asked for; printed without a backtrace.
  class Error < StandardError; end

  def self.today
    ENV['SRS_TODAY'] ? Date.parse(ENV['SRS_TODAY']) : Date.today
  end
end

require_relative 'topics'
require_relative 'store'
require_relative 'sheet'
require_relative 'leetcode'
require_relative 'progress'
require_relative 'report'
require_relative 'setup'
require_relative 'sm2'
require_relative 'scheduler'
require_relative 'scaffold'
require_relative 'slot_printer'
require_relative 'commands'
require_relative 'cli'

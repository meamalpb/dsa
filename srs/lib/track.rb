# frozen_string_literal: true

module Srs
  # Which language the commands work in: its own state file, config and source files.
  # Ruby is the default; `bin/srs java …` switches to the Java track — DESIGN.md §13 —
  # and `bin/srs sql …` to the SQL track, with its own problem list and roadmap — §14.
  Track = Struct.new(:name, :state_path, :config_path, :command, :problems_path, :roadmap, keyword_init: true) do
    def java?
      name == 'java'
    end

    def sql?
      name == 'sql'
    end

    def one_pass?
      java?
    end

    # Creates the files `start` writes: Scaffold for Ruby, JavaScaffold for Java, SqlScaffold for SQL.
    def scaffold(problems)
      return SqlScaffold if sql?

      java? ? JavaScaffold.new(problems) : Scaffold
    end

    # The problems this track practices. Ruby and SQL: all of their list. Java: the ones already solved in Ruby,
    # with `file` pointing at the Java file and `ruby_file` at the Ruby original it is made from.
    def problems(all, root: ROOT)
      return all unless java?

      all.each_with_object({}) do |(slug, problem), out|
        file = problem['file']
        next unless file && solved_in_ruby?(File.join(root, file))

        out[slug] = problem.merge('file' => JavaScaffold.java_path(file), 'ruby_file' => file)
      end
    end

    private

    # Same test as Setup#seed: an unsolved `srs start` scaffold has no top-level def/class.
    def solved_in_ruby?(path)
      File.exist?(path) && File.read(path).match?(/^(def|class|module) /)
    end
  end

  RUBY_TRACK = Track.new(name: 'ruby', state_path: STATE_PATH, config_path: CONFIG_PATH, command: 'bin/srs',
                         problems_path: PROBLEMS_PATH, roadmap: Topics::ROADMAP)
  JAVA_TRACK = Track.new(
    name: 'java',
    state_path: ENV.fetch('SRS_STATE_JAVA', File.join(ROOT, 'srs', 'state.java.yml')),
    config_path: ENV.fetch('SRS_CONFIG_JAVA', File.join(ROOT, 'srs', 'config.java.yml')),
    command: 'bin/srs java',
    problems_path: PROBLEMS_PATH,
    roadmap: Topics::ROADMAP
  )
  # LeetCode's Top SQL 50 (srs/problems.sql.yml, committed — there's no setup for it).
  SQL_TRACK = Track.new(
    name: 'sql',
    state_path: ENV.fetch('SRS_STATE_SQL', File.join(ROOT, 'srs', 'state.sql.yml')),
    config_path: ENV.fetch('SRS_CONFIG_SQL', File.join(ROOT, 'srs', 'config.sql.yml')),
    command: 'bin/srs sql',
    problems_path: File.join(ROOT, 'srs', 'problems.sql.yml'),
    roadmap: Topics::SQL_ROADMAP
  )

  def self.track
    @track ||= RUBY_TRACK
  end

  # The settings belong to the track, so switching it drops the loaded ones.
  def self.track=(track)
    @track = track
    @config = nil
  end
end

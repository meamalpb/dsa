# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'tmpdir'
require_relative '../lib/srs'

class SqlTest < Minitest::Test
  PROBLEM = <<~SQL
    -- 1. Some Problem · Easy · Select
    -- Rows must come in the order shown.
    -- Checked with: SELECT * FROM T

    -- Case 1: LeetCode's example ------------------------------------------------

    CREATE TABLE T (a int);
    INSERT INTO T VALUES (1), (2);

    -- Expected
    CREATE TABLE expected (a int);
    INSERT INTO expected VALUES (1);

    -- Case 2: empty table -------------------------------------------------------

    CREATE TABLE T (a int);

    -- Expected
    CREATE TABLE expected (a int);

    -- Your query below this line ------------------------------------------------

    DELETE FROM T WHERE a = 2;
  SQL

  def result(columns, *rows)
    Srs::SqlRunner::Result.new(columns, rows)
  end

  def runner
    Srs::SqlRunner.new(out: StringIO.new)
  end

  def test_parse_splits_cases_query_and_flags
    problem = Srs::SqlRunner.parse(PROBLEM)

    assert_equal ["LeetCode's example", 'empty table'], problem.cases.map(&:label)
    assert_includes problem.cases[0].sql, 'INSERT INTO T VALUES (1), (2);'
    refute_includes problem.cases[0].sql, 'empty table'
    assert_equal "\nDELETE FROM T WHERE a = 2;\n", problem.query
    assert problem.ordered
    assert_equal 'SELECT * FROM T', problem.check
  end

  def test_parse_needs_the_marker
    assert_raises(Srs::Error) { Srs::SqlRunner.parse("-- Case 1: x --\nSELECT 1;\n") }
  end

  def test_numbers_compare_by_value_and_columns_ignore_case
    assert runner.same?(result(%w[Rate], ['0.5']), result(%w[rate], ['0.50']), false)
    refute runner.same?(result(%w[rate], ['0.333']), result(%w[rate], ['0.33']), false)
    refute runner.same?(result(%w[rate], ['1']), result(%w[other], ['1']), false)
  end

  def test_null_is_not_an_empty_string
    refute runner.same?(result(%w[a], [nil]), result(%w[a], ['']), false)
    assert runner.same?(result(%w[a b], [nil, 'x']), result(%w[a b], [nil, 'x']), false)
  end

  def test_row_order_counts_only_when_the_problem_says_so
    mine = result(%w[a], ['2'], ['1'])
    theirs = result(%w[a], ['1'], ['2'])

    assert runner.same?(mine, theirs, false)
    refute runner.same?(mine, theirs, true)
  end

  def test_attempt_keeps_everything_up_to_the_marker
    blank = Srs::SqlScaffold.blank(PROBLEM)

    assert blank.end_with?("-- Your query below this line #{'-' * 48}\n\n")
    refute_includes blank, 'DELETE'
    assert_equal 'a/b.attempt.sql', Srs::SqlScaffold.attempt_path('a/b.sql')
    assert_equal 'a/b.sql', Srs::SqlScaffold.original_path('a/b.attempt.sql')
  end

  def test_every_listed_problem_has_a_file_with_cases
    problems = Srs::Store.load(Srs::SQL_TRACK.problems_path, {})

    assert_equal 50, problems.size
    problems.each do |slug, problem|
      assert Srs::Topics::SQL_ROADMAP.key?(problem['topic']), "#{slug}: unknown topic #{problem['topic']}"
      assert_match %r{\Adatabase/#{problem['topic']}/#{problem['difficulty'].downcase}/}, problem['file']
      source = File.read(File.join(Srs::ROOT, problem['file']))
      parsed = Srs::SqlRunner.parse(source)

      assert_includes source, problem['link']
      assert parsed.cases.all? { |kase| kase.sql.include?('CREATE TABLE expected') }, slug
    end
  end

  def test_sql_track_has_its_own_files_and_a_valid_config
    refute_equal Srs::RUBY_TRACK.state_path, Srs::SQL_TRACK.state_path
    assert_equal 'bin/srs sql', Srs::SQL_TRACK.command
    assert_equal Srs::SqlScaffold, Srs::SQL_TRACK.scaffold({})
    config = Srs::Config.load(Srs::SQL_TRACK.config_path)

    assert_equal({ 'A' => 'easy', 'B' => 'any' }, config.dig('session', 'slots'))
  end

  # Needs a running PostgreSQL server; skipped without one.
  def test_runs_the_query_with_psql
    skip 'no PostgreSQL server' unless system('psql', '-X', '-q', '-d', 'postgres', '-c', 'SELECT 1',
                                              out: File::NULL, err: File::NULL)
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'p.sql')
      File.write(path, PROBLEM)
      assert runner.run(path)

      File.write(path, PROBLEM.sub('a = 2', 'a = 1'))
      refute runner.run(path)
    end
  end
end

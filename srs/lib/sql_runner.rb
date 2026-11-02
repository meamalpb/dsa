# frozen_string_literal: true

require 'bigdecimal'
require 'csv'
require 'open3'
require 'tmpdir'

module Srs
  # `bin/srs sql run` — DESIGN.md §14. Runs the query at the bottom of a problem file on each of
  # the file's cases with psql. A case is its tables plus an `expected` table; it runs inside a
  # transaction that is rolled back, so nothing is left behind in the database.
  class SqlRunner # rubocop:disable Metrics/ClassLength
    MARKER = /\A-- Your query below this line/
    CASE = /\A-- Case \d+: (.*?) -*\s*\z/
    ORDERED = /^-- Rows must come in the order shown\./
    CHECK = /^-- Checked with: (.+)$/
    NUMBER = /\A-?\d+(\.\d+)?\z/

    # A problem file: its cases, the user's query, whether row order counts, and for a problem
    # that changes a table (DELETE …), the query whose result is compared instead.
    Problem = Struct.new(:cases, :query, :ordered, :check)
    Case = Struct.new(:label, :sql)
    # Column names, and rows of strings (nil = NULL).
    Result = Struct.new(:columns, :rows)

    # psql stopped on an error in the query; the message is psql's.
    class QueryError < StandardError; end

    def self.parse(source)
      lines = source.lines
      marker = lines.index { |line| line.match?(MARKER) } or
        raise Error, 'no `-- Your query below this line` marker in the problem file'
      cases = []
      lines[0...marker].each do |line|
        if (match = line.match(CASE)) then cases << Case.new(match[1], +'')
        elsif cases.any? then cases.last.sql << line
        end
      end
      raise Error, 'no `-- Case 1: …` section in the problem file' if cases.empty?

      head = lines[0...marker].join
      Problem.new(cases, lines[(marker + 1)..].join, head.match?(ORDERED), head[CHECK, 1])
    end

    def initialize(out: $stdout, database: ENV.fetch('SRS_PGDATABASE', 'postgres'))
      @out = out
      @database = database
    end

    # Runs every case and prints how each went. Returns true when they all pass.
    def run(path)
      problem = self.class.parse(File.read(path))
      raise Error, "Write your query under the last line of #{path.delete_prefix("#{ROOT}/")} first." if
        blank?(problem.query)

      passed = problem.cases.each_with_index.count { |kase, i| report(kase, i + 1, problem) }
      total = problem.cases.size
      summary = if passed < total then "#{passed}/#{total} cases pass."
                elsif total == 1 then 'It passes.'
                else "All #{total} cases pass."
                end
      @out.puts "\n#{summary}"
      passed == total
    end

    # Numbers compare by value to 5 decimals (0.5 = 0.50, as LeetCode does), column names
    # ignoring case (Postgres lowercases unquoted aliases), and rows in any order unless the
    # problem says otherwise.
    def same?(actual, expected, ordered)
      return false unless actual.columns.map(&:downcase) == expected.columns.map(&:downcase)

      mine = actual.rows.map { |row| key(row) }
      theirs = expected.rows.map { |row| key(row) }
      ordered ? mine == theirs : mine.sort == theirs.sort
    end

    private

    def report(kase, number, problem)
      actual, expected = execute(kase.sql, problem)
      ok = same?(actual, expected, problem.ordered)
      @out.puts "Case #{number} (#{kase.label}): #{ok ? 'pass' : 'FAIL'}"
      unless ok
        @out.puts "  #{why(actual, expected, problem.ordered)}"
        @out.puts '  your result:', table(actual), '  expected:', table(expected)
      end
      ok
    rescue QueryError => e
      @out.puts "Case #{number} (#{kase.label}): ERROR", e.message.gsub(/^/, '  ')
      false
    end

    def execute(setup, problem)
      Dir.mktmpdir('srs-sql') do |dir|
        actual = File.join(dir, 'actual.csv')
        expected = File.join(dir, 'expected.csv')
        statement = if problem.check
                      [problem.query, ';', "\\o '#{actual}'", "#{problem.check};"]
                    else
                      ["\\o '#{actual}'", problem.query, ';']
                    end
        psql(['SET client_min_messages = warning;', 'BEGIN;', setup, *statement,
              "\\o '#{expected}'", 'TABLE expected;', '\o', 'ROLLBACK;'].join("\n"))
        [read(actual), read(expected)]
      end
    end

    # Exit status 2 is a connection problem, 3 an error in the script (ON_ERROR_STOP).
    def psql(script)
      _, err, status = Open3.capture3('psql', '-X', '-q', '--csv', '-v', 'ON_ERROR_STOP=1', '-d', @database,
                                      stdin_data: script)
      return if status.success?
      raise QueryError, err.gsub(/^psql:<stdin>:\d+: /, '').strip if status.exitstatus == 3

      raise Error, "psql couldn't run (database `#{@database}`, change it with SRS_PGDATABASE):\n#{err.strip}"
    rescue Errno::ENOENT
      raise Error, 'psql not found — install PostgreSQL (e.g. `brew install postgresql@16`) and start it.'
    end

    def read(path)
      header, *rows = File.exist?(path) ? CSV.read(path) : []
      header ||= []
      # A one-column NULL row is an empty CSV line, which parses as [].
      Result.new(header, rows.map { |row| row + ([nil] * (header.size - row.size)) })
    end

    def key(row)
      row.map do |cell|
        if cell.nil? then [0, '']
        elsif cell.match?(NUMBER) then [1, BigDecimal(cell).round(5)]
        else [2, cell]
        end
      end
    end

    def why(actual, expected, ordered)
      return 'your statement returned no rows or columns — is it a SELECT?' if actual.columns.empty?
      unless actual.columns.map(&:downcase) == expected.columns.map(&:downcase)
        return "columns differ: yours (#{actual.columns.join(', ')}), expected (#{expected.columns.join(', ')})"
      end
      return 'right rows, wrong order' if ordered && same?(actual, expected, false)

      "rows differ (#{actual.rows.size} yours, #{expected.rows.size} expected)"
    end

    def table(result)
      return '    (nothing)' if result.columns.empty?

      cells = [result.columns] + result.rows.map { |row| row.map { |cell| cell.nil? ? 'null' : cell } }
      widths = result.columns.each_index.map { |i| cells.map { |row| row[i].to_s.size }.max }
      lines = cells.map do |row|
        "    #{row.each_with_index.map { |cell, i| cell.to_s.ljust(widths[i]) }.join(' | ')}".rstrip
      end
      lines.insert(1, "    #{widths.map { |w| '-' * w }.join('-+-')}")
      lines << '    (no rows)' if result.rows.empty?
      lines.join("\n")
    end

    def blank?(query)
      query.lines.all? { |line| line.strip.empty? || line.strip.start_with?('--') }
    end
  end
end

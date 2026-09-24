# frozen_string_literal: true

require 'fileutils'

module Srs
  # Files created by `start` — DESIGN.md §8.
  module Scaffold
    TOP_BLOCK = /\A(def|class|module) /
    BANNER = /\A#\s*(-{3,}|approach\b)/i
    TEST_BLOCK = 'if __FILE__ == $PROGRAM_NAME'

    module_function

    def attempt_path(file)
      file.sub(/\.rb\z/, '.attempt.rb')
    end

    # Returns true if the file was created, false if it already existed.
    def create_new(file, slug)
      write_unless_exists(file) { new_source(file, slug) }
    end

    def create_attempt(file)
      original = File.read(File.join(ROOT, file))
      write_unless_exists(attempt_path(file)) do
        attempt_source(original)
      rescue ArgumentError
        header_and_tests(original)
      end
    end

    def write_unless_exists(file)
      path = File.join(ROOT, file)
      return false if File.exist?(path)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, yield)
      true
    end

    def new_source(file, slug)
      <<~RUBY
        # frozen_string_literal: true

        # #{file}

        # Problem
        # https://leetcode.com/problems/#{slug}/

        #{TEST_BLOCK}
          # tests go here
        end
      RUBY
    end

    # Keeps everything that isn't the answer: header, requires, signature
    # comments, runner helpers and the test block. Each solution def/class
    # before `def runner` becomes an empty stub. Relies on top-level
    # def/class/end sitting at column 0 (rubocop layout).
    def attempt_source(source)
      lines = source.lines
      out = []
      helpers = false
      i = 0
      while i < lines.size
        line = lines[i]
        break out.concat(lines[i..]) if line.start_with?(TEST_BLOCK)

        if line.match?(TOP_BLOCK)
          j = block_end(lines, i)
          helpers ||= line.start_with?('def runner')
          out.concat(helpers ? lines[i..j] : [line, "end\n"])
          i = j
        elsif !line.match?(BANNER)
          out << line
        end
        i += 1
      end
      squeeze_blank_lines(out).join
    end

    def block_end(lines, start)
      return start if lines[start].match?(/;\s*end\s*\z/)

      (start + 1...lines.size).find { |k| lines[k].match?(/\Aend\b/) } or
        raise ArgumentError, "no closing `end` for: #{lines[start].strip}"
    end

    # Fallback when the file doesn't fit the layout: header + test block only.
    def header_and_tests(source)
      lines = source.lines
      url = lines.index { |l| l.include?('leetcode.com/problems/') } || 0
      tests = lines.index { |l| l.start_with?(TEST_BLOCK) }
      (lines[0..url] + ["\n"] + (tests ? lines[tests..] : [])).join
    end

    def squeeze_blank_lines(lines)
      lines.each_with_object([]) do |line, out|
        out << line unless line.strip.empty? && (out.empty? || out.last.strip.empty?)
      end
    end
  end
end

# frozen_string_literal: true

require 'fileutils'

module Srs
  # Files created by `java start` — DESIGN.md §13. Same job as Scaffold, but the stub is built
  # from the Ruby original: package, problem link, and each function with its arguments.
  # A Java file sits next to its Ruby one (foo_bar.rb → FooBar.java); a review attempt is
  # FooBarAttempt.java (gitignored).
  class JavaScaffold # rubocop:disable Metrics/ClassLength
    TEST_BLOCK = 'if __FILE__ == $PROGRAM_NAME'
    DEF = /\A(?<indent>\s*)def\s+(?<name>\w+)[?!=]?/
    SKIPPED_DEFS = %w[runner pp].freeze
    SKIPPED_CLASSES = %w[ListNode TreeNode].freeze
    KEYWORDS = %w[abstract assert boolean break byte case catch char class const continue default do double else
                  enum extends final finally float for goto if implements import instanceof int interface long
                  native new package private protected public return short static strictfp super switch
                  synchronized this throw throws transient try void volatile while].freeze

    # A Ruby class and its defs worth a stub (`initialize` becomes the constructor). Defs after a
    # `private` line are helpers, so `visible` turns false there.
    RubyClass = Struct.new(:name, :defs, :visible)
    # A def: its name, and its arguments as written in Ruby.
    RubyDef = Struct.new(:name, :params)

    class << self
      def java_path(ruby_file)
        File.join(File.dirname(ruby_file), "#{class_name(ruby_file)}.java")
      end

      # group_anagrams.rb → GroupAnagrams; a leading digit isn't allowed in Java.
      def class_name(ruby_file)
        name = File.basename(ruby_file, '.rb').split('_').map(&:capitalize).join
        name.match?(/\A\d/) ? "_#{name}" : name
      end
    end

    def initialize(problems, root: ROOT)
      @by_file = problems.values.to_h { |problem| [problem['file'], problem] }
      @root = root
    end

    def attempt_path(file)
      file.sub(/\.java\z/, 'Attempt.java')
    end

    # What a path given to `start` means: the problem's own Java file.
    def original_path(file)
      file.sub(/\.attempt\.rb\z/, '.rb').sub(/Attempt\.java\z/, '.java')
    end

    # Returns true if the file was created, false if it already existed.
    def create_new(file, _slug)
      write_unless_exists(file) { source(file, File.basename(file, '.java')) }
    end

    def create_attempt(file)
      write_unless_exists(attempt_path(file)) { source(file, "#{File.basename(file, '.java')}Attempt") }
    end

    def source(file, class_name)
      problem = @by_file.fetch(file)
      ruby = File.read(File.join(@root, problem['ruby_file']))
      render(package_of(file), problem['link'], class_name, parse(ruby))
    end

    private

    def write_unless_exists(file)
      path = File.join(@root, file)
      return false if File.exist?(path)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, yield)
      true
    end

    # Top-level defs and classes of the Ruby file, in order, up to its test block.
    def parse(ruby)
      found = []
      klass = nil
      ruby.each_line do |line|
        break if line.start_with?(TEST_BLOCK)

        if (match = line.match(/\Aclass\s+(\w+)/))
          klass = RubyClass.new(match[1], [], true)
          found << klass unless SKIPPED_CLASSES.include?(klass.name)
        elsif line.match?(/\Aend\b/)
          klass = nil
        elsif klass && line.match?(/\A\s+(private|protected)\s*$/)
          klass.visible = false
        elsif (ruby_def = ruby_def(line, klass ? '  ' : ''))
          if klass.nil? then found << ruby_def
          elsif klass.visible then klass.defs << ruby_def
          end
        end
      end
      found
    end

    # A def at exactly this indent (top level, or directly inside a class), or nil.
    def ruby_def(line, indent)
      match = line.match(DEF)
      return unless match && match[:indent] == indent && !SKIPPED_DEFS.include?(match[:name])

      rest = line[match.end(0)..]
      return if rest.start_with?('.') # def self.x

      raw = rest[/\A\s*\((.*?)\)/, 1] || rest[/\A\s+([^;#\n]+)/, 1] || ''
      RubyDef.new(match[:name], raw.split(',').filter_map { |arg| arg.strip.sub(/\A[*&]+/, '')[/\A\w+/] })
    end

    def package_of(file)
      dir = File.dirname(file)
      return if dir == '.'

      dir.split('/').map { |part| part.match?(/\A\d/) ? "_#{part}" : part }.join('.')
    end

    def render(package, link, class_name, parsed)
      body = parsed.flat_map { |item| member_lines(item, class_name) }
      lines = []
      lines += ["package #{package};", ''] if package
      lines += ["// #{link}", '']
      lines += ["public class #{class_name} {"]
      lines += body.flat_map { |chunk| indent(chunk + ['']) }
      lines += ['}']
      "#{lines.join("\n")}\n"
    end

    # Chunks of lines (each one member), not yet indented. A Ruby class named like the file's class
    # becomes that class's own constructor and methods; any other becomes a nested static class.
    def member_lines(item, class_name)
      return [method_lines(item, 'public static')] if item.is_a?(RubyDef)

      if item.name == class_name
        item.defs.map { |ruby_def| method_lines(ruby_def, 'public', constructor_of: class_name) }
      else
        [nested_lines(item)]
      end
    end

    def nested_lines(klass)
      methods = klass.defs.map { |ruby_def| method_lines(ruby_def, 'public', constructor_of: klass.name) }
      inner = methods.each_with_index.flat_map { |lines, i| i.zero? ? lines : ['', *lines] }
      ["static class #{klass.name} {", *indent(inner), '}']
    end

    def method_lines(ruby_def, modifiers, constructor_of: nil)
      params = ruby_def.params.map { |arg| "Object #{safe(camel(arg))}" }.join(', ')
      if ruby_def.name == 'initialize'
        ["#{modifiers} #{constructor_of}(#{params}) {", '}']
      else
        ["#{modifiers} Object #{safe(camel(ruby_def.name))}(#{params}) {", '    return null;', '}']
      end
    end

    def camel(name)
      name.gsub(/_+(\w)/) { Regexp.last_match(1).upcase }
    end

    def safe(name)
      KEYWORDS.include?(name) ? "#{name}Value" : name
    end

    def indent(lines)
      lines.map { |line| line.empty? ? line : "    #{line}" }
    end
  end
end

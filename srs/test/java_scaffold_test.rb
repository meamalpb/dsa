# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/srs'

class JavaScaffoldTest < Minitest::Test
  def scaffold(file, link = 'https://leetcode.com/problems/x/')
    Srs::JavaScaffold.new({ 'x' => { 'file' => file, 'link' => link, 'ruby_file' => 'unused.rb' } })
  end

  def render(ruby, file = 'arrays_and_hashing/medium/GroupAnagrams.java')
    scaffold = scaffold(file)
    scaffold.send(:render, scaffold.send(:package_of, file), 'https://leetcode.com/problems/x/',
                  File.basename(file, '.java'), scaffold.send(:parse, ruby))
  end

  def test_paths
    assert_equal 'tree/easy/InvertBinaryTree.java', Srs::JavaScaffold.java_path('tree/easy/invert_binary_tree.rb')
    assert_equal '_3sum', Srs::JavaScaffold.class_name('two_pointers/medium/3sum.rb')
    java = scaffold('tree/easy/X.java')
    assert_equal 'tree/easy/XAttempt.java', java.attempt_path('tree/easy/X.java')
    assert_equal 'tree/easy/X.java', java.original_path('tree/easy/XAttempt.java')
    assert_equal 'tree/easy/x.rb', java.original_path('tree/easy/x.attempt.rb')
  end

  def test_function_becomes_static_stub_with_camel_case_names_and_arguments
    ruby = <<~RUBY
      # frozen_string_literal: true

      def two_sum(nums, target)
        nums
      end

      def runner(input)
        input
      end

      if __FILE__ == $PROGRAM_NAME
        def not_this(x); end
      end
    RUBY

    assert_equal <<~JAVA, render(ruby, 'arrays_and_hashing/easy/TwoSum.java')
      package arrays_and_hashing.easy;

      // https://leetcode.com/problems/x/

      public class TwoSum {
          public static Object twoSum(Object nums, Object target) {
              return null;
          }

      }
    JAVA
  end

  def test_class_named_like_the_file_becomes_the_class_itself
    ruby = <<~RUBY
      class MinStack
        attr_reader :items

        def initialize
          @items = []
        end

        def push(val)
          @items << val
        end

        def get_min
          1
        end

        private

        def helper(x)
          x
        end
      end
    RUBY

    java = render(ruby, 'stack/medium/MinStack.java')
    assert_includes java, "public class MinStack {\n    public MinStack() {\n    }\n"
    assert_includes java, 'public Object push(Object val) {'
    assert_includes java, 'public Object getMin() {'
    refute_includes java, 'helper'
  end

  def test_other_classes_are_nested_and_node_helpers_skipped
    ruby = <<~RUBY
      class ListNode
        def initialize(val = 0, next_node = nil); end
      end

      class TimeMap
        def initialize(size, *rest, &block); end

        def set(key, value:); end
      end
    RUBY

    java = render(ruby, 'binary_search/medium/TimeBasedKeyValueStore.java')
    refute_includes java, 'ListNode'
    assert_includes java, "    static class TimeMap {\n        public TimeMap(Object size, Object rest, Object block)"
    assert_includes java, 'public Object set(Object key, Object value) {'
  end

  def test_java_keywords_get_a_different_name
    assert_includes render("def f(new, default)\nend\n"), 'f(Object newValue, Object defaultValue)'
  end

  def test_create_writes_once_and_keeps_existing_files
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'two_sum.rb'), "def two_sum(nums)\nend\n")
      problems = { 'two-sum' => { 'file' => 'TwoSum.java', 'ruby_file' => 'two_sum.rb',
                                  'link' => 'https://leetcode.com/problems/two-sum/' } }
      scaffold = Srs::JavaScaffold.new(problems, root: dir)

      assert scaffold.create_new('TwoSum.java', 'two-sum')
      refute scaffold.create_new('TwoSum.java', 'two-sum')
      assert scaffold.create_attempt('TwoSum.java')
      assert_includes File.read(File.join(dir, 'TwoSumAttempt.java')), 'public class TwoSumAttempt {'
    end
  end
end

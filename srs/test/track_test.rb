# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/srs'

class TrackTest < Minitest::Test
  def test_java_track_keeps_only_problems_solved_in_ruby_and_points_files_at_java
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'tree'))
      File.write(File.join(dir, 'tree', 'invert_tree.rb'), "def invert_tree(root)\nend\n")
      File.write(File.join(dir, 'tree', 'scaffold_only.rb'), "# https://leetcode.com/problems/x/\n")
      all = {
        'invert-tree' => { 'name' => 'Invert', 'file' => 'tree/invert_tree.rb' },
        'scaffold-only' => { 'name' => 'Scaffold only', 'file' => 'tree/scaffold_only.rb' },
        'missing' => { 'name' => 'Missing', 'file' => 'tree/missing.rb' },
        'no-file' => { 'name' => 'No file', 'file' => nil }
      }

      java = Srs::JAVA_TRACK.problems(all, root: dir)

      assert_equal ['invert-tree'], java.keys
      assert_equal 'tree/InvertTree.java', java['invert-tree']['file']
      assert_equal 'tree/invert_tree.rb', java['invert-tree']['ruby_file']
      assert_same all, Srs::RUBY_TRACK.problems(all, root: dir)
    end
  end

  def test_tracks_have_their_own_state_and_commands
    refute_equal Srs::RUBY_TRACK.state_path, Srs::JAVA_TRACK.state_path
    assert_equal 'bin/srs java', Srs::JAVA_TRACK.command
    assert_equal Srs::Scaffold, Srs::RUBY_TRACK.scaffold({})
    assert_instance_of Srs::JavaScaffold, Srs::JAVA_TRACK.scaffold({})
  end

  def test_java_config_loads_and_is_valid
    config = Srs::Config.load(Srs::JAVA_TRACK.config_path)

    assert_equal %w[A B C], config.dig('session', 'slots').keys
    assert_equal 0, config.dig('unlock', 'topic_ratio')
  end
end

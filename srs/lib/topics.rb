# frozen_string_literal: true

module Srs
  # Topic keys, their folders, and NeetCode's roadmap (topic => prerequisite topics).
  module Topics
    ROADMAP = {
      'arrays' => { folder: 'arrays_and_hashing', prereqs: [] },
      'two_pointers' => { folder: 'two_pointers', prereqs: %w[arrays] },
      'sliding_window' => { folder: 'sliding_window', prereqs: %w[two_pointers] },
      'stack' => { folder: 'stack', prereqs: %w[arrays] },
      'binary_search' => { folder: 'binary_search', prereqs: %w[two_pointers] },
      'linked_list' => { folder: 'linked_list', prereqs: %w[two_pointers] },
      'trees' => { folder: 'tree', prereqs: %w[binary_search linked_list] },
      'tries' => { folder: 'tries', prereqs: %w[trees] },
      'heap' => { folder: 'heap', prereqs: %w[trees] },
      'backtracking' => { folder: 'backtracking', prereqs: %w[trees] },
      'graphs' => { folder: 'graphs', prereqs: %w[backtracking] },
      'advanced_graphs' => { folder: 'advanced_graphs', prereqs: %w[heap graphs] },
      'dp_1d' => { folder: 'dp_1d', prereqs: %w[backtracking] },
      'dp_2d' => { folder: 'dp_2d', prereqs: %w[graphs dp_1d] },
      'greedy' => { folder: 'greedy', prereqs: %w[heap] },
      'intervals' => { folder: 'intervals', prereqs: %w[heap] },
      'math_geometry' => { folder: 'math_geometry', prereqs: %w[graphs bit_manipulation] },
      'bit_manipulation' => { folder: 'bit_manipulation', prereqs: %w[dp_1d] }
    }.freeze

    # The SQL track (§14): the seven sections of LeetCode's Top SQL 50 study plan, in its order.
    # String functions only need grouping, so they open alongside the advanced joins.
    SQL_ROADMAP = {
      'select' => { folder: 'database/select', prereqs: [] },
      'basic_joins' => { folder: 'database/basic_joins', prereqs: %w[select] },
      'aggregates' => { folder: 'database/aggregates', prereqs: %w[basic_joins] },
      'sorting_grouping' => { folder: 'database/sorting_grouping', prereqs: %w[aggregates] },
      'advanced_joins' => { folder: 'database/advanced_joins', prereqs: %w[sorting_grouping] },
      'subqueries' => { folder: 'database/subqueries', prereqs: %w[advanced_joins] },
      'strings' => { folder: 'database/strings', prereqs: %w[sorting_grouping] }
    }.freeze

    # Sheet "Category" column => topic key. "Graph" is the sheet's label for
    # Longest Consecutive Sequence, which is an Arrays problem.
    CATEGORIES = {
      'Arrays' => 'arrays',
      'Graph' => 'arrays',
      'Two Pointers' => 'two_pointers',
      'Sliding Window' => 'sliding_window',
      'Stack' => 'stack',
      'Binary Search' => 'binary_search',
      'Linked List' => 'linked_list',
      'Trees' => 'trees',
      'Tries' => 'tries',
      'Heap / Priority Queue' => 'heap',
      'Backtracking' => 'backtracking',
      'Graphs' => 'graphs',
      'Advanced Graphs' => 'advanced_graphs',
      '1-D Dynamic Programming' => 'dp_1d',
      '2-D Dynamic Programming' => 'dp_2d',
      'Greedy' => 'greedy',
      'Intervals' => 'intervals',
      'Math & Geometry' => 'math_geometry',
      'Bit Manipulation' => 'bit_manipulation'
    }.freeze

    module_function

    def folder(topic)
      ROADMAP.fetch(topic)[:folder]
    end

    # The current track's roadmap: NeetCode's for Ruby and Java, the study plan's for SQL.
    def roadmap
      Srs.track.roadmap
    end

    def prereqs(topic)
      roadmap.fetch(topic)[:prereqs]
    end

    def for_category(category)
      CATEGORIES.fetch(category) { raise "unknown sheet category: #{category.inspect}" }
    end

    def for_folder(folder)
      ROADMAP.find { |_, t| t[:folder] == folder }&.first
    end
  end
end

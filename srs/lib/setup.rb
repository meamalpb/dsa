# frozen_string_literal: true

require 'fileutils'

module Srs
  # `bin/srs setup` — DESIGN.md §3. Safe to re-run: only fills in what's missing
  # and never changes an existing state.yml entry.
  class Setup
    EXCLUDED_DIRS = %w[codeforces/ random/ srs/ bin/ linked_list/helpers/].freeze
    FILE_SLUG = %r{leetcode\.com/problems/([a-z0-9-]+)}

    def initialize(out: $stdout, today: Date.today)
      @out = out
      @today = today
    end

    def run
      rows = Sheet.rows
      files = local_files
      old = Store.load(PROBLEMS_PATH, {})
      problems = rows.to_h { |row| [row.slug, build(row, files[row.slug], old.fetch(row.slug, {}))] }

      fetch_details(problems)
      problems.each { |slug, p| fill_links_and_path(slug, p) }
      Store.save(PROBLEMS_PATH, problems)

      created = create_folders(problems)
      state = Store.load(STATE_PATH, Store.default_state)
      seeded = seed(state, problems, files)
      Store.save(STATE_PATH, state)

      report(problems, state, files, created, seeded)
    end

    private

    # slug => repo-relative path, for every solution file with a LeetCode header.
    def local_files
      Dir.glob('**/*.rb', base: ROOT).sort.each_with_object({}) do |path, map|
        next if EXCLUDED_DIRS.any? { |dir| path.start_with?(dir) } || path.end_with?('.attempt.rb')

        slug = File.read(File.join(ROOT, path))[FILE_SLUG, 1] or next
        warn "  two files for #{slug}: #{map[slug]} and #{path} (using the first)" if map.key?(slug)
        map[slug] ||= path
      end
    end

    def build(row, file, old)
      # File location wins over the sheet's category.
      topic = (file && Topics.for_folder(file.split('/').first)) || Topics.for_category(row.category)
      {
        'name' => row.name,
        'topic' => topic,
        'difficulty' => old['difficulty'],
        'paid_only' => old['paid_only'],
        'link' => "https://leetcode.com/problems/#{row.slug}/",
        'alt_link' => nil,
        'file' => file,
        'order' => row.order,
        'notes' => row.notes
      }
    end

    def fetch_details(problems)
      missing = problems.select { |_, p| p['difficulty'].nil? }
      return if missing.empty?

      @out.puts "Fetching difficulty for #{missing.size} problems (~#{missing.size * Leetcode::DELAY}s)..."
      missing.each_with_index do |(slug, p), i|
        sleep Leetcode::DELAY if i.positive?
        p.merge!(Leetcode.details(slug))
        @out.print '.'
      rescue StandardError => e
        @out.puts "\n  #{slug}: #{e.message} — re-run setup to retry"
      end
      @out.puts
    end

    def fill_links_and_path(slug, problem)
      problem['alt_link'] = Leetcode.free_link(slug) if problem['paid_only']
      return if problem['file'] || problem['difficulty'].nil?

      problem['file'] = File.join(Topics.folder(problem['topic']), problem['difficulty'].downcase,
                                  "#{slug.tr('-', '_')}.rb")
    end

    def create_folders(problems)
      dirs = problems.values.filter_map { |p| p['file'] && File.dirname(p['file']) }.uniq
      dirs.reject { |d| Dir.exist?(File.join(ROOT, d)) }.each { |d| FileUtils.mkdir_p(File.join(ROOT, d)) }
    end

    # Matched files count as solved once, on the date they were first committed
    # (later commits may only be cleanups, like adding a header). A file with no
    # top-level def/class is an unsolved `srs start` scaffold, not a solution.
    def seed(state, problems, files)
      problems.keys.filter_map do |slug|
        path = files[slug]
        next if path.nil? || state['problems'].key?(slug)
        next unless File.read(File.join(ROOT, path)).match?(/^(def|class|module) /)

        date = first_commit_date(path)
        state['problems'][slug] = {
          'reps' => 1, 'ease' => 2.5, 'interval' => 1,
          'last_reviewed' => date, 'next_review' => date + 1,
          'history' => [{ 'date' => date, 'grade' => 'seed' }]
        }
        slug
      end
    end

    def first_commit_date(path)
      out = IO.popen(['git', '-C', ROOT, 'log', '--follow', '--diff-filter=A', '--format=%cs', '--', path], &:read)
      first = out.split.last
      first ? Date.parse(first) : @today
    end

    def report(problems, state, files, created, seeded)
      matched = problems.keys.select { |s| files.key?(s) }
      @out.puts "\nMatched #{matched.size} local files to sheet rows:"
      matched.each { |s| @out.puts "  #{problems[s]['topic'].ljust(15)} #{problems[s]['name'].ljust(45)} #{files[s]}" }

      ignored = (files.keys - problems.keys).map { |s| File.basename(files[s]) }
      @out.puts "\nIgnored #{ignored.size} files not on the sheet: #{ignored.join(', ')}"
      @out.puts "\nSeeded #{seeded.size} problems into state.yml." unless seeded.empty?
      @out.puts "\nCreated #{created.size} folders: #{created.join(', ')}" unless created.empty?

      Report.premium(problems, @out)
      Report.coverage(problems, state, @out)
    end
  end
end

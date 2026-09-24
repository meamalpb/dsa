# frozen_string_literal: true

require 'date'
require 'yaml'

module Srs
  # Reads and writes the YAML data files.
  module Store
    module_function

    def load(path, default)
      return default unless File.exist?(path)

      YAML.safe_load_file(path, permitted_classes: [Date]) || default
    end

    # Write to a temp file and rename, so an interrupted run can't leave
    # state.yml half-written.
    def save(path, data)
      tmp = "#{path}.tmp"
      File.write(tmp, unshare(data).to_yaml(line_width: -1))
      File.rename(tmp, path)
    end

    # YAML writes an object that appears twice (e.g. one Date used for both
    # last_reviewed and a history entry) as an &alias, which safe_load then
    # refuses. Copying every value keeps the file alias-free.
    def unshare(obj)
      case obj
      when Hash then obj.to_h { |k, v| [k, unshare(v)] }
      when Array then obj.map { |v| unshare(v) }
      else obj.dup
      end
    end

    def default_state
      {
        'problems' => {},
        'last_new_on' => nil,
        'next_forced_pool' => 'medium_hard',
        'session' => nil
      }
    end
  end
end

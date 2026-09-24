# frozen_string_literal: true

require 'csv'
require 'net/http'

module Srs
  # The published NeetCode 150 Google Sheet. It never changes, so it's only read by setup.
  module Sheet
    CSV_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vRLw2LeIkVdQ4bcZxGLJQjSfzQtbI7NS94K4hnJeZMLCMAch_Yz2bp3AoqFTGbyGYXQ8MQ7smkmy4ca/pub?output=csv'
    # Also matches .../accounts/login/?next=/problems/<slug>/
    SLUG = %r{/problems/([a-z0-9-]+)}
    # Sheet links LeetCode has since renamed.
    SLUG_FIXES = { 'coin-change-2' => 'coin-change-ii' }.freeze

    Row = Struct.new(:order, :category, :name, :slug, :notes, keyword_init: true)

    module_function

    def rows
      CSV.parse(download(CSV_URL), headers: true).each_with_index.map do |r, i|
        slug = r['Link'].to_s[SLUG, 1] or raise "no LeetCode slug in sheet row #{i + 2}: #{r['Link']}"
        slug = SLUG_FIXES.fetch(slug, slug)
        notes = r.fields[4].to_s.strip
        Row.new(order: i + 1, category: r['Category'].strip, name: r['Name'].strip,
                slug: slug, notes: notes.empty? ? nil : notes)
      end
    end

    def download(url, redirects = 5)
      res = Net::HTTP.get_response(URI(url))
      case res
      when Net::HTTPSuccess then res.body.force_encoding('UTF-8')
      when Net::HTTPRedirection
        raise 'sheet download: too many redirects' if redirects.zero?

        download(res['location'], redirects - 1)
      else
        raise "sheet download failed: HTTP #{res.code}"
      end
    end
  end
end

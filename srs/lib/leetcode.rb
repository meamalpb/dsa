# frozen_string_literal: true

require 'json'
require 'net/http'

module Srs
  # Difficulty + premium flag from LeetCode's GraphQL endpoint. robots.txt disallows
  # /graphql for crawlers, so only setup calls this, once per slug, throttled.
  module Leetcode
    URL = URI('https://leetcode.com/graphql')
    QUERY = 'query q($slug: String!) { question(titleSlug: $slug) { difficulty isPaidOnly } }'
    DELAY = 1 # seconds between requests

    # Premium problems => NeetCode's free version.
    NEETCODE_SLUGS = {
      'encode-and-decode-strings' => 'string-encode-and-decode',
      'meeting-rooms' => 'meeting-schedule',
      'meeting-rooms-ii' => 'meeting-schedule-ii',
      'walls-and-gates' => 'islands-and-treasure',
      'graph-valid-tree' => 'valid-tree',
      'number-of-connected-components-in-an-undirected-graph' => 'count-connected-components',
      'alien-dictionary' => 'foreign-dictionary'
    }.freeze

    module_function

    def free_link(slug)
      NEETCODE_SLUGS[slug] && "https://neetcode.io/problems/#{NEETCODE_SLUGS[slug]}"
    end

    def details(slug)
      res = Net::HTTP.post(URL, { query: QUERY, variables: { slug: slug } }.to_json,
                           'Content-Type' => 'application/json', 'Referer' => 'https://leetcode.com')
      raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      question = JSON.parse(res.body).dig('data', 'question') or raise 'no such problem'
      { 'difficulty' => question['difficulty'], 'paid_only' => question['isPaidOnly'] }
    end
  end
end

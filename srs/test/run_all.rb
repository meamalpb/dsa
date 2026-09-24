# frozen_string_literal: true

# ruby srs/test/run_all.rb
Dir[File.join(__dir__, '*_test.rb')].each { |f| require f }

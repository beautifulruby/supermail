# frozen_string_literal: true

require 'rails/all'
require 'rails/generators/test_case'
require 'minitest/assertions'
require "supermail"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require "rails/generators/testing/behavior"
require "rails/generators/testing/setup_and_teardown"
require "rails/generators/testing/assertions"

RSpec.configure do |config|
  config.include Rails::Generators::Testing::Behavior,         type: :generator
  config.include Rails::Generators::Testing::SetupAndTeardown, type: :generator
  config.include Rails::Generators::Testing::Assertions,       type: :generator
  config.include Minitest::Assertions,                         type: :generator
  config.include FileUtils,                                    type: :generator
end

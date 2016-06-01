require "delivery_matchers"

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include DeliveryMatchers
  config.include UnitTestingMatchers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = :doc
  end

  config.order = :random
  Kernel.srand config.seed

  config.after :each do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end
end

# Silence ActiveJob log output during test runs
ActiveJob::Base.logger = Logger.new(nil)

# Use in-memory job queue for testing
ActiveJob::Base.queue_adapter = :test

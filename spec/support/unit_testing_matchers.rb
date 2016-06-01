module UnitTestingMatchers
  extend RSpec::Matchers::DSL

  matcher :be_failure do |expected|
    def supports_block_expectations?
      true
    end

    match do |block|
      begin
        block.call
        false
      rescue RSpec::Expectations::ExpectationNotMetError
        true
      end
    end

    def failure_message
      "Expectation should have failed."
    end

    def failure_message_when_negated
      "Expectation should have passed."
    end
  end
end

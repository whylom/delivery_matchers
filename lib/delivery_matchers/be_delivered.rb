module DeliveryMatchers
  class BeDelivered
    attr_reader :options, :email

    def initialize(first={}, second={})
      case first
      when Time
        # Allow user to specify the :on date as the first argument:
        # be_delivered 1.day.from_now, via_queue: 'priority'
        options = second
        options[:on] = first
      when Hash
        options = first
      end

      # Rename the hash keys used by this matcher to match the keys used by
      # ActionMailer::MessageDelivery#deliver_later
      options[:wait]       ||= options[:in]
      options[:wait_until] ||= options[:on]
      options[:queue]      ||= options[:via_queue]

      @options = options
    end

    def matches?(email)
      @email = email
      enqueued_jobs.any? { |job| match_expected?(job) }
    end

    def failure_message
      enqueued = enqueued_jobs.map(&:inspect).join("\n  ")

      [
        "expected to find this mail delivery job in queue:",
        "  #{expected_job}",
        "instead found these jobs:",
        "  #{enqueued}"
      ].join("\n")
    end

    def failure_message_when_negated
      [
        "expected NOT to find this mail delivery job in queue:",
        "  #{expected_job}"
      ].join("\n")
    end

    private

    def match_expected?(job)
      args_match?(job) && options_match?(job)
    end

    def args_match?(job)
      job[:args] == expected_args
    end

    def options_match?(job)
      class_matches?(job) && queue_matches?(job) && time_matches?(job)
    end

    def class_matches?(job)
      job[:job] == expected_class
    end

    def queue_matches?(job)
      return true if options[:queue].nil?
      job[:queue] == options[:queue]
    end

    def time_matches?(job)
      return true unless options[:wait] || options[:wait_until]

      if options[:wait]
        expected = Time.current + options[:wait]
      elsif options[:wait_until]
        expected = options[:wait_until].to_time
      end

      # Difference between expected and actual must be less than 1 second
      (job[:at].to_i - expected.to_i).abs <= 1
    end

    def expected_job
      job = {
        job:   expected_class,
        args:  expected_args,
        queue: expected_queue
      }

      if expected_delivery_time
        job[:at] = expected_delivery_time
      end

      job
    end

    def expected_class
      ActionMailer::DeliveryJob
    end

    def expected_queue
      options[:queue] || 'mailers'
    end

    def expected_delivery_time
      if options[:wait_until]
        options[:wait_until].to_time.to_f
      elsif options[:wait]
        (Time.current + options[:wait]).to_f
      end
    end

    def expected_args
      mailer = email.instance_variable_get('@mailer').to_s
      method = email.instance_variable_get('@mail_method').to_s
      args   = email.instance_variable_get('@args')

      [mailer, method, 'deliver_now', *global_ids(args)]
    end

    def global_ids(array)
      Array(array).map { |obj| global_id(obj) }
    end

    def global_id(obj)
      if obj.respond_to? :to_global_id
        { "_aj_globalid" => obj.to_global_id.to_s }
      else
        obj
      end
    end

    def enqueued_jobs
      ActiveJob::Base.queue_adapter.enqueued_jobs
    end
  end
end

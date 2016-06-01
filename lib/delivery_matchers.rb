require "action_mailer"
require "active_job"

require "delivery_matchers/be_delivered"
require "delivery_matchers/version"

module DeliveryMatchers
  def be_delivered(*args)
    BeDelivered.new(*args)
  end
end

require "spec_helper"

RSpec.describe DeliveryMatchers::BeDelivered do
  class Mailer < ActionMailer::Base
    def message(*); end
  end

  let(:mail) { Mailer.message("I'm an argument!") }

  describe "successful matching" do
    context "when mail is enqueued with no arguments" do
      before { mail.deliver_later }

      it "matches with no arguments" do
        expect(mail).to be_delivered
      end

      it "matches the default queue" do
        expect(mail).to be_delivered queue: "mailers"
        expect(mail).to be_delivered via_queue: "mailers"
      end
    end

    context "when mail is enqueued with a `wait_until` date" do
      before { mail.deliver_later wait_until: 1.day.from_now }

      it "matches with no arguments" do
        expect(mail).to be_delivered
      end

      it "matches with the date provided as the 1st argument" do
        expect(mail).to be_delivered 1.day.from_now
      end

      it "matches with the date provided as a keyword argument" do
        expect(mail).to be_delivered wait_until: 1.day.from_now
        expect(mail).to be_delivered on: 1.day.from_now
      end
    end

    context "when mail is enqueued with a `wait` interval" do
      before { mail.deliver_later wait: 1.week }

      it "matches with no arguments" do
        expect(mail).to be_delivered
      end

      it "matches with the interval provided" do
        expect(mail).to be_delivered wait: 1.week
        expect(mail).to be_delivered in: 1.week
      end
    end

   context "when mail is enqueued with a `queue`" do
      before { mail.deliver_later queue: "priority" }

      it "matches with no arguments" do
        expect(mail).to be_delivered
      end

      it "matches with the queue provided" do
        expect(mail).to be_delivered queue: "priority"
        expect(mail).to be_delivered via_queue: "priority"
      end
    end

   context "when mail is enqueued with an interval AND a queue" do
      before { mail.deliver_later queue: "lazy", wait_until: 1.day.from_now }

      it "matches with no arguments" do
        expect(mail).to be_delivered
      end

      it "matches with the interval provided" do
        expect(mail).to be_delivered 1.day.from_now
        expect(mail).to be_delivered wait_until: 1.day.from_now
        expect(mail).to be_delivered on: 1.day.from_now
      end

      it "matches with the queue provided" do
        expect(mail).to be_delivered queue: "lazy"
        expect(mail).to be_delivered via_queue: "lazy"
      end

      it "matches with both the interval and queue provided" do
        expect(mail).to be_delivered 1.day.from_now, via_queue: "lazy"
        expect(mail).to be_delivered wait_until: 1.day.from_now, queue: "lazy"
        expect(mail).to be_delivered on: 1.day.from_now, via_queue: "lazy"
      end
    end
  end

  describe "unsuccessful matching" do
    context "when mail is not enqueued at all" do
      it "does not match" do
        expect { expect(mail).to be_delivered }.to be_failure
      end
    end

    context "when mail is enqueued with no arguments" do
      before { mail.deliver_later }

      let(:date) { 1.day.from_now }

      it "does not match when an argument is expected" do
        expect { expect(mail).to be_delivered date                  }.to be_failure
        expect { expect(mail).to be_delivered wait_until: date      }.to be_failure
        expect { expect(mail).to be_delivered on: date              }.to be_failure

        expect { expect(mail).to be_delivered wait: 1.week          }.to be_failure
        expect { expect(mail).to be_delivered in: 1.week            }.to be_failure

        expect { expect(mail).to be_delivered queue: "priority"     }.to be_failure
        expect { expect(mail).to be_delivered via_queue: "priority" }.to be_failure
      end
    end

    context "when mail is enqueued with the wrong date" do
      before { mail.deliver_later wait_until: 1.day.from_now }

      it "does not match" do
        expect { expect(mail).to be_delivered 2.days.from_now }.to be_failure
        expect { expect(mail).to be_delivered wait_until: 2.days.from_now }.to be_failure
        expect { expect(mail).to be_delivered on: 2.days.from_now }.to be_failure
      end
    end

    context "when mail is enqueued with the wrong interval" do
      before { mail.deliver_later wait: 1.week }

      it "does not match" do
        expect { expect(mail).to be_delivered wait: 6.days }.to be_failure
        expect { expect(mail).to be_delivered in: 6.days }.to be_failure
      end
    end

    context "when mail is enqueued in the wrong queue" do
      before { mail.deliver_later queue: "priority" }

      it "does not match" do
        expect { expect(mail).to be_delivered queue: "lazy" }.to be_failure
        expect { expect(mail).to be_delivered via_queue: "lazy" }.to be_failure
      end
    end
  end
end

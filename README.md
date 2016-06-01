# DeliveryMatchers

[![Build Status](https://semaphoreci.com/api/v1/generalassembly/delivery_matchers/branches/master/badge.svg)](https://semaphoreci.com/generalassembly/delivery_matchers)

An RSpec custom matcher for ActionMailer's `deliver_later` method.

This matcher was extracted from a General Assembly product with a considerable amount of logic to determine when to send certain transactional emails to different subsets of students.

We wanted to ensure this code had bulletproof test coverage. Inspecting the in-memory ActiveJob queue let us test our delivery logic, but it also allowed a lot of low-level details to leak into our tests, making them harder to read.

We rolled this custom matcher to keep our test code beautiful. We hope you find it as useful as we did!


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'delivery_matchers'
```

and include the `DeliveryMatchers` module in your RSpec config:

```ruby
RSpec.configure do |config|
  config.include DeliveryMatchers
end
```


## Usage

### Basics

Let's assume you have a garden-variety ActionMailer class:

```ruby
class UserMailer < ActionMailer::Base
  def welcome(user)
    @user = user
  end
end
```

Let's further assume you have a controller action that enqueues a welcome email for delivery with `deliver_later`, but only under certain circumstances:


```ruby
class UsersController < ApplicationController
  def create
    ...
    if user.emailable?
      UserMailer(user).welcome.deliver_later
    end
    ...
  end
end
```

With this custom matcher, you can write tests to assert that the controller enqueues an email for delivery.

```ruby
expect( UserMailer.welcome(emailable_user) ).to be_delivered
```

You can also assert that an email is **not** delivered, in cases where that is the expected behavior.

```ruby
expect( UserMailer.welcome(non_emailable_user) ).not_to be_delivered
```

### Delivery options

#### wait_until

If you schedule an email for delivery on a future date with `wait_until`

```ruby
UserMailer.welcome(user).deliver_later(wait_until: 1.day.from_now)
```

you can test it with

```ruby
let(:email) { UserMailer.welcome(user) }
expect(email).to be_delivered 1.day.from_now
```

or with the more explicit (and sometimes more readable) form

```ruby
expect(email).to be_delivered on: expected_date
```

#### wait

If you use `wait` to schedule an email for delivery after a certain interval

```ruby
UserMailer.welcome(user).deliver_later(wait: 2.days)
```

you can test it like this

```ruby
expect(email).to be_delivered in: 2.days
```

#### queue

You can also test that a delivery job was put into a particular queue

```ruby
UserMailer.welcome(user).deliver_later(queue: "priority")
```

like this

```ruby
expect(email).to be_delivered via_queue: "priority"
```

`via_queue` can also be combined with either the `on` or `in` options

```ruby
expect(email).to be_delivered 3.days.from_now, via_queue: "priority"

expect(email).to be_delivered in: 2.days, via_queue: "priority"
```

### Alternative interface

`be_delivered` supports `in`, `on`, and `via_queue` as a convenience for readability. But if you prefer consistency with the code being tested, you can also use the same keys provided to `deliver_later`.

```ruby
expect(email).to be_delivered wait_until: expected_date

expect(email).to be_delivered wait: 2.days

expect(email).to be_delivered queue: "priority"
```

### A note on precision

This matcher performs all time comparisons with a precision of 1 second. If you see intermittent errors as a result, consider using [ActiveSupport's TimeHelpers](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html) or the [Timecop gem](https://github.com/travisjeffery/timecop) to freeze time in your tests.

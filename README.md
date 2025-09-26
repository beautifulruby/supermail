# Supermail

Organize emails with plain 'ol Ruby objects in a Rails application, like this:

```ruby
# ./app/email/user/welcome.rb
class User::WelcomeEmail < ApplicationEmail
  def initialize(person:)
    @person = person
  end

  def to = @person.email
  def subject = "Welcome to Beautiful Ruby"
  def body
    super do
      <<~_
      Hi #{@person.name},

      You're going to learn a ton at https://beautifulruby.com.
      _
    end
  end
end
```

Contrast that with rails ActionMailer, where you will spend 20 minutes trying to figure out how to send an email. I created this gem because I got tired of digging through Rails docs to understand how to intialize an email and send it. PORO's FTW!

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add supermail
```

Then install it in Rails.

```bash
rails generate supermail:install
```

This creates the `ApplicationEmail` class at `app/emails/application_email.rb` where you can customize the base for all emails, including setting defaults like the `from` address.

```ruby
class ApplicationEmail < Supermail::Rails::Base
  def from = "website@example.com"
  def to = nil
  def subject = nil
  def body
     <<~_
     #{yield if block_given?}

     Best,

     The Example.com Team
     _
  end
end
```

## Usage

To generate a new email, run the following command:

```bash
rails generate supermail:email User::Welcome
```

This will create a new email class in `app/mailers/user/welcome_email.rb`.

```ruby
# ./app/email/user/welcome.rb
class User::WelcomeEmail < ApplicationEmail
  def body = <<~PLAIN
    Hello there!
  PLAIN
end
```


```ruby
# ./app/email/user/welcome.rb
class User::WelcomeEmail < ApplicationEmail
  def initialize(person:)
    @person = person
  end

  def to = @person.email
  def subject = "Welcome to the website"
  def body
    super do
      <<~_
      Hi #{@person.name},

      Welcome to the website We're excited to have you on board.
      _
    end
  end
end
```

Then, to send the email.

```ruby
User::Welcome.new(user: User.first).deliver_now
```

If you want to tweak the message on the fly, you can modify the message, then deliver it.

```ruby
User::Welcome.new(user: User.first).message.tap do
  it.to << "another@example.com"
end.deliver_now
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/supermail.

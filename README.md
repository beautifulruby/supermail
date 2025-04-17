# Supermail

Supermail is a slightly more intuitive way of organizing Emails in a Rails application.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add supermail
```

Then install it in Rails.

```bash
rails generate supermail:install
```

This creates the `app/emails/application_email.rb` file that you can customize as the base for all emails.

```ruby
class ApplicationEmail < Supermail::Email
  def from = "Supermail <noreply@supermail.com>"

  class HTML
    def after_template
      p { "Best, The Supermail Team" }
    end
  end

  class Text
    def after_template
      "Best,\nThe Supermail Team"
    end
  end
end
```

## Usage

To generate a new email, run the following command:

```bash
rails generate supermail:email User::Welcome
```

This will create a new email class in `app/mailers/user/welcome.rb`.

```ruby
# ./app/email/user/welcome.rb
class User::Welcome < ApplicationEmail
  def initialize(user:)
    @user = user
  end

  def subject = "Welcome to Supermail!"

  class HTML
    def view_template
      h1 { "Welcome, #{@user.name}!" }
      p { "We're excited to have you on board." }
    end
  end

  class Text
    def view_template
      "Welcome, #{@user.name}!\n\nWe're excited to have you on board."
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/supermail.

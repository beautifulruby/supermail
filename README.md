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

## Support this project

Learn how to build UI's out of Ruby classes and support this project by ordering the [Phlex on Rails video course](https://beautifulruby.com/phlex).

[![](https://immutable.terminalwire.com/hmM9jvv7yF89frBUfjikUfRmdUsTVZ8YvXc7OnnYoERXfLJLzDcj5dFM7qdfMG2bqQLuw633Zt1gl3O7z0zKmH6k8QmifN7z0kJo.png)](https://beautifulruby.com/phlex/forms/introduction)


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

### Send emails from the server

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

### Launch the user's email client

Supermail clases can be used to generate `mailto:` links.

```erb
<%= link_to Support::OrderEmail.new(
      user: current_user,
      order: @order
    ).mail_to s%>
```

This opens your users email client with prefilled information. A support email about an order might look like this:

```ruby
class Support::OrderEmail < ApplicationEmail
  def initialize(user:, order:)
    @user = user
    @order = order
  end

  def to = "support@example.com"
  def from = @user.email
  def subject = "Question about order #{@order.id}"
  def body = <<~BODY
    Hi Support,

    I need help with my order #{@order.id}.

    Thanks,

    #{@user.name}
  BODY
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/supermail.

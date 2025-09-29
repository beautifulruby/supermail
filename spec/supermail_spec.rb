# frozen_string_literal: true

require "spec_helper"

class ExampleMailer < Supermail::Rails::Base
  def initialize(to:, from:, subject:, body:)
    @to = to
    @from = from
    @subject = subject
    @body = body
  end

  attr_reader :to, :from, :subject, :body
end

RSpec.describe ExampleMailer do
  let(:email) { described_class.new(
    to: "user@example.com",
    from: "support@example.com",
    subject: "Hello",
    body: "Hi there")
  }
  let(:message) { email.message }
  subject { message }

  it "builds a Mail::Message" do
    expect(subject).to be_a(Mail::Message)
  end

  it "sets the to header" do
    expect(subject.to).to eq(["user@example.com"])
  end

  it "sets the from header" do
    expect(subject.from).to eq(["support@example.com"])
  end

  it "sets the subject header" do
    expect(subject.subject).to eq("Hello")
  end

  it "sets the body" do
    expect(subject.body.to_s).to eq("Hi there")
  end

  describe "#mailto" do
    let(:full_mailer_class) do
      Class.new(Supermail::Rails::Base) do
        def initialize(to:, from:, subject:, body:, cc:, bcc:)
          @to = to
          @from = from
          @subject = subject
          @body = body
          @cc = cc
          @bcc = bcc
        end

        attr_reader :to, :from, :subject, :body, :cc, :bcc
      end
    end

    let(:full_mailer) do
      full_mailer_class.new(
        to: "recipient@example.com",
        from: "sender@example.com",
        subject: "Test Subject",
        body: "Test body content",
        cc: ["cc@example.com"],
        bcc: ["bcc@example.com"]
      )
    end

    it "passes all mail fields to the mailto URL" do
      result = full_mailer.mailto
      expect(result).to start_with("mailto:recipient@example.com?")
      expect(result).to include("from=sender%40example.com")
      expect(result).to include("subject=Test%20Subject")
      expect(result).to include("body=Test%20body%20content")
      expect(result).to include("cc=%5B%22cc%40example.com%22%5D")
      expect(result).to include("bcc=%5B%22bcc%40example.com%22%5D")
    end
  end
end

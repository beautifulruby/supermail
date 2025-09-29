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

  describe "with minimal configuration" do
    let(:minimal_mailer_class) do
      Class.new(Supermail::Rails::Base) do
        def to = "test@example.com"
        def from = nil
        def subject = nil
        def body = ""
        def cc = []
        def bcc = []
      end
    end

    let(:minimal_mailer) { minimal_mailer_class.new }

    it "generates a simple mailto URL when optional parameters are nil or empty" do
      result = minimal_mailer.mailto
      expect(result).to eq("mailto:test@example.com?body=")
    end
  end

  describe "with special characters" do
    let(:special_mailer_class) do
      Class.new(Supermail::Rails::Base) do
        def to = "test+tag@example.com"
        def from = "sender@example.com"
        def subject = "Hello & Welcome! 🎉"
        def body = "Line 1\nLine 2\n\nBest regards"
        def cc = []
        def bcc = []
      end
    end

    let(:special_mailer) { special_mailer_class.new }

    it "properly escapes special characters and unicode" do
      result = special_mailer.mailto
      expect(result).to include("mailto:test+tag@example.com?")
      expect(result).to include("subject=Hello%20%26%20Welcome%21")
      expect(result).to include("body=Line%201%0ALine%202%0A%0ABest%20regards")
    end
  end

  describe "with empty parameters" do
    let(:empty_mailer_class) do
      Class.new(Supermail::Rails::Base) do
        def to = "test@example.com"
        def from = ""
        def subject = ""
        def body = ""
        def cc = []
        def bcc = []
      end
    end

    let(:empty_mailer) { empty_mailer_class.new }

    it "includes empty string parameters but excludes empty arrays in the mailto URL" do
      result = empty_mailer.mailto
      expect(result).to include("from=")
      expect(result).to include("subject=")
      expect(result).to include("body=")
      expect(result).not_to include("cc=")
      expect(result).not_to include("bcc=")
    end
  end

  describe "with mixed array and string recipients" do
    let(:mixed_mailer_class) do
      Class.new(Supermail::Rails::Base) do
        def to = "primary@example.com"
        def from = "sender@example.com"
        def subject = "Mixed Recipients"
        def body = "Test message"
        def cc = "single-cc@example.com"
        def bcc = ["bcc1@example.com", "bcc2@example.com"]
      end
    end

    let(:mixed_mailer) { mixed_mailer_class.new }

    it "handles both string and array recipients correctly" do
      result = mixed_mailer.mailto
      expect(result).to include("cc=single-cc%40example.com")
      expect(result).to include("bcc=%5B%22bcc1%40example.com%22%2C%20%22bcc2%40example.com%22%5D")
    end
  end
end

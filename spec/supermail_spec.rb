# frozen_string_literal: true

require "spec_helper"

class ExampleMailer < Supermail::Rails::Base
  def initialize(to:, from:, subject:, body:, cc: [], bcc: [])
    @to = to
    @from = from
    @subject = subject
    @body = body
    @cc = cc
    @bcc = bcc
  end

  attr_reader :to, :from, :subject, :body, :cc, :bcc
end

RSpec.describe ExampleMailer do
  let(:email) { described_class.new(
    to: "user@example.com",
    from: "support@example.com",
    subject: "Hello",
    body: "Hi there",
    cc: ["cc@example.com"],
    bcc: ["bcc@example.com"])
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
    it "passes all mail fields to the mailto URL" do
      result = email.mailto
      expect(result).to start_with("mailto:user@example.com?")
      expect(result).to include("from=support%40example.com")
      expect(result).to include("subject=Hello")
      expect(result).to include("body=Hi%20there")
      expect(result).to include("cc=%5B%22cc%40example.com%22%5D")
      expect(result).to include("bcc=%5B%22bcc%40example.com%22%5D")
    end
  end
end

class HtmlMailer < Supermail::Rails::Base
  def initialize(to:, from:, subject:, body:, html_body:)
    @to = to
    @from = from
    @subject = subject
    @body = body
    @html_body = html_body
  end

  attr_reader :to, :from, :subject, :body, :html_body
end

RSpec.describe HtmlMailer do
  let(:email) { described_class.new(
    to: "user@example.com",
    from: "support@example.com",
    subject: "Hello",
    body: "Hi there",
    html_body: "<p>Hi there</p>")
  }
  let(:message) { email.message }

  it "creates a multipart email" do
    expect(message.multipart?).to be true
  end

  it "includes text part" do
    text_part = message.text_part
    expect(text_part).not_to be_nil
    expect(text_part.body.to_s).to eq("Hi there")
  end

  it "includes html part" do
    html_part = message.html_part
    expect(html_part).not_to be_nil
    expect(html_part.body.to_s).to eq("<p>Hi there</p>")
  end

  context "when html_body is nil" do
    let(:email) { described_class.new(
      to: "user@example.com",
      from: "support@example.com",
      subject: "Hello",
      body: "Hi there",
      html_body: nil)
    }

    it "creates a plain text email" do
      expect(message.multipart?).to be false
      expect(message.body.to_s).to eq("Hi there")
    end
  end

  context "when html_body is empty" do
    let(:email) { described_class.new(
      to: "user@example.com",
      from: "support@example.com",
      subject: "Hello",
      body: "Hi there",
      html_body: "")
    }

    it "creates a plain text email" do
      expect(message.multipart?).to be false
      expect(message.body.to_s).to eq("Hi there")
    end
  end

  context "when html_body contains only whitespace" do
    let(:email) { described_class.new(
      to: "user@example.com",
      from: "support@example.com",
      subject: "Hello",
      body: "Hi there",
      html_body: "   \n\t  ")
    }

    it "creates a multipart email" do
      # Mail gem may strip whitespace-only content, which is expected behavior
      expect(message.multipart?).to be true
    end
  end

  context "with cc and bcc" do
    class HtmlMailerWithCc < Supermail::Rails::Base
      def initialize(to:, from:, subject:, body:, html_body:, cc:, bcc:)
        @to = to
        @from = from
        @subject = subject
        @body = body
        @html_body = html_body
        @cc = cc
        @bcc = bcc
      end

      attr_reader :to, :from, :subject, :body, :html_body, :cc, :bcc
    end

    let(:email) { HtmlMailerWithCc.new(
      to: "user@example.com",
      from: "support@example.com",
      subject: "Hello",
      body: "Hi there",
      html_body: "<p>Hi there</p>",
      cc: ["cc@example.com"],
      bcc: ["bcc@example.com"])
    }
    let(:message) { email.message }

    it "includes cc recipients" do
      expect(message.cc).to eq(["cc@example.com"])
    end

    it "includes bcc recipients" do
      expect(message.bcc).to eq(["bcc@example.com"])
    end

    it "creates a multipart email" do
      expect(message.multipart?).to be true
    end
  end

  context "html part content type" do
    it "sets correct content type" do
      html_part = message.html_part
      expect(html_part.content_type).to include("text/html")
      expect(html_part.content_type).to include("charset=UTF-8")
    end
  end

  context "delivery methods" do
    let(:email) { described_class.new(
      to: "user@example.com",
      from: "support@example.com",
      subject: "Hello",
      body: "Hi there",
      html_body: "<p>Hi there</p>")
    }

    it "responds to deliver" do
      expect(email).to respond_to(:deliver)
    end

    it "responds to deliver_now" do
      expect(email).to respond_to(:deliver_now)
    end

    it "responds to deliver_later" do
      expect(email).to respond_to(:deliver_later)
    end
  end

  context "when body is empty but html_body is present" do
    let(:email) { described_class.new(
      to: "user@example.com",
      from: "support@example.com",
      subject: "Hello",
      body: "",
      html_body: "<p>Hi there</p>")
    }

    it "creates a multipart email" do
      expect(message.multipart?).to be true
    end

    it "includes empty text part" do
      expect(message.text_part.body.to_s).to eq("")
    end

    it "includes html part" do
      expect(message.html_part.body.to_s).to eq("<p>Hi there</p>")
    end
  end
end

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

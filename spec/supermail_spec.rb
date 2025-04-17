# frozen_string_literal: true

RSpec.describe Supermail::Email do
  it "has a version number" do
    expect(Supermail::VERSION).not_to be nil
  end

  let(:email) { Supermail::Email.new }
  before do
    email.to = "user@example.com"
    email.subject = "Hello"
  end

  describe "#to" do
    it "returns email address" do
      expect(email.to).to eq("user@example.com")
    end
  end
end

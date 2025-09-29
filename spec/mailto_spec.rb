# frozen_string_literal: true

require "spec_helper"

RSpec.describe Supermail::MailTo do
  describe ".href" do
    context "with minimal parameters" do
      subject { described_class.href(to: "test@example.com") }

      it { is_expected.to eq("mailto:test@example.com") }
    end

    context "with all parameters" do
      subject do
        described_class.href(
          to: "recipient@example.com",
          from: "sender@example.com",
          cc: "cc@example.com",
          bcc: "bcc@example.com",
          subject: "Test Subject",
          body: "Test body content"
        )
      end

      it { is_expected.to start_with("mailto:recipient@example.com?") }
      it { is_expected.to include("from=sender%40example.com") }
      it { is_expected.to include("cc=cc%40example.com") }
      it { is_expected.to include("bcc=bcc%40example.com") }
      it { is_expected.to include("subject=Test%20Subject") }
      it { is_expected.to include("body=Test%20body%20content") }
    end

    context "with nil parameters" do
      subject do
        described_class.href(
          to: "test@example.com",
          from: nil,
          subject: "Hello",
          cc: nil
        )
      end

      it { is_expected.to eq("mailto:test@example.com?subject=Hello") }
    end

    context "with empty arrays" do
      subject { described_class.href(to: "test@example.com", cc: []) }

      it { is_expected.to eq("mailto:test@example.com") }
    end

    context "with special characters" do
      subject do
        described_class.href(
          to: "test+tag@example.com",
          subject: "Hello & Welcome!",
          body: "Line 1\nLine 2"
        )
      end

      it { is_expected.to start_with("mailto:test+tag@example.com?") }
      it { is_expected.to include("subject=Hello%20%26%20Welcome%21") }
      it { is_expected.to include("body=Line%201%0ALine%202") }
    end

    context "with unicode characters" do
      subject { described_class.href(to: "test@example.com", subject: "Héllo Wørld! 🎉") }

      it { is_expected.to start_with("mailto:test@example.com?subject=") }
      it { is_expected.to include("H%C3%A9llo") }
      it { is_expected.to include("W%C3%B8rld") }
    end

    context "with multiple CC recipients" do
      subject { described_class.href(to: "test@example.com", cc: ["cc1@example.com", "cc2@example.com"]) }

      it { is_expected.to eq("mailto:test@example.com?cc=%5B%22cc1%40example.com%22%2C%20%22cc2%40example.com%22%5D") }
    end

    context "with multiple BCC recipients" do
      subject { described_class.href(to: "test@example.com", bcc: ["bcc1@example.com", "bcc2@example.com"]) }

      it { is_expected.to eq("mailto:test@example.com?bcc=%5B%22bcc1%40example.com%22%2C%20%22bcc2%40example.com%22%5D") }
    end
  end

  describe ".query" do
    context "with simple parameters" do
      subject { described_class.query(subject: "Hello", body: "World") }

      it { is_expected.to eq("subject=Hello&body=World") }
    end

    context "with no parameters" do
      subject { described_class.query }

      it { is_expected.to eq("") }
    end

    context "with nil values" do
      subject { described_class.query(subject: "Hello", from: nil, body: "World") }

      it { is_expected.to eq("subject=Hello&body=World") }
    end

    context "with special characters" do
      subject { described_class.query(subject: "Hello & Goodbye", body: "Line 1\nLine 2") }

      it { is_expected.to eq("subject=Hello%20%26%20Goodbye&body=Line%201%0ALine%202") }
    end

    context "with mixed parameter types" do
      subject do
        described_class.query(
          subject: "Test",
          cc: ["test1@example.com", "test2@example.com"],
          from: nil,
          body: ""
        )
      end

      it { is_expected.to include("subject=Test") }
      it { is_expected.to include("cc=%5B%22test1%40example.com%22%2C%20%22test2%40example.com%22%5D") }
      it { is_expected.to include("body=") }
      it { is_expected.not_to include("from=") }
    end

    context "with empty arrays" do
      subject { described_class.query(subject: "Test", cc: [], bcc: [], from: "test@example.com") }

      it { is_expected.to eq("subject=Test&from=test%40example.com") }
    end

    context "with mixed empty arrays and nil values" do
      subject { described_class.query(subject: "Test", cc: [], bcc: nil, from: "test@example.com", body: "") }

      it { is_expected.to eq("subject=Test&from=test%40example.com&body=") }
    end
  end

  describe ".mailto_escape" do
    it "is private" do
      expect(described_class.private_methods).to include(:mailto_escape)
    end

    context "with simple string" do
      subject { described_class.send(:mailto_escape, "Hello World") }

      it { is_expected.to eq("Hello%20World") }
    end

    context "with plus signs" do
      subject { described_class.send(:mailto_escape, "test+tag@example.com") }

      it { is_expected.to eq("test%2Btag%40example.com") }
    end

    context "with newlines" do
      subject { described_class.send(:mailto_escape, "Line 1\nLine 2") }

      it { is_expected.to eq("Line%201%0ALine%202") }
    end

    context "with ampersands" do
      subject { described_class.send(:mailto_escape, "Hello & Goodbye") }

      it { is_expected.to eq("Hello%20%26%20Goodbye") }
    end

    context "with non-string objects" do
      subject { described_class.send(:mailto_escape, 123) }

      it { is_expected.to eq("123") }
    end

    context "with carriage returns and line feeds" do
      subject { described_class.send(:mailto_escape, "Line 1\r\nLine 2") }

      it { is_expected.to eq("Line%201%0D%0ALine%202") }
    end

    context "with unicode characters" do
      subject { described_class.send(:mailto_escape, "Héllo 🎉") }

      it { is_expected.to include("H%C3%A9llo") }
    end

    context "with percent signs" do
      subject { described_class.send(:mailto_escape, "50% off") }

      it { is_expected.to eq("50%25%20off") }
    end

    context "with empty strings" do
      subject { described_class.send(:mailto_escape, "") }

      it { is_expected.to eq("") }
    end
  end
end

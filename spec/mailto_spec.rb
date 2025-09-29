# frozen_string_literal: true

require "spec_helper"

RSpec.describe Supermail::MailTo do
  describe ".href" do
    context "with minimal parameters" do
      it "generates a simple mailto URL" do
        result = described_class.href(to: "test@example.com")
        expect(result).to eq("mailto:test@example.com")
      end
    end

    context "with all parameters" do
      let(:params) do
        {
          to: "recipient@example.com",
          from: "sender@example.com",
          cc: "cc@example.com",
          bcc: "bcc@example.com",
          subject: "Test Subject",
          body: "Test body content"
        }
      end

      it "generates a complete mailto URL with query parameters" do
        result = described_class.href(**params)
        expected_query = [
          "from=sender%40example.com",
          "cc=cc%40example.com",
          "bcc=bcc%40example.com",
          "subject=Test%20Subject",
          "body=Test%20body%20content"
        ].join("&")

        expect(result).to eq("mailto:recipient@example.com?#{expected_query}")
      end
    end

    context "with nil parameters" do
      it "excludes nil parameters from the query string" do
        result = described_class.href(
          to: "test@example.com",
          from: nil,
          subject: "Hello",
          cc: nil
        )

        expect(result).to eq("mailto:test@example.com?subject=Hello")
      end
    end

    context "with empty arrays" do
      it "excludes empty arrays from the query string" do
        result = described_class.href(
          to: "test@example.com",
          cc: []
        )

        expect(result).to eq("mailto:test@example.com")
      end
    end

    context "with special characters" do
      it "properly escapes email addresses and content" do
        result = described_class.href(
          to: "test+tag@example.com",
          subject: "Hello & Welcome!",
          body: "Line 1\nLine 2"
        )

        expected_query = [
          "subject=Hello%20%26%20Welcome%21",
          "body=Line%201%0ALine%202"
        ].join("&")

        expect(result).to eq("mailto:test+tag@example.com?#{expected_query}")
      end
    end

    context "with unicode characters" do
      it "properly handles unicode content" do
        result = described_class.href(
          to: "test@example.com",
          subject: "Héllo Wørld! 🎉"
        )

        expect(result).to include("mailto:test@example.com?subject=")
        expect(result).to include("H%C3%A9llo")
        expect(result).to include("W%C3%B8rld")
      end
    end

    context "with multiple CC recipients" do
      it "handles array of CC recipients" do
        result = described_class.href(
          to: "test@example.com",
          cc: ["cc1@example.com", "cc2@example.com"]
        )

        expect(result).to eq("mailto:test@example.com?cc=%5B%22cc1%40example.com%22%2C%20%22cc2%40example.com%22%5D")
      end
    end

    context "with multiple BCC recipients" do
      it "handles array of BCC recipients" do
        result = described_class.href(
          to: "test@example.com",
          bcc: ["bcc1@example.com", "bcc2@example.com"]
        )

        expect(result).to eq("mailto:test@example.com?bcc=%5B%22bcc1%40example.com%22%2C%20%22bcc2%40example.com%22%5D")
      end
    end
  end

  describe ".query" do
    context "with simple parameters" do
      it "generates a proper query string" do
        params = { subject: "Hello", body: "World" }
        result = described_class.query(**params)

        expect(result).to eq("subject=Hello&body=World")
      end
    end

    context "with no parameters" do
      it "returns an empty string" do
        result = described_class.query
        expect(result).to eq("")
      end
    end

    context "with nil values" do
      it "excludes nil values from the query string" do
        params = { subject: "Hello", from: nil, body: "World" }
        result = described_class.query(**params)

        expect(result).to eq("subject=Hello&body=World")
      end
    end

    context "with special characters" do
      it "properly escapes parameter values" do
        params = { subject: "Hello & Goodbye", body: "Line 1\nLine 2" }
        result = described_class.query(**params)

        expect(result).to eq("subject=Hello%20%26%20Goodbye&body=Line%201%0ALine%202")
      end
    end

    context "with mixed parameter types" do
      it "handles strings, arrays, and nil values" do
        params = {
          subject: "Test",
          cc: ["test1@example.com", "test2@example.com"],
          from: nil,
          body: ""
        }
        result = described_class.query(**params)

        expect(result).to include("subject=Test")
        expect(result).to include("cc=%5B%22test1%40example.com%22%2C%20%22test2%40example.com%22%5D")
        expect(result).to include("body=")
        expect(result).not_to include("from=")
      end
    end

    context "with empty arrays" do
      it "excludes empty arrays from query string" do
        params = {
          subject: "Test",
          cc: [],
          bcc: [],
          from: "test@example.com"
        }
        result = described_class.query(**params)

        expect(result).to eq("subject=Test&from=test%40example.com")
        expect(result).not_to include("cc=")
        expect(result).not_to include("bcc=")
      end
    end

    context "with mixed empty arrays and nil values" do
      it "excludes both empty arrays and nil values from query string" do
        params = {
          subject: "Test",
          cc: [],
          bcc: nil,
          from: "test@example.com",
          body: ""
        }
        result = described_class.query(**params)

        expect(result).to eq("subject=Test&from=test%40example.com&body=")
        expect(result).not_to include("cc=")
        expect(result).not_to include("bcc=")
      end
    end
  end

  describe ".mailto_escape" do
    it "is private" do
      expect(described_class.private_methods).to include(:mailto_escape)
    end

    context "accessing via send" do
      it "properly escapes strings" do
        result = described_class.send(:mailto_escape, "Hello World")
        expect(result).to eq("Hello%20World")
      end

      it "converts plus signs to %20" do
        result = described_class.send(:mailto_escape, "test+tag@example.com")
        expect(result).to eq("test%2Btag%40example.com")
      end

      it "handles newlines" do
        result = described_class.send(:mailto_escape, "Line 1\nLine 2")
        expect(result).to eq("Line%201%0ALine%202")
      end

      it "handles ampersands" do
        result = described_class.send(:mailto_escape, "Hello & Goodbye")
        expect(result).to eq("Hello%20%26%20Goodbye")
      end

      it "converts non-string objects to strings" do
        result = described_class.send(:mailto_escape, 123)
        expect(result).to eq("123")
      end

      it "handles special email characters" do
        result = described_class.send(:mailto_escape, "user+tag@example.com")
        expect(result).to eq("user%2Btag%40example.com")
      end

      it "handles carriage returns and line feeds" do
        result = described_class.send(:mailto_escape, "Line 1\r\nLine 2")
        expect(result).to eq("Line%201%0D%0ALine%202")
      end

      it "handles unicode characters" do
        result = described_class.send(:mailto_escape, "Héllo 🎉")
        expect(result).to include("H%C3%A9llo")
      end

      it "handles percent signs" do
        result = described_class.send(:mailto_escape, "50% off")
        expect(result).to eq("50%25%20off")
      end

      it "handles empty strings" do
        result = described_class.send(:mailto_escape, "")
        expect(result).to eq("")
      end
    end
  end
end

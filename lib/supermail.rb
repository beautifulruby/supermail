# frozen_string_literal: true

require_relative "supermail/version"
require "action_mailer"
require "erb"

module Supermail
  class Error < StandardError; end

  module Rails
    class Base
      delegate \
          :deliver,
          :deliver_now,
          :deliver_later,
        to: :message

      def message
        @message ||= action_mailer_base_mail
      end

      def to = nil
      def from = nil
      def subject = nil
      def cc = []
      def bcc = []
      def body = ""
      def html_body = nil

      # Generate a mailto: URL with appropriate escaping.
      def mailto = MailTo.href(to:, from:, cc:, bcc:, subject:, body:)
      alias :mail_to :mailto

      private def action_mailer_base_mail
        if html_body && !html_body.empty?
          # Multipart email with both text and HTML
          # Capture values to avoid context issues in blocks
          email_to = to
          email_from = from
          email_cc = cc
          email_bcc = bcc
          email_subject = subject
          text_body = body
          html_content = html_body

          Mail.new do
            to email_to
            from email_from
            cc email_cc if email_cc && !email_cc.empty?
            bcc email_bcc if email_bcc && !email_bcc.empty?
            subject email_subject

            text_part do
              body text_body
            end

            html_part do
              content_type 'text/html; charset=UTF-8'
              body html_content
            end
          end
        else
          # Plain text only
          # ActionMailer::Base.mail returns a MessageDelivery, extract the message
          ActionMailer::Base.mail(to:, from:, cc:, bcc:, subject:, body:).message
        end
      end
    end
  end

  module MailTo
    extend self

    def href(to:, **params)
      q = query(**params)
      q.empty? ? "mailto:#{to}" : "mailto:#{to}?#{q}"
    end

    def query(**params)
      params
        .compact                          # drop nils
        .reject { |k, v| v.is_a?(Array) && v.empty? }  # drop empty arrays
        .map { |k, v| "#{k}=#{mailto_escape(v)}" }
        .join("&")
    end

    private

    def mailto_escape(str)
      ERB::Util.url_encode(str.to_s).tr("+", "%20")
    end
  end
end

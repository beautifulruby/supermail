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
          :message,
        to: :action_mailer_base_mail

      def to = nil
      def from = nil
      def subject = nil
      def cc = []
      def bcc = []
      def body = ""

      # Generate a mailto: URL with appropriate escaping.
      def mailto = MailTo.href(to:, from:, cc:, bcc:, subject:, body:)
      alias :mail_to :mailto

      private def action_mailer_base_mail
        ActionMailer::Base.mail(to:, from:, cc:, bcc:, subject:, body:)
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

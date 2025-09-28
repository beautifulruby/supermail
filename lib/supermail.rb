# frozen_string_literal: true

require_relative "supermail/version"
require "action_mailer"

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
      def body = ""

      private def action_mailer_base_mail
        ActionMailer::Base.mail(to:, from:, subject:, body:)
      end
    end
  end
end

# frozen_string_literal: true

require_relative "supermail/version"
require "action_mailer"

module Supermail
  class Error < StandardError; end

  module Rails
    class Base
      delegate :deliver, :deliver_now, :deliver_later, to: :message

      def to = nil
      def from = nil
      def subject = nil
      def body = ""

      def message
        ActionMailer::Base.mail(to:, from:, subject:, body:)
      end
    end
  end
end

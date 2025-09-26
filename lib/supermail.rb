# frozen_string_literal: true

require_relative "supermail/version"
require 'action_mailer'

module Supermail
  class Error < StandardError; end

  module Rails
    class Base
      delegate :deliver, :deliver_now, :deliver_later, to: :message_delivery

      def to = nil
      def from = nil
      def subject = nil
      def body = ""

      def message
        message_delivery.message
      end

      def message_delivery
        ActionMailer::Base.mail(to:, from:, subject:, body:)
      end
    end
  end
end

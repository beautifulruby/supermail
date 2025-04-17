# frozen_string_literal: true

require_relative "supermail/version"

require 'mail'
require "supermail/version"

module Supermail
  class Error < StandardError; end

  # A simple Email builder that wraps Mail::Message
  class Email
    # Hook to ensure default initialization runs before any subclass initialize
    module Defaults
      def initialize(*args, &block)
        # default fields
        @cc = []
        @bcc = []
        @headers = {}
        @attachments = []
        super
      end
    end

    # Whenever subclassing, prepend Defaults to ensure it wraps initialize
    def self.inherited(subclass)
      subclass.prepend Defaults
      super
    end

    attr_accessor :from, :to, :cc, :bcc, :subject,
                  :reply_to, :return_path, :date, :message_id,
                  :in_reply_to, :references, :headers,
                  :text_body, :html_body, :attachments

    # Builds a Mail::Message from this Email's attributes
    # @return [Mail::Message]
    def message
      mail = Mail.new
      mail.from        = Array(from) if from
      mail.to          = Array(to)
      mail.cc          = cc if cc.any?
      mail.bcc         = bcc if bcc.any?
      mail.reply_to    = Array(reply_to) if reply_to
      mail.return_path = return_path if return_path
      mail.date        = date if date
      mail.message_id  = message_id if message_id
      mail.in_reply_to = in_reply_to if in_reply_to
      mail.references  = references if references

      # Custom headers
      headers.each { |key, value| mail.header[key] = value }

      mail.subject = subject if subject

      # Bodies
      if text_body
        mail.text_part = Mail::Part.new do
          body text_body
        end
      end

      if html_body
        mail.html_part = Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body html_body
        end
      end

      # Attachments (each as a hash: { filename:, content: })
      attachments.each do |att|
        mail.add_file filename: att[:filename], content: att[:content]
      end

      mail
    end

    # Delivers the built Mail::Message via its configured delivery_method
    # @return [Mail::Message]
    def deliver
      raise Error, "`to` address is required" unless to
      message.deliver!
    end
  end
end

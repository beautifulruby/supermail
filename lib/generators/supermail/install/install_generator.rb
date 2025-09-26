# frozen_string_literal: true

require 'rails/generators/base'

module Supermail
  class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Install Supermail in a Rails application"

      def create_application_email
        template 'application_email.rb', 'app/emails/application_email.rb'
      end

      def create_emails_directory
        empty_directory 'app/emails'
      end
  end
end

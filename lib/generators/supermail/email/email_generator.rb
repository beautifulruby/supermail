# frozen_string_literal: true

require 'rails/generators/named_base'

module Supermail
  class EmailGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    desc "Generate a new email class"

    def create_email_file
      template 'email.rb', "app/emails/#{file_path}_email.rb"
    end

    private

    def file_path
      name.underscore
    end

    def class_name
      name.camelize
    end
  end
end
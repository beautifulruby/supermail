# frozen_string_literal: true

require 'rails/generators/named_base'

module Supermail
  class EmailGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    desc "Generate a new email class"

    def create_email_file
      template 'email.rb', "app/emails/#{file_path}.rb"
    end

    private

    def file_path
      "#{base_name.underscore}_email"
    end

    def class_name
      "#{base_name.camelize}Email"
    end

    def base_name
      stripped = name.to_s.sub(/_?email\z/i, '')
      stripped.empty? ? name : stripped
    end
  end
end

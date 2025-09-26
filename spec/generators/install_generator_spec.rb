# frozen_string_literal: true

require "spec_helper"
require "generators/supermail/install/install_generator"

RSpec.describe Supermail::InstallGenerator, type: :generator do
  tests Supermail::InstallGenerator

  INSTALL_DESTINATION_PATH = Pathname.new(__dir__).join("../tmp/generators")
  destination INSTALL_DESTINATION_PATH.to_s

  before { prepare_destination }
  after { FileUtils.rm_rf(INSTALL_DESTINATION_PATH) }

  describe "after running generator" do
    before { run_generator }

    describe "app/emails/application_email.rb" do
      subject { File.read(INSTALL_DESTINATION_PATH.join("app/emails/application_email.rb")) }
      it { is_expected.to match(/class ApplicationEmail < Supermail::Rails::Base/) }
      it { is_expected.to match(/def from = "website@example.com"/) }
      it { is_expected.to match(/The Example.com Team/) }
    end

    describe "app/emails directory" do
      subject { File.directory?(INSTALL_DESTINATION_PATH.join("app/emails")) }
      it { is_expected.to be true }
    end
  end
end

# frozen_string_literal: true

require_relative "lib/supermail/version"

Gem::Specification.new do |spec|
  spec.name = "supermail"
  spec.version = Supermail::VERSION
  spec.authors = ["Brad Gessler"]
  spec.email = ["bradgessler@gmail.com"]

  spec.summary = "Build emails with plain ol' Ruby objects."
  spec.description = spec.summary
  spec.homepage = "https://github.com/rubymonolith/supermail"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "mail", "~> 2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

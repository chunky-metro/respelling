# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "spec"
  t.test_files = FileList["spec/**/*_spec.rb"]
  t.warning = false
end

task default: :test

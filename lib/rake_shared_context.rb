# -*- coding: utf-8 -*-
require "rake_shared_context/version"
require "rake"
require "pathname"

class RakeSharedContext
  class << self
    def root_dir
      return @root_dir if @root_dir

      if defined? Rails
        Rails.root
      elsif defined? Padrino
        Pathname.new(Padrino.root)
      else
        Pathname.pwd
      end
    end

    def root_dir=(dir)
      @root_dir = Pathname.new(dir)
    end

    def rake_dir
      return @rake_dir if @rake_dir

      root_dir.join('lib', 'tasks')
    end

    def rake_dir=(dir)
      @rake_dir = Pathname.new(dir)
    end
  end
end

begin
  require 'rspec/core'
  RSpec.configure do |config|
    config.before(:suite) do
      Rake.application = Rake::Application.new
      loaded_files = []
      rake_dir = RakeSharedContext.rake_dir
      rake_files = File.join(rake_dir, '**', '*.rake')

      Dir.glob(rake_files).each do |task|
        filename_without_ext = File.basename(task.sub(/.rake$/, ''))
        Rake.application.rake_require(filename_without_ext, [File.dirname(task).to_s], loaded_files)
      end

      Rake::Task.define_task(:environment)
    end
  end

  RSpec.shared_context 'rake' do
    let(:task_name) { self.class.top_level_description }
    before { Rake.application.tasks.each(&:reenable) }
    subject { Rake.application[task_name] }
  end
rescue LoadError
end

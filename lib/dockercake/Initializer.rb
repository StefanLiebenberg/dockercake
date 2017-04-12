require 'yaml'
require 'rake/file_utils'

module DockerCake
  module Initializer
    extend FileUtils

    def self.get_volume_name(options)
      "dockercake_#{options['name']}"
    end

    def self.start(app_file)

      unless app_file
        puts 'No app_file specified'
        exit 1
      end

      app_content = File.read(app_file)
      app = YAML.safe_load(app_content)
      pull_image(app)
      create_volumes(app)
      run_image(app)
    end

    def self.create_volumes(app)
      # work in progress
      # name = get_volume_name(app)
      # sh "docker volume create #{name}" do |ok, _|
      #   raise "Failed to create volume #{name}" unless ok
      # end
    end

    def self.run_image(app)
      cmd = DockerCake::CmdBuilder.build_cmd(app)
      puts "Running #{cmd}"
      exec cmd
    end

    def self.pull_image(app)
      puts "loading image from #{app['image']}"
      sh "docker pull #{app['image']}" do |ok, _|
        raise "Failed to pull docker image #{app['image']}" unless ok
      end
    end
  end
end

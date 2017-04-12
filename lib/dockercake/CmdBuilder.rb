require 'rubygems'
require 'bundler/setup'
require_relative '../../lib/dockercake/Permissions'

Bundler.require(:default)
require 'rake'

module DockerCake
  module CmdBuilder

    def self.build_cmd(options = {})
      raise 'no image specified at options[\'image\']' unless options['image']

      docker_args = '--rm '
      docker_args += "--name #{options['name']} "
      docker_args += "--user #{get_user_id} "

      perms = Permissions.get_permissions(options)

      if perms.include? 'display'
        docker_args += '-v /tmp/.X11-unix:/tmp/.X11-unix '
        docker_args += '-e DISPLAY=unix$DISPLAY '
      end

      # does not work.
      # this needs a pulse audio server.
      if perms.include? 'sound'
        docker_args += '--device /dev/snd '
        docker_args += '-e PULSE_SERVER=pulseaudio '
      end

      # work in progress
      # if perms.include? 'storage'
      #   if options['persist']
      #     v_name = DockerCake::Initializer.get_volume_name(options)
      #     options['persist'].each do |item|
      #       docker_args += "-v #{v_name}:#{item} "
      #     end
      #   end
      # end

      "docker run -it #{docker_args} #{options['image']} #{options['command'] || ''}"
    end


    def self.get_user_id
      user_id = `id -u`.strip
      unless $?.success?
        raise 'Failed to retrieve current user id'
      end
      user_id
    end

  end

end

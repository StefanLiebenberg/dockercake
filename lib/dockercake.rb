require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'yaml'
require 'rake'

app_file = ARGV[0]

unless app_file
  puts 'No app_file specified'
  exit 1
end

app_content = File.read(app_file)
app = YAML.safe_load(app_content)
unless app['image']
  puts 'No image specified'
  exit 1
end

puts "loading image from #{app['image']}"
sh "docker pull #{app['image']}" do |ok, _|
  abort "Failed to pull docker image #{app['image']}" unless ok
end

user_id = `id -u`.strip
unless $?.success?
  puts 'Failed to retrieve current user id'
  exit 1
end

docker_args = '--rm '
docker_args += "--name #{app['name']} "
docker_args += "--user #{user_id} "

perms = app['permissions']['required'] + app['permissions']['optional']

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

docker_cmd = "docker run -it #{docker_args} #{app['image']} --help"
puts "Running #{docker_cmd}"
exec docker_cmd



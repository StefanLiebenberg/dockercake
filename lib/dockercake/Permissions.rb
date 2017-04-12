module DockerCake
  module Permissions
    def self.get_permissions(options)
      if options['permissions']
        options['permissions']['required'] + options['permissions']['optional']
      else
        []
      end
    end
  end
end

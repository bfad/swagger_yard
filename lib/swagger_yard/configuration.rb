module SwaggerYard
  class Configuration
    attr_accessor :api_version, :api_base_path
    attr_accessor :swagger_version
    attr_accessor :title, :description
    attr_accessor :enable, :reload
    attr_accessor :controller_path, :model_path
    attr_accessor :path_discovery_function
    attr_accessor :security_definitions

    def initialize
      self.swagger_version = "2.0"
      self.api_version = "0.1"
      self.enable = false
      self.reload = true
      self.title = "Configure title with SwaggerYard.config.title"
      self.description = "Configure description with SwaggerYard.config.description"
      self.security_definitions = {}
    end

    def swagger_spec_base_path=(ignored)
      warn "DEPRECATED: swagger_spec_base_path is no longer necessary."
    end

    def api_path=(ignored)
      warn "DEPRECATED: api_path is no longer necessary."
    end
  end
end

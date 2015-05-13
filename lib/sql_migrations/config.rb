module SqlMigrations
  # Configuration class
  #
  class Config
    class << self
      attr_reader :env

      def load!(config_file, env = nil)
        @env = (env || ENV['ENV'] || ENV['RAKE_ENV'] || :development).to_sym
        config = get_config_for_env_from_file(config_file)
        @databases = config[:databases]
        @options   = config[:options]
        { databases: @databases, options: @options }
      end

      def databases
        if @databases.nil? || @databases.empty?
          raise 'No configuration done !' if @databases.nil?
        end
        @databases
      end

      private

      def get_config_for_env_from_file(file)
        yaml_hash = YAML.load(ERB.new(File.new(file).read).result)
        config = symbolize_keys(yaml_hash)[@env]
        raise LoadError, "No configuration for `#{@env}` environment found !" unless config
        config
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), new_hash|
          new_key = key.is_a?(String) ? key.to_sym : key
          new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
          new_hash[new_key] = new_value
        end
      end
    end
  end
end

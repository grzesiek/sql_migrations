module SqlMigrations
  class Config
    class << self
      attr_reader :options

      def load!(config_file)
        yaml_hash = YAML.load(ERB.new(File.new(config_file).read).result)
        @options = symbolize_keys(yaml_hash)
      end
    end

    def initialize
      @env = (ENV['ENV'] ||= "development").to_sym
      @options = self.class.options
      @databases = get_databases_from_config
    end

    def databases
      @databases.map do |db|
        db_options = @options[db][@env.to_sym]
        unless db_options
          raise "Configuration for #{db} in environment #{@env} not found !"
        end
        db_options.merge!(name: db)
      end
    end

    private
    def get_databases_from_config
      @options.map { |k, v| k.to_sym }
    end

    def self.symbolize_keys(hash)
      hash.inject({}) do |acc, (key, value)|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
        acc[new_key] = new_value
        acc
      end
    end
  end
end

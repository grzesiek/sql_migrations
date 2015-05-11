module SqlMigrations
  class Config
    class << self
      attr_reader :options

      def load!(config_file)
        @options = YAML.load(ERB.new(File.new(config_file).read).result)
      end
    end

    def initialize
      @env = (ENV['ENV'] ||= "development").to_sym
      @options = self.class.options
      @databases = get_databases_from_config
    end

    def databases
      @databases.map do |db|
        db_options = @options[db.to_s][@env.to_s]
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
  end
end

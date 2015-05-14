module SqlMigrations
  # SqlScript class
  #
  class SqlScript
    attr_reader :date, :time, :name

    def initialize(content, opts)
      @content  = content
      @date     = opts[:date]
      @time     = opts[:time]
      @name     = opts[:name]
      @db_name  = opts[:db_name]
      @type     = self.class.name.downcase.split('::').last
      @datetime = (@date + @time).to_i
    end

    def execute(db)
      @database = db
      return false unless new?
      begin
        @database.driver.transaction do
          @benchmark = Benchmark.measure do
            @database.driver.run @content
          end
        end
      rescue
        puts "[-] Error while executing #{@type} #{@name} !"
        raise
      else
        true & on_success
      end
    end

    def self.find(db_name, type)
      files = FindScripts.find(db_name, type)
      scripts = files.map do |parameters|
        path = parameters.delete(:path)
        content = File.read(path)
        new(content, parameters)
      end

      scripts.sort_by { |file| (file.date + file.time).to_i }
    end

    private

    def new?
      schema = @database.schema_dataset
      last = schema.order(Sequel.asc(:time)).where(type: @type).last
      is_new = schema.where(time: @datetime, type: @type).count == 0
      if is_new && !last.nil?
        if last[:time] > @datetime
          raise "#{@type.capitalize} #{@name} has time BEFORE last one recorded !"
        end
      end
      is_new
    end

    def on_success
      puts "[+] Successfully executed #{@type}, name: #{@name}"
      puts "    Benchmark: #{@benchmark}"
      schema = @database.schema_dataset
      schema.insert(time: @datetime, name: @name, type: @type, executed: DateTime.now)
    end
  end
end

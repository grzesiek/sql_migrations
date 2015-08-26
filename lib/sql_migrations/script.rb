require 'forwardable'

module SqlMigrations
  # SqlScript class
  #
  class Script
    extend Forwardable
    delegate [:name, :date, :time, :datetime,
              :type, :content, :path] => :@file

    def initialize(file)
      @file = file
    end

    def execute(db)
      @database = db
      return false unless new?
      driver = @database.driver
      begin
        driver.transaction do
          @benchmark = Benchmark.measure do
            statements.each { |query| driver.run(query) }
          end
        end
      rescue
        puts "[-] Error while executing #{@type} #{@name} !"
        raise
      else
        true & on_success
      end
    end

    def statements
      separator = Config.options[:separator]
      if separator
        statements = content.split(separator)
        statements.collect!(&:strip)
        statements.reject(&:empty?)
      else
        [content]
      end
    end

    def self.find(database_name, type)
      files = []

      Find.find(Dir.pwd) do |path|
        file = File.new(path, database_name, type)

        raise "Duplicate time for #{type}s: #{files.find { |f| f = file }}, #{file}" if
          file.valid? && files.include?(file)

        files << file if file.valid?
      end

      files.sort_by(&:datetime)
      files.map { |file| new(file) }
    end

    def new?
      schema = @database.schema_dataset
      last = schema.order(Sequel.asc(:time)).where(type: @file.type).last
      is_new = schema.where(time: @file.datetime, type: @file.type).count == 0
      if is_new && !last.nil?
        if last[:time] > @file.datetime
          raise "#{@file.type.capitalize} #{@file.name} has time BEFORE last one recorded !"
        end
      end
      is_new
    end

    def on_success
      puts "[+] Successfully executed #{@file.type}, name: #{@file.name}"
      puts "    #{@file.type.capitalize} file: #{@file.date}_#{@file.time}_#{@file.name}.sql"
      puts "    Benchmark: #{@benchmark}"
      schema = @database.schema_dataset
      schema.insert(time: @file.datetime, name: @file.name,
                    type: @file.type, executed: DateTime.now)
    end
  end
end

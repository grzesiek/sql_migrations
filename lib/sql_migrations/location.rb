module SqlMigrations
  # Class that represents script file
  #
  class File
    attr_reader :name, :time, :date, :database, :path

    def initialize(path, database, type)
      @path     = path
      @database = database
      @type     = type.to_s

      @file, @base, @parent = elements(path)
      @date, @time, @name = match(@filename) if @filename
    end

    def valid?
      (@name && @time && @date &&
        @database && matches_directories?) ? true : false
    end

    def datetime
      (@date.to_s + @time.to_s).to_i
    end

    private

    def elements(path)
      _filename, _base_directory, _parent_directory =
        path.split(::File::SEPARATOR).last(3).reverse
    end

    def match(filename)
      _, date, time, name =
        filename.match(/^(\d{8})_(\d{6})_(.*)?\.sql$/).to_a
      [date, time, name]
    end

    def matches_directories?
      if @database == :default
        file_in_type_base_directory? || file_in_database_directory?
      else
        file_in_database_directory?
      end
    end

    def file_in_type_base_directory?
      @base == "#{@type}s"
    end

    def file_in_type_parent_directory?
      @parent == "#{@type}s"
    end

    def file_in_database_directory?
      file_in_type_parent_directory? &&
        (@base == @database.to_s)
    end
  end
end

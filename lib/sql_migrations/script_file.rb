module SqlMigrations
  # Class representing script file
  #
  class ScriptFile
    attr_reader :name, :time, :date, :database_name, :path

    def initialize(path, database_name, type)
      @filename,
      @base_directory,
      @parent_directory   = path_elements(path)
      @path               = path
      @type               = type.to_s
      @database_name      = database_name
      @date, @time, @name = match_regexp(@filename) if @filename
    end

    def content
      File.read(@path)
    end

    def valid?
      (@name && @time && @date && @database_name && matches_directories?) ? true : false
    end

    private

    def path_elements(path)
      _filename, _base_directory, _parent_directory =
        path.split(File::SEPARATOR).last(3).reverse
    end

    def match_regexp(filename)
      _, date, time, name =
        filename.match(/(\d{8})_(\d{6})_(.*)?\.sql/).to_a
      [date, time, name]
    end

    def matches_directories?
      if @database_name == :default
        file_in_type_base_directory? || file_in_database_directory?
      else
        file_in_database_directory?
      end
    end

    def file_in_type_base_directory?
      @base_directory == "#{@type}s"
    end

    def file_in_type_parent_directory?
      @parent_directory == "#{@type}s"
    end

    def file_in_database_directory?
      file_in_type_parent_directory? &&
        (@base_directory == @database_name.to_s)
    end
  end
end

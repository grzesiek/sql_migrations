describe 'no loadable configuration file' do
  it 'should raise error when config is not loaded' do
    expect { SqlMigrations.list_files }.to raise_error RuntimeError
  end
end

describe 'loadable configuration file' do
  before do
    File.open('databases.yml', 'w') do |f|
      f.puts 'development:'
      f.puts '  databases:'
      f.puts '    default:'
      f.puts '      adapter: sqlite3'
      f.puts '      database: <%= ENV["DB_NAME"] %>'
      f.puts '  options:'
      f.puts '    separator: ;'
    end
    ENV['DB_NAME'] = 'test_database'
    SqlMigrations::Config.load! 'databases.yml'
  end

  it 'should use environment variables in config' do
    databases = SqlMigrations::Config.databases
    expect(databases[:default][:database]).to eq 'test_database'
  end

  it 'should parse database correctly' do
    databases = SqlMigrations::Config.databases[:default]
    expect(databases).to eq(adapter: 'sqlite3', database: 'test_database')
  end

  it 'should parse options correctly' do
    options = SqlMigrations::Config.options
    expect(options[:separator]).to eq ';'
  end

  after do
    ENV.delete('DB_NAME')
  end
end

# DEPRECATED: use tracco executables instead
desc "Open an irb session preloaded with this library, e.g. rake 'console[production]' will open a irb session with the production db env"
task :console, [:tracco_env] do |t, args|
  args.with_defaults(tracco_env: "development")
  sh "tracco c --environment #{args.tracco_env}"
end

# DEPRECATED: use tracco executables instead
task :c, [:tracco_env] do |t, args|
  args.with_defaults(tracco_env: "development")
  sh "tracco c --environment #{args.tracco_env}"
end

# DEPRECATED: use tracco executables instead
namespace :run do
  desc "Run on the cards tracked starting from a given day, e.g. rake 'run:from_day[2012-11-1]'"
  task :from_day, [:starting_date, :tracco_env] do |t, args|
    args.with_defaults(starting_date: Date.today.to_s, tracco_env: "development")
    sh "tracco t #{args.starting_date} --environment #{args.tracco_env}"
  end

  desc "Run on the cards tracked today, #{Date.today}"
  task :today, [:tracco_env] do |t, args|
    args.with_defaults(tracco_env: "development")
    sh "tracco t #{Date.today.to_s} --environment #{args.tracco_env}"
  end
end

# DEPRECATED: use tracco executables instead
namespace :export do
  desc "Export all cards to a google docs spreadsheet, e.g. rake \"export:google_docs[my_sheet,tracking,production]\""
  task :google_docs, [:spreadsheet, :worksheet, :tracco_env] do |t, args|
    args.with_defaults(tracco_env: "development")
    sh "tracco egd #{args.spreadsheet} #{args.worksheet} --environment #{args.tracco_env}"
  end
end

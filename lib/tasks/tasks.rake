# DEPRECATED: use tracco executables instead
desc "Open an irb session preloaded with this library, e.g. rake 'console[production]' will open a irb session with the production db env"
task :console, [:tracco_env] do |t, args|
  args.with_defaults(tracco_env: "development")
  sh "tracco console --environment #{args.tracco_env}"
end

# DEPRECATED: use tracco executables instead
task :c, [:tracco_env] do |t, args|
  args.with_defaults(tracco_env: "development")
  sh "tracco c --environment #{args.tracco_env}"
end

desc "Copy template config files"
task :prepare do
  Dir.glob("config/*.template.yml").each do |file|
    template_file = File.basename(file)
    target_file = template_file.sub('.template', '')
    if File.exists?(File.join('config', target_file))
      puts "skipping #{target_file.color(:yellow)}, already exists."
    else
      cp File.join('config', template_file), File.join('config', target_file)
      puts "please edit the #{target_file} to have all the proper configurations"
    end
  end
end

# DEPRECATED: use tracco executables instead
namespace :run do
  desc "Run on the cards tracked starting from a given day, e.g. rake 'run:from_day[2012-11-1]'"
  task :from_day, [:starting_date, :tracco_env] do |t, args|
    args.with_defaults(starting_date: Date.today.to_s, tracco_env: "development")
    sh "tracco collect #{args.starting_date} --environment #{args.tracco_env}"
  end

  desc "Run on the cards tracked today, #{Date.today}"
  task :today, [:tracco_env] do |t, args|
    args.with_defaults(tracco_env: "development")
    sh "tracco collect #{Date.today.to_s} --environment #{args.tracco_env}"
  end
end

# DEPRECATED: use tracco executables instead
namespace :export do
  desc "Export all cards to a google docs spreadsheet, e.g. rake \"export:google_docs[my_sheet,tracking,production]\""
  task :google_docs, [:spreadsheet, :worksheet, :tracco_env] do |t, args|
    args.with_defaults(tracco_env: "development")
    sh "tracco export_google_docs #{args.spreadsheet} #{args.worksheet} --environment #{args.tracco_env}"
  end
end

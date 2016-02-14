#!/usr/bin/env ruby
require 'optparse'      # Parses command line options
require 'yaml'          # Parses configuration files
require 'date'

# Default setting, can be overridden with the -v command line parameter
DEBUG = false
DATE_FORMAT = "%Y-%m-%d"

# Collect the list of repositories
repositories = YAML.load_file("repositories.yaml")[:repositories]

# Parse the command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: commitHop.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
    DEBUG = true
  end

  opts.on("-d", "--date_override #{DATE_FORMAT}", "Override the current date, defaults to current system date.") do |d|
    options[:cur_date] = DateTime.now
    if d 
        if DEBUG
            puts "date override provided: #{d}"
        end
        options[:cur_date] = DateTime.strptime("#{d}", DATE_FORMAT)
    end
  end

end.parse!

if DEBUG
    p options
end

output = []
cur_date = options[:cur_date] || DateTime.now

repositories.each do |repo_name, repo_info|
    # Find the date of the first commit for this repo
    if File.exists? File.expand_path(repo_info['local_path'])
        first_commit = %x(cd #{repo_info['local_path']} && git log --pretty=%cd --reverse | head -1)
        if first_commit.empty?
            puts "ERROR: Can't find commits for repo #{repo_name}. Have you made any yet?"
            next
        end
    else
        puts "ERROR: Can't find git repo at #{repo_info['local_path']}"
        next
    end

    first_commit_date = DateTime.parse(first_commit).strftime(DATE_FORMAT)
    if DEBUG
        puts "first commit date for #{repo_name}: #{first_commit_date}"
    end

    while cur_date.strftime(DATE_FORMAT) >= first_commit_date
        cur_date = Time.new(cur_date.strftime("%Y").to_i-1, cur_date.strftime("%m"), cur_date.strftime("%d"))

        start_date = cur_date - 86400

        # Set the git log options that we care about to assert a certain format and author 
        log_options = []
        log_options << "--pretty=\"%cd\t%H\t[%h]\t%s\""
        log_options << "--since=\"#{start_date.strftime(DATE_FORMAT)}\""
        log_options << "--before=\"#{cur_date.strftime(DATE_FORMAT)}\""
        log_options << "--no-merges"
        log_options << "--date=short"

        git_options = log_options.join(" ")

        # Switch to the proper local directory and do a fetch to make sure the git log is up to date
        git_fetch = %x(cd #{repo_info['local_path']} && git fetch --all > /dev/null)
        cmd_output = %x(cd #{repo_info['local_path']} && git log #{git_options})

        commits = cmd_output.split( /\r?\n/ )
        if commits.length > 0
            output << "#{repo_name} #{commits.length} commits from #{cur_date.strftime(DATE_FORMAT)} ago..."
            commits.each do | commit |
                commit_info = commit.split("\t") 
                output << "  #{commit_info[0]} - #{commit_info[3]} #{commit_info[2]}\n"
            end

            output << "\n"
        else
            output << "No commits on #{cur_date.strftime(DATE_FORMAT)}"
        end
    end
end

puts output
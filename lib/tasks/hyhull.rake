# require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')
require 'jettywrapper'
require 'win32/process' if RUBY_PLATFORM =~ /mswin32|mingw|cygwin/
require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'


namespace :hyhull do
  
  namespace :config do
    desc "Copies the libraries necessary for text extraction with solr"
    task :solr_text_extraction do
      cp_r("solr_conf/text_extraction_support/contrib/extraction", "jetty/solr/lib/contrib/", verbose: true)
    end

    desc "Copies the libraries and war necessary for xslt processing within Fedora"
    task :saxon_xslt_engine do
      cp("fedora_conf/saxon_xslt_engine/contexts/saxon.xml", "jetty/contexts/", verbose: true)
      cp("fedora_conf/saxon_xslt_engine/webapps/saxon.war", "jetty/webapps/", verbose: true)
    end
  end

  namespace :default_fixtures do


    desc "Load default hull fixtures via hydra"
    task :load => [:load_dependencies, :ingest] do     
    end

    desc "Load the default fixtures via fedora's ingest"
    task :ingest => :environment do
        puts "opening files"
        fixture_files.each_with_index do |fixture,index|
          pid = pid_from_path(fixture)
          body = ''
          begin
            ActiveFedora::FixtureLoader.import_to_fedora(fixture)
            ActiveFedora::FixtureLoader.index(pid)
          rescue
            #typically an "object exists" error
          end
          puts " Ingested #{pid}"
        end
    end

    desc "Load the dependencies (sDeps,sDefs,etc.)"
    task :load_dependencies => :environment do
        puts "loading dependencies"
        dependencies.each do |dependency|
          pid = pid_from_path(dependency)
          puts "Loading #{dependency}..."
          begin
            ActiveFedora::FixtureLoader.import_to_fedora(dependency)
            ActiveFedora::FixtureLoader.index(pid)
          rescue
            #typically an "object exists" error
          end
          puts "Loaded #{pid}"
        end
    end

    desc "Remove the dependencies (sDeps,sDefs,etc.)"
    task :delete_dependencies do
      dependencies.each_with_index do |dependency,index|
        pid = pid_from_path(dependency)
        puts "removing #{dependency}"
        begin
          ActiveFedora::FixtureLoader.delete(pid)
        rescue
          #typically an "object exists" error
        end
      end
    end

    desc "Remove default hull fixtures"
    task :delete do
      fixture_files.each_with_index do |fixture,index|
        pid = pid_from_path(fixture)
        puts "deleting #{fixture}"
        begin
          ActiveFedora::FixtureLoader.delete(pid)
        rescue
          #typically an "object exists" error
        end
      end
    end

    desc "Refresh default hull fixtures"
    task :refresh do
      Rake::Task["hyhull:default_fixtures:delete"].invoke
      Rake::Task["hyhull:default_fixtures:load"].invoke
    end
  end

  desc "Test Jenkins CI build"
  task :test do
    ENV["RAILS_ENV"] ||= 'test'
    workspace_dir = ENV['WORKSPACE'] # workspace should be set by Hudson
    project_dir = workspace_dir ? workspace_dir : ENV['PWD']   
    Rake::Task["hydra:jetty:config"].invoke
    jetty_params = {
      :jetty_home => "#{project_dir}/jetty",
      :quiet => false,
      :jetty_port => 8983,
      :solr_home => "#{project_dir}/jetty/solr",
      :fedora_home => "#{project_dir}/jetty/fedora/default",
      :startup_wait => 50
    }
    # Copy across the Solr Text Extraction libraries
    Rake::Task["hyhull:config:solr_text_extraction"].invoke
    # Copy across the saxon_xslt_engine libraries
    Rake::Task["hyhull:config:saxon_xslt_engine"].invoke

    jetty_params = Jettywrapper.load_config.merge(jetty_params)

    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke      
    
    error = Jettywrapper.wrap(jetty_params) do
      puts "Refreshing fixtures in test fedora/solr"
      puts %x[rake hyhull:default_fixtures:refresh RAILS_ENV=test]  # must explicitly set RAILS_ENV to test
      
      Rake::Task["cucumber:ok"].invoke  # running cucumber first because rspec is exiting with an odd error after running with 0 failures
      Rake::Task["spec"].invoke
        
    end
    raise "test failures: #{error}" if error
  end

end

#Make hyhull:test the default rake task
task :default => ["hyhull:test"]

def fixture_files
  Dir.glob(File.join("#{Rails.root}","spec","fixtures", "hyhull", "objects", Rails.env, "*.xml")) +
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hyhull", "objects", "*.xml"))
end

def dependencies
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hyhull", "dependencies", Rails.env,"*.xml")) +
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hyhull","dependencies","*.xml"))
end

def pid_from_path(path)
  path.split("/")[-1].gsub(/(\.foxml)?\.xml/,"").split("~")[-1].sub("_",":")
end

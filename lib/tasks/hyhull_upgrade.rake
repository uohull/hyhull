namespace :hyhull_upgrade do
  
  namespace :process do

    # resource_state task will process all the resource_models and confirm that the resource_state element is set 
    # in the properties ds. 
    # specify model=ExamPaper to only process the resource state of exam papers   
    task :resource_state => :environment do

      puts "Processing resource state"
      puts "Target models to match against: #{ENV['model']}" if ENV['model']  

      all_objects = find_all_objects

      all_objects.each do |object|

        if object.pid.include? "hull:"

            active_fedora_obj = ActiveFedora::Base.find(object.pid, cast: true)

            puts ""
            puts "PID: #{active_fedora_obj.pid} Model: #{active_fedora_obj.class} "

            model = ENV['model'].constantize if ENV['model']
            models_to_include = model.nil? ? resource_models : [model]
           
            if models_to_include.include? active_fedora_obj.class
              puts "Processing: #{active_fedora_obj.pid}"
              
              if active_fedora_obj._resource_state.nil? && active_fedora_obj.resource_state == "proto"
                puts "Resource does not have DS#properties.resourceState set and is defaulting to proto"
                 
                if active_fedora_obj.apo.id == active_fedora_obj.parent_id
                  puts "Resource Parent set and APO match... It is a published resource"
                  puts "Setting resource to published"
                  active_fedora_obj.properties._resource_state = "published"
                  # We remove the defaulted proto queue and set it to nil. 
                  active_fedora_obj.queue = nil
                 
                  puts "Saving changes to properties ds and refreshing..."
                  if active_fedora_obj.properties.save
                    puts "Properties DS Changes saved"
                    # Refresh the resource state - this checks the DS#properties.resourceState field...
                    active_fedora_obj.get_resource_state 
                    puts "Resource is being reported as published" if active_fedora_obj.resource_published? 
                  else 
                    puts "Properties DS Changes did NOT save"
                  end
                end
              end

              puts "Saving the resource"
              if active_fedora_obj.save
                puts "#{active_fedora_obj.pid}: Saved"
              else
                puts "active_fedora_obj.pid}: Did NOT save"
                puts "#{active_fedora_obj.errors.messages}"
              end

            else 
              puts "Ignoring: #{active_fedora_obj.pid}"
            end

          end
      end
    end

    # file_assets task checks that all FileAssets use the correct RELS-EXT declaration.  
    # The correct declaration is info:fedora/afmodel:FileAsset 
    # The old incorrect declaration is info:fedora/afmodel:fileAsset
    task :file_assets => :environment do
      puts "Querying for Objects stored in Fedora that cast to FileAsset"
      objs = find_objects_by_model(FileAsset, "hull", nil)
      
      objs.each do |obj|
        puts ""
        puts "Processing FileAsset Resource with Object PID: #{obj.pid}"

        puts "Checking for the use of incorrect model declation of info:fedora/afmodel:fileAsset"
        if obj.relationships(:has_model).include? "info:fedora/afmodel:fileAsset"
          puts "#{obj.pid} contains the incorrect FileAsset hasModel statement."
          puts "Removing the incorrect relationship..."
          obj.remove_relationship(:has_model, "info:fedora/afmodel:fileAsset")
          puts "Adding the correct relationship..."
          obj.add_relationship(:has_model, "info:fedora/afmodel:FileAsset")

          if obj.save
            puts "FileAsset saved..."
          else
            puts "Save failed: #{obj.errors.messages}"
          end
        else 
          puts "#{obj.pid} FileAsset has the correct declaration"
        end

      end
    end

    # uketd_objects - processes the objects are makes sure that Creator is the correct case in the MODS ie. 'Creator'
    task :uketd_objects => :environment do
      puts "Querying for Objects stored in Fedora that cast to UketdObject"
      objs = find_objects_by_model(UketdObject, "hull", nil)

      objs.each do |obj|
        puts ""
        puts "Processing UketdObject Resource with Object PID: #{obj.pid}"
        puts "Checking and replacing incorrect 'creator' case in person role in mods"
        obj.person_role_text = obj.person_role_text.collect { |role| role =  role == "creator" ? "Creator" : role  } 

        if obj.changed?
           if obj.save
            puts "#{obj.pid} UketdObject saved..."
          else
            puts "Save failed: #{obj.errors.messages}"
          end
        else 
          puts "#{obj.pid} UketdObject hasn't changed. Not saving."
        end
      end

    end


    # exam_papers - processes the objects and removes an invalid extra titleInfo => title XML from relatedItem element in Mods
    task :exam_papers => :environment do
      puts "Querying for Objects stored in Fedora that cast to ExamPaper"
      puts "Checking for un-needed <titleInfo><title></title></titleInfo> within the <relatedItem ID='module'> block"

      objs = find_objects_by_model(ExamPaper, "hull", nil)

      objs.each do |obj|
        puts ""
        puts "Processing ExamPaper Resource with Object PID: #{obj.pid}"

        if obj.descMetadata.ng_xml.search("//xmlns:relatedItem[@ID='module']/xmlns:titleInfo").to_xml != ""
          puts "Erroneous titleInfo found. Removing..."
          obj.descMetadata.ng_xml.search("//xmlns:relatedItem[@ID='module']/xmlns:titleInfo").remove
          obj.descMetadata.ng_xml_will_change!

          if obj.save
            puts "#{obj.pid} ExamPaper saved..."
          else
            puts "Save failed: #{obj.errors.messages}"
          end

          puts "#{obj.pid}: Erroneous title removed" if obj.descMetadata.ng_xml.search("//xmlns:relatedItem[@ID='module']/xmlns:titleInfo").to_xml == ""
        end
      end

    end

  end

  # Index objects in Fedora by the model Classname 
  # This will index based on the class that Object casts to use ActiveFedora::Base method
  # To use e.g. rake hyhull_upgrade:index:by_model model=ExamPaper numeric_pids_only=true
  namespace :index do
    task :by_model => :environment do
      if ENV['model']
        puts "Querying for Objects stored in Fedora that cast to: #{ENV['model']}"
        model =  ENV['model'].constantize
        objs = find_objects_by_model(model, "hull", ENV['numeric_pids_only'])

        objs.each do |obj|
          puts "Processing Resource with Object PID: #{obj.pid}"
          puts "Attemping to save...#{obj.pid}"

          begin
            if obj.save!
              puts "Saved"
            else
              puts "Didn't save: #{obj.errors.messages}"
            end
          rescue Exception => error
            puts error.to_s            
          end
        end

      else
        puts "You must specify an ActiveFedora Model name to index from Fedora"
      end
    end
  end

end


# Returns all the Objects from Fedora that cast into the target model class
# If return_numeric_pids is set to true, it will also filter out non NS:1234 type pids. 
def find_objects_by_model(model, object_ns, return_numeric_pids=false)
  if model && object_ns
    objects = []

    all_objects = find_all_objects

    all_objects.each do |obj|
      af_object = ActiveFedora::Base.find(obj.pid, cast: true)

      if return_numeric_pids
        # We only match on the model and objects with a ns:numeric pattern
        objects << af_object if af_object.class == model && !af_object.pid[numeric_pid_regexp(object_ns)].nil?
      else
        objects << af_object if af_object.class == model
      end
    end

    # If we only return numeric pids, we will sort into numerical order
    if objects.size > 0 && return_numeric_pids
      return sort_by_pid(objects)
    else 
      objects 
    end

  else
    puts "Missing the model_name and object_ns parameter"
  end

end

# RegExp that will match namespace:1... and nil for other patterns 
def numeric_pid_regexp(namespace)
  Regexp.compile("#{Regexp.escape(namespace)}:[0-9]")
end


# Sorts an array of objects (which have 'pid' property)
# sorts the based on the numerical part of pid i.e hull:223 is before hull:1234
def sort_by_pid(obj_array)
  obj_array.sort { |x,y|  x.pid[x.pid.index(":")+1, x.pid.size].to_i <=> y.pid[y.pid.index(":")+1, y.pid.size].to_i }
end


# Finds all objects within Fedora
def find_all_objects
  connections.each do |conn|
    return conn.search(nil)
  end
end

def resource_models
  [UketdObject, ExamPaper, Dataset, GenericContent, JournalArticle]
end

def connections
  if ActiveFedora.config.sharded?
    return ActiveFedora.config.credentials.map { |cred| ActiveFedora::RubydoraConnection.new(cred).connection}
  else
    return [ActiveFedora::RubydoraConnection.new(ActiveFedora.config.credentials).connection]
  end
end
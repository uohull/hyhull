# encoding: UTF-8

namespace :hyhull_upgrade do
  
  namespace :process do

    # resource_state task will process all the resource_models and confirm that the resource_state element is set 
    # in the properties ds. 
    # specify model=ExamPaper to only process the resource state of exam papers   
    task :resource_state => :environment do

      puts "Processing resource state"
      puts "Target models to match against: #{ENV['model']}" if ENV['model'] 
      
      saved_objects = []
      unsaved_objects  = []
      objects_to_process = []

      all_objects = find_all_objects

      model = ENV['model'].constantize if ENV['model']
    
      if model
        objects_to_process = objects_by_model(model, all_objects)
      else
        objects_to_process = all_objects
      end

      puts "Processing #{objects_to_process.size.to_s} objects"  

      objects_to_process.each_with_index do |object, i|

        if object.pid.include? "hull:"

            active_fedora_obj = ActiveFedora::Base.find(object.pid, cast: true)

            #puts "PID: #{active_fedora_obj.pid} Model: #{active_fedora_obj.class} "

            models_to_include = model.nil? ? resource_models : [model]
           
            if models_to_include.include? active_fedora_obj.class
              puts ""
              puts "Processing: #{active_fedora_obj.pid} Model: #{active_fedora_obj.class} (#{i} of #{objects_to_process.size.to_s})"
              
              if active_fedora_obj._resource_state.nil? && active_fedora_obj.resource_state == "proto"
                puts "Resource does not have DS#properties.resourceState set and is defaulting to proto"
                 
                begin  
                  if active_fedora_obj.apo.pid == active_fedora_obj.parent_id
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
                      # Make sure that the parent is set... 
                      active_fedora_obj.parent = active_fedora_obj.apo if active_fedora_obj.resource_published? 
                    else 
                      puts "Properties DS Changes did NOT save"
                    end
                  else
                    puts "APO pid does not match the Parent pid"
                  end
                rescue Exception => e
                  puts "Problem with resource: #{e.to_s}"
                end

              end

              puts "Saving the resource"
              begin
                if active_fedora_obj.save
                  puts "#{active_fedora_obj.pid}: Saved"
                  saved_objects << active_fedora_obj.pid
                else
                  puts "active_fedora_obj.pid}: Did NOT save"
                  puts "#{active_fedora_obj.errors.messages}"
                  unsaved_objects << active_fedora_obj.pid
                end
              rescue Exception => e
                puts "Problem saving resource: #{e.to_s}"
              end

            else 
              #puts "Ignoring: #{active_fedora_obj.pid}"
            end

          end
      end

      puts "#{saved_objects.size.to_s} objects have been saved sucessfully"
      puts "#{unsaved_objects.size.to_s} objects did not save sucessfully"

      puts "Unsaved objects include:"
      p unsaved_objects
    end

    task :validate_objects => :environment do
      "Puts Validating objects"
      puts "Target models to match against: #{ENV['model']}" if ENV['model'] 
      model = ENV['model'].constantize if ENV['model']

      if model
        all_resources_models = eval("#{model}.all") 

        puts "Checking #{all_resources_models.size.to_s} objects"

        all_resources_models.each do |object|
          if !object.valid?
            puts ""
            puts "Object #{object.pid} is invalid"
            puts object.errors.messages
          end
        end

      end
    end 

    task :fix_missing_parent => :environment do

      model = ENV['model'].constantize if ENV['model']

      if model
        #puts "Target models to match against: #{ENV['model']}" if ENV['model']
        all_objs = eval "#{model}.find(:all)"

        fixed_objects = []

        puts "Checking #{all_etds.size.to_s} etds"

        all_objs.each do |obj|
          puts ""
          puts "Checking #{obj.pid}"
          if obj.resource_published? 
             puts "Resource is published"

             if obj.parent.nil?
               puts "Parent is nil.."
               
               unless obj.apo.nil?
                 puts "Apo isn't nil.. using that"
                 obj.parent = obj.apo

                 puts "Saving obj..."
                 obj.save

                 fixed_objects << obj.pid
               else
                  puts "Apo is nil too!"
               end

            else
              puts "Parent isn't nil"
            end
          end
        end
      end   

      p fixed_objects

    end

    # file_assets task checks that all FileAssets use the correct RELS-EXT declaration.  
    # The correct declaration is info:fedora/afmodel:FileAsset 
    # The old incorrect declaration is info:fedora/afmodel:fileAsset
    task :file_assets => :environment do

      puts "Querying for Objects stored in Fedora that cast to FileAsset"
      #objs = find_objects_by_model(FileAsset, "hull", nil)      

      puts "Calling find_all_objects."
      all_objects = find_all_objects

      puts "Calling objects_by_model"
      objs = objects_by_model(FileAsset, all_objects )
      
      #objs = FileAsset.all

      objs.each_with_index do |rubydora_obj,i|
        begin
          puts ""
          puts "Processing FileAsset with Object PID: #{rubydora_obj.pid} (#{i.to_s} of #{objs.size.to_s})"

          obj = ActiveFedora::Base.find(rubydora_obj.pid, cast: true)
      
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

        rescue Exception => e
          puts "There was an error: #{e.to_s}"
        end

      end
    end

    # uketd_objects - processes the objects are makes sure that Creator is the correct case in the MODS ie. 'Creator'
    task :uketd_objects => :environment do
      puts "Querying for Objects stored in Fedora that cast to UketdObject"
      #objs = find_objects_by_model(UketdObject, "hull", nil)
      objs = UketdObject.all

      objs.each_with_index do |obj, i|
        puts ""
        puts "Processing UketdObject Resource with Object PID: #{obj.pid} (#{i.to_s} of #{objs.size.to_s})"
        puts "Checking and replacing incorrect 'creator' case in person role in mods"
        obj.person_role_text = obj.person_role_text.collect { |role| role =  role == "creator" ? "Creator" : role  } 

        puts "Checking for, and replacing incorrect genre: Thesis or Dissertation"
        obj.genre = "Thesis or dissertation" if obj.genre == "Thesis or Dissertation"

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

      #objs = find_objects_by_model(ExamPaper, "hull", nil)
      objs = ExamPaper.all

      objs.each_with_index do |obj, i|
        puts ""
        puts "Processing ExamPaper Resource with Object PID: #{obj.pid}  (#{i.to_s} of #{objs.size.to_s})"

        if obj.descMetadata.ng_xml.search("//xmlns:relatedItem[@ID='module']/xmlns:titleInfo").to_xml != ""
          puts "Erroneous titleInfo found. Removing..."
          obj.descMetadata.ng_xml.search("//xmlns:relatedItem[@ID='module']/xmlns:titleInfo").remove
          obj.descMetadata.ng_xml_will_change!
        end

        if obj.descMetadata.organisation.role.text == ["creator"]
          puts "creator roleterm found. Replacing with Creator roleterm"
          obj.descMetadata.organisation.role.text = ["Creator"]
          obj.descMetadata.ng_xml_will_change!
        end

        if obj.descMetadata.changed?
          if obj.save
            puts "#{obj.pid} ExamPaper saved..."
          else
            puts "Save failed: #{obj.errors.messages}"
          end

          puts "#{obj.pid}: Erroneous title removed" if obj.descMetadata.ng_xml.search("//xmlns:relatedItem[@ID='module']/xmlns:titleInfo").to_xml == ""
        
        else
          puts "No processing needed."
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

        return_numeric_pids = true if ENV['numeric_pids_only'] == "true"

        puts "Calling find_all_objects.  Returning numeric pids: #{return_numeric_pids.to_s}"
        all_objects = find_all_objects

        puts "Calling objects_by_model"
        objs = objects_by_model(model, all_objects, return_numeric_pids )

        objs.each_with_index do |rubydora_obj, i|
          obj = ActiveFedora::Base.find(rubydora_obj.pid, cast: true)

          #puts "PID: #{active_fedora_obj.pid} Model: #{active_fedora_obj.class} "
          puts "Processing Resource with Object PID: #{obj.pid} (#{i.to_s} of #{objs.size.to_s})"
          if model == obj.class

  
            puts "Attemping to save...#{obj.pid}"
            begin
              if obj.save
                puts "Saved"
              else
                if obj.class == StructuralSet && obj.parent.nil?
                  # Trying fallback routine for a set...
                  index_set(obj.id)
                elsif obj.class == DisplaySet && obj.display_set.nil?
                  # Trying fallback routine for a set...
                  index_display_set(obj.id)
                else
                   puts "Didn't save: #{obj.errors.messages}"
                end
              end
            rescue Exception => error
              puts error.to_s            
            end
          else
            puts "Object didn't cast to the expected model.  It cast to: #{obj.class.to_s}"
          end
        end

      else
        puts "You must specify an ActiveFedora Model name to index from Fedora"
      end

    end

  end

end


def index_set(pid)
  puts ""
  puts "Attempting to index the set: #{pid}"
  obj = StructuralSet.find(pid)

  if obj.save
    puts "#{pid} - Set saved!"
  else
    puts "Save failed. Reason: #{obj.errors.messages}"
    puts "Checking for nil parent..."
    if obj.parent.nil?
      puts "Parent is nil"
      if obj.relationships(:is_member_of).size == 1

        rel = obj.relationships(:is_member_of).first
        parent_id = rel[rel.index("/")+1, rel.size]
        puts "Parent in RELS-EXT is: #{parent_id}"    
        if parent_id.size > 1 
          puts "indexing parent set: #{parent_id}"
          index_set(parent_id)
          
          # Lets try reloading and saving the original object
          obj = StructuralSet.find(pid)
          if obj.save
             puts "#{pid} has now saved..."
          else
             puts "#{pid} still won't save!"
          end
          #

        end
      else 
        puts "Incorrect number of is_member_of predicates for a StructuralSet: #{obj.id}"
      end
    end
  end
end


def index_display_set(pid)
  puts ""
  puts "Attempting to index the set: #{pid}"
  obj = DisplaySet.find(pid)

  if obj.save
    puts "#{pid} - Set saved!"
  else
    puts "Save failed. Reason: #{obj.errors.messages}"
    puts "Checking for nil display parent..."
    if obj.display_set.nil?
      puts "Display set parent is nil"
      if obj.relationships(:is_member_of).size == 1
        rel = obj.relationships(:is_member_of).first
        display_set_parent_id = rel[rel.index("/")+1, rel.size]
        puts "Parent in RELS-EXT is: #{display_set_parent_id}"    
        if display_set_parent_id.size > 1 
          puts "indexing display parent set: #{display_set_parent_id}"
          index_display_set(parent_id)
          
          # Lets try reloading and saving the original object
          obj = DisplaySet.find(pid)
          if obj.save
             puts "#{pid} has now saved..."
          else
             puts "#{pid} still won't save!"
          end
          #

        end
      else 
        puts "Incorrect number of is_member_of predicates for a DisplaySet: #{obj.id}"
      end
    end
  end
end


# Will process a rubydora_object array and return a list of objects based upon a model class 
# (uses a predicate to search)
def objects_by_model(model, rubydora_object_array, numeric_pids_only=false, object_ns="hull" )
  objects = []
  puts "Running object_model_code"
  if model
    rubydora_object_array.each do |object|
      # For GenericContent resources we have serveral predicates to match against
      if model == GenericContent
        model_predicates = ["info:fedora/hull-cModel:event","info:fedora/hull-cModel:artwork","info:fedora/hull-cModel:diagram","info:fedora/hull-cModel:drawing","info:fedora/hull-cModel:map","info:fedora/hull-cModel:photograph","info:fedora/hull-cModel:movingImage","info:fedora/hull-cModel:software","info:fedora/hull-cModel:sound","info:fedora/hydra-cModel:genericContent","info:fedora/hull-cModel:book","info:fedora/hull-cModel:bookChapter","info:fedora/hull-cModel:conferencePaper","info:fedora/hull-cModel:conferencePoster", "info:fedora/hull-cModel:examPaper","info:fedora/hull-cModel:guidance","info:fedora/hull-cModel:handbook","info:fedora/hull-cModel:internetPublication","info:fedora/hull-cModel:journalArticle","info:fedora/hull-cModel:learningMaterial","info:fedora/hull-cModel:letter","info:fedora/hull-cModel:license","info:fedora/hull-cModel:meetingPaper","info:fedora/hull-cModel:musicScore","info:fedora/hull-cModel:genericContent","info:fedora/hull-cModel:policy","info:fedora/hull-cModel:presentation","info:fedora/hull-cModel:regulation","info:fedora/hull-cModel:report"]
        
        model_predicates.each do |model_predicate|
          if object.profile_xml.include?(model_predicate)
            objects << object
            break
          end
        end
      elsif model == FileAsset
        model_predicates = ["info:fedora/afmodel:FileAsset","info:fedora/afmodel:fileAsset"]
        model_predicates.each do |model_predicate|
          if object.profile_xml.include?(model_predicate)
            objects << object
            break
          end
        end  
      # For other resource types...
      else
        model_predicate = "<model>info:fedora/hull-cModel:uketdObject</model>" if model == UketdObject
        model_predicate = "<model>info:fedora/hull-cModel:examPaper</model>" if model == ExamPaper
        model_predicate = "<model>info:fedora/hull-cModel:journalArticle</model>" if model == JournalArticle
        model_predicate = "<model>info:fedora/hull-cModel:dataset</model>" if model == Dataset
        model_predicate = "<model>info:fedora/hull-cModel:structuralSet</model>" if model == StructuralSet
        model_predicate = "<model>info:fedora/hull-cModel:displaySet</model>" if model == DisplaySet
        if numeric_pids_only
          objects << object if object.profile_xml.include?(model_predicate) && !object.pid[numeric_pid_regexp(object_ns)].nil?
        else
          objects << object if object.profile_xml.include?(model_predicate)
        end                   
      end
    end
  end

  # If we only return numeric pids, we will sort into numerical order
  if objects.size > 0 && numeric_pids_only
    puts "Calling sort_by_pid and returning..."
    return sort_by_pid(objects)
  else 
    objects 
  end

  puts "Matched #{objects.size.to_s} objects"
  return objects
end




# Returns all the Objects from Fedora that cast into the target model class
# If return_numeric_pids is set to true, it will also filter out non NS:1234 type pids. 
def find_objects_by_model(model, object_ns, return_numeric_pids=false)
  if model && object_ns
    objects = []

    puts "Calling find_all_objects.  Returning numeric pids: #{return_numeric_pids.to_s}"

    all_objects = find_all_objects

    puts "find_all_objects returned #{all_objects.size.to_s} objects"

    puts "Processing objects for correct model type..."
    puts ""
    all_objects.each_with_index do |obj, i|
      print "\rChecking #{i.to_s} of #{all_objects.size.to_s}  "
      af_object = ActiveFedora::Base.find(obj.pid, cast: true)

      if return_numeric_pids
        # We only match on the model and objects with a ns:numeric pattern
        objects << af_object if af_object.class == model && !af_object.pid[numeric_pid_regexp(object_ns)].nil?
      else
        objects << af_object if af_object.class == model
      end
    end

    puts "Finished processing objects, found #{objects.size.to_s} objects that match with the target model"

    # If we only return numeric pids, we will sort into numerical order
    if objects.size > 0 && return_numeric_pids
      puts "Calling sort_by_pid and returning..."
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
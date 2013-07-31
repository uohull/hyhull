module Hyhull::Controller::ControllerBehaviour
  extend ActiveSupport::Concern

  included do
     # Add the CanCan load_and_authorize_resource to Controllers including this...
     # See https://github.com/ryanb/cancan/wiki/Authorizing-Controller-Actions  
     load_and_authorize_resource
  end
 
  def changed_fields(params)
    changes = Hash.new
    return changes if params[:document_fields].nil?
    object = get_model_from_pid(params[:id])
    logger.info("\n\n\n\n\n" + params[:document_fields].inspect + "\n\n\n\n\n\n")
    params[:document_fields].each do |k,v|
      if params[:document_fields][k.to_sym].kind_of?(Array)
        unless object.send(k.to_sym) == v or (object.send(k.to_sym).empty? and v.first.empty?) or (v.sort.uniq.count > object.send(k.to_sym).count and v.sort.uniq.first.empty?)
          changes.store(k,v)
        end
      else
        unless object.send(k.to_sym) == v
          changes.store(k,v)
        end
      end
    end
    return changes
  end

  def get_model_from_pid(id)
    af = ActiveFedora::Base.load_instance_from_solr(id)
    af.relationships.data.each_statement do |s|
      if s.object.to_s.match("afmodel")
        model = s.object.to_s.gsub("info:fedora/afmodel:","")
        return eval(model).find(id)
      end
    end
  end

end

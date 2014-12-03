class BookChapter < Book
  
  # Extra validations for the resource_state state changes
  BookChapter.state_machine :resource_state do   
    state :hidden, :deleted do
      validates :resource_status, presence: true
    end

    state :qa, :published do
      validates :title, presence: true
    end
  end

  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsBookChapter

  has_attributes :related_item_title, :related_item_subtitle, :related_item_volume, :related_item_issue, :related_item_start_page,
                            :related_item_end_page, datastream: :descMetadata, multiple: false

  
  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hull-cModel:bookChapter")  
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")    
  end


  # to_solr overridden to add object_type facet field to document
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => "Book chapter")
    solr_doc
  end  

end
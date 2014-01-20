# PropertyHelper
module PropertyHelper
  # Provides a Select dropdown based upon the proptery_type_name 
  # sort_dropdown is an optional (defaults to true) - Will sort by name..
  def select_by_property_type(form, attribute, property_type_name, sort_dropdown=true)
    form.input attribute, collection: Property.select_by_property_type_name(property_type_name, sort_dropdown), value_method: "value"
  end
end

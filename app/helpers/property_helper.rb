# PropertyHelper
module PropertyHelper
  def select_by_property_type(form, attribute, property_type_name)
    form.input attribute, collection: Property.select_by_property_type_name(property_type_name), value_method: "value"
  end
end

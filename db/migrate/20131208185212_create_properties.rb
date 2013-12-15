class CreateProperties < ActiveRecord::Migration
  def up
    create_table :properties do |t|
      t.string :name
      t.string :value
      t.belongs_to :property_type
    end

    add_index :properties, [:value, :property_type_id]

    create_table :property_types do |t|
      t.string :name
      t.string :description
    end

    add_index :property_types, [:name]

  end

  def down
    drop_table :properties
    drop_table :property_types
  end
end

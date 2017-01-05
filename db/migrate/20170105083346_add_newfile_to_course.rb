class AddNewfileToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :excel, :string
  end
end

class AddExcelToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :excel, :string
  end
end

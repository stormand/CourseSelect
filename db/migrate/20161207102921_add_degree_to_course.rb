class AddDegreeToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :degree ,:boolean,default:false
  end
end

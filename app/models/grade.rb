class Grade < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  validates :grade, numericality: { only_integer: true, :greater_than => 0, :less_than => 100}
end

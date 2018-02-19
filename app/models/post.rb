class Post < ApplicationRecord
  validates :content, {presence: true, length: {maximum: 140}}
  validates :user_id, {presence: true}
  validates :latitude, {presence: true}
  validates :longitude, {presence: true}
  def user
    return User.find_by(id: self.user_id)
  end
  
end

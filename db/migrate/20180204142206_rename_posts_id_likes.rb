class RenamePostsIdLikes < ActiveRecord::Migration[5.1]
  def change
    remove_column :likes, :pots_id, :integer
    add_column :likes, :post_id, :integer
  end
end

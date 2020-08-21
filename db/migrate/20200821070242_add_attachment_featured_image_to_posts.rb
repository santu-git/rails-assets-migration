class AddAttachmentFeaturedImageToPosts < ActiveRecord::Migration[5.0]
  def self.up
    change_table :posts do |t|
      t.attachment :featured_image
    end
  end

  def self.down
    remove_attachment :posts, :featured_image
  end
end

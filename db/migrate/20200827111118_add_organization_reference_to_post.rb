class AddOrganizationReferenceToPost < ActiveRecord::Migration[5.2]
  def change
    add_reference :posts, :organization, foreign_key: true
  end
end

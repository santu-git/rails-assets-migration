class Post < ApplicationRecord
  # has_one_attached :featured_image do |attachment|
  #   attachment.service :digital_ocean
  #   attachment.bucket :"#{self.organization.bucket_name}"
  # end
  has_one_attached :featured_image
  belongs_to :organization
  #has_attached_file :featured_image, styles: { medium: "300x300>", thumb: "100x100>" }
  #validates_attachment_content_type :featured_image, content_type: /\Aimage\/.*\z/
end

# class Ckeditor::Picture < Ckeditor::Asset
#   has_attached_file :data,
#                     url: '/ckeditor_assets/pictures/:id/:style_:basename.:extension',
#                     path: ':rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension',
#                     styles: { content: '800>', thumb: '118x100#' }

#   validates_attachment_presence :data
#   validates_attachment_size :data, less_than: 2.megabytes
#   validates_attachment_content_type :data, content_type: /\Aimage/

#   def url_content
#     url(:content)
#   end
# end

# frozen_string_literal: true

class Ckeditor::Picture < Ckeditor::Asset
  # for validation, see https://github.com/igorkasyanchuk/active_storage_validations

  def url_content
    rails_representation_url(storage_data.variant(resize: '800>').processed, only_path: true)
  end

  def url_thumb
    rails_representation_url(storage_data.variant(resize: '118x100').processed, only_path: true)
  end
end


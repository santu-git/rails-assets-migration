# frozen_string_literal: true

class Ckeditor::Picture < Ckeditor::Asset
  # for validation, see https://github.com/igorkasyanchuk/active_storage_validations

  def url_content
    storage_data.variant(resize: '800>').service_url
    # p rails_representation_url(storage_data.variant(resize: '800>').processed, only_path: true)
  end

  def url_thumb
    storage_data.variant(resize: '118x100').service_url
    # p rails_representation_url(storage_data.variant(resize: '118x100').processed, only_path: true)
  end

end

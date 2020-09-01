class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def s3_service
    service = ActiveStorage::Blob.service
    return unless service.class.to_s ==   'ActiveStorage::Service::S3Service'
    service
  end
end

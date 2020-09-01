require 'aws-sdk-s3'
require 'active_storage/service/s3_service'
require 'active_support/core_ext/numeric/bytes'

module ActiveStorage
  class Service::S3Service < Service
    attr_reader :client, :bucket, :upload_options
    def initialize(bucket:, upload: {}, **options)
      @client = Aws::S3::Resource.new(**options)
      @bucket = @client.bucket(bucket)

      @upload_options = upload
    end
  end
end

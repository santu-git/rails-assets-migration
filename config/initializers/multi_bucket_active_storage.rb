module Methods
  def set_bucket(bucket)
    @bucket = get_bucket_obj(bucket)
    # @bucket = bucket
  end

  private
    def get_bucket_obj(bucket_name)
      s3 = Aws::S3::Resource.new(access_key_id: ENV.fetch("S3_KEY"), secret_access_key: ENV.fetch("S3_SECRET"), region: 'sgp1',endpoint: "https://sgp1.digitaloceanspaces.com")
      return s3.bucket(bucket_name)
    end
end
ActiveStorage::Service.module_eval { attr_writer :bucket }
ActiveStorage::Service.class_eval { include Methods }

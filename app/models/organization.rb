class Organization < ApplicationRecord
  has_many :posts

  after_create :create_s3_bucket

  def create_s3_bucket
    if self.bucket_name.present?
      client = Aws::S3::Client.new(
        access_key_id: ENV.fetch("S3_KEY"),
        secret_access_key: ENV.fetch("S3_SECRET"),
        endpoint: 'https://sgp1.digitaloceanspaces.com',
        region: 'sgp1'
      )

      # Create a new Space
      client.create_bucket({ bucket: bucket_name, acl: "private" })
    end
  end
end

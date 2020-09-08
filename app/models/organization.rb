class Organization < ApplicationRecord
  has_many :posts

  # after_create :create_s3_bucket

  def create_s3_bucket
    # debugger
    if self.bucket_name.present?
      client = Aws::S3::Client.new( access_key_id: 'DTICUU77NLQTBYPSJCIV', secret_access_key: 'QRTAvsMGDKYZmzxOWLngUiL2V77lt6kGvrZ+fkdieFY', endpoint: 'https://sgp1.digitaloceanspaces.com', region: 'sgp1' )
      client.create_bucket({ bucket: bucket_name, acl: "private" })
    end
  end
end

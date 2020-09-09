# frozen_string_literal: true

module ActiveStorage
  class Downloader
    def initialize(blob, tempdir: nil)
      @blob    = blob
      @tempdir = tempdir
    end

    def download_blob_to_tempfile
      open_tempfile do |file|
        download_blob_to file
        verify_integrity_of file
        yield file
      end
    end

    private

    attr_reader :blob, :tempdir

    def open_tempfile
      file = Tempfile.open(["ActiveStorage-#{blob.id}-", blob.filename.extension_with_delimiter], tempdir)

      begin
        yield file
      ensure
        file.close!
      end
    end

    def download_blob_to(file)
      file.binmode
      blob.download { |chunk| file.write(chunk) }
      file.flush
      file.rewind
    end

    def verify_integrity_of(file)
      raise ActiveStorage::IntegrityError unless Digest::MD5.file(file).base64digest == blob.checksum
    end
  end
end

module AsDownloadPatch
  def open(tempdir: nil, &block)
    ActiveStorage::Downloader.new(self, tempdir: tempdir).download_blob_to_tempfile(&block)
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Blob.send(:include, AsDownloadPatch)
end

def parse_html(html)
  html_doc = Nokogiri::HTML(html)
  nodes = html_doc.xpath("//img[@src]")
  raise "No <img .../> tags!" if nodes.empty?
  nodes.inject([]) do |uris, node|
    uris << node.attr('src').strip.split("/").last
  end.uniq
end

def migrate_blob(blob)
  p blob
  print '.'
  file = Tempfile.new("file#{Time.now}")
  file.binmode
  file << blob.download
  file.rewind
  checksum = blob.checksum
  to_service.upload(blob.key, file, checksum: checksum)
end

def migrate(from, to, organization)
  configs = Rails.configuration.active_storage.service_configurations
  from_service = ActiveStorage::Service.configure from, configs
  configs["digital_ocean"].merge!("bucket"=> organization.bucket_name)
  to_service = ActiveStorage::Service.configure to, configs
  p configs
  ActiveStorage::Blob.service = from_service
  ckeditor_assets = ActiveStorage::Attachment.where(record_type: "Ckeditor::Asset")
  organization.posts.each do |post|
    ck_asset_names = parse_html(post.description)
    ck_blobs = []
    ck_asset_names.each do |asset_name|
      blobs = []
      ckeditor_assets.each{|a| blobs << a if a.filename.to_s == asset_name}
      ck_blobs << blobs
    end
    ck_blobs.flatten.each do |ck_blob|
      begin
        p ck_blob.blob
        print '.'
        file = Tempfile.new("file#{Time.now}")
        file.binmode
        file << ck_blob.blob.download
        file.rewind
        checksum = ck_blob.blob.checksum
        to_service.upload(ck_blob.blob.key, file, checksum: checksum)
      rescue Errno::ENOENT
        puts "Rescued by Errno::ENOENT statement. ID: #{ck_blob.blob.id} / Key: #{ck_blob.blob.key}"
        next
      rescue ActiveStorage::FileNotFoundError
        puts "Rescued by FileNotFoundError. ID: #{ck_blob.blob.id} / Key: #{ck_blob.blob.key}"
        next
      end
    end
    begin
      p post.featured_image.blob
      print '.'
      file = Tempfile.new("file#{Time.now}")
      file.binmode
      file << post.featured_image.blob.download
      file.rewind
      checksum = post.featured_image.blob.checksum
      to_service.upload(post.featured_image.blob.key, file, checksum: checksum)
    rescue Errno::ENOENT
      puts "Rescued by Errno::ENOENT statement. ID: #{ck_blob.blob.id} / Key: #{ck_blob.blob.key}"
      next
    rescue ActiveStorage::FileNotFoundError
      puts "Rescued by FileNotFoundError. ID: #{ck_blob.blob.id} / Key: #{ck_blob.blob.key}"
      next
    end
  end
  # ActiveStorage::Blob.find_each do |blob|
  #   # p blob
  #   # print '.'
  #   # file = Tempfile.new("file#{Time.now}")
  #   # file.binmode
  #   # file << blob.download
  #   # file.rewind
  #   # checksum = blob.checksum
  #   # to_service.upload(blob.key, file, checksum: checksum)
  # rescue Errno::ENOENT
  #   puts "Rescued by Errno::ENOENT statement. ID: #{blob.id} / Key: #{blob.key}"
  #   next
  # rescue ActiveStorage::FileNotFoundError
  #   puts "Rescued by FileNotFoundError. ID: #{blob.id} / Key: #{blob.key}"
  #   next
  # end
end

namespace :migrate_local_storage do
  desc 'Migrate ActiveStorage files from local to Amazon S3'
  task to_s3_bucket: :environment do
    Organization.find_each do |organization|
      migrate(:local, :digital_ocean, organization)
    end
  end
end

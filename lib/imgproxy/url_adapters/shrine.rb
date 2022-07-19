module Imgproxy
  class UrlAdapters
    # Adapter for Shrine
    #
    #   Imgproxy.configure do |config|
    #     config.url_adapters.add Imgproxy::UrlAdapters::Shrine.new
    #   end
    #
    #   Imgproxy.url_for(user.avatar)
    class Shrine
      attr_reader :service_name

      def initialize(service_name)
        @service_name = service_name
      end

      def applicable?(image)
        image.is_a?(::Shrine::UploadedFile)
      end

      def url(image)
        return s3_url(image) if use_s3_url(image)

        opts = {}
        opts[:host] = config.shrine_host if Imgproxy.config.shrine_host
        image.url(opts)
      end

      private

      def s3_url(image)
        path = [*image.storage.prefix, image.id].join("/")
        "s3://#{image.storage.bucket.name}/#{path}"
      end

      def use_s3_url(image)
        config.use_s3_urls &&
          image.storage.is_a?(::Shrine::Storage::S3)
      end

      def config
        Imgproxy.config(service_name)
      end
    end
  end
end

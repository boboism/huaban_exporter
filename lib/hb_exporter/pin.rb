require 'tempfile'
require 'timeout'

module HbExporter
  class Pin

    attr_accessor :key, :data

    def initialize(key, opt={})
      @key  = key
      @data = opt[:data]
    end


    def to_s
      "#<Pin #{key} #{image_url}>"
    end
    

    def image_url
      return nil unless key
      @image_url ||= "http://img.hb.aicdn.com/" << key
    end


    EXPORT_TIMEOUT = 3
    MAX_RETRY_COUNT = 5 
    def export path: ''
      file_path = File.join(path, export_file_name)
      return true if !!!File.size?(file_path)
      retry_count = 0
      while !!!File.size?(file_path) && retry_count < MAX_RETRY_COUNT
        begin
          Timeout::timeout(EXPORT_TIMEOUT) do 
            Tempfile.open(export_file_name) do |tmpfile|
              tmpfile << HTTParty.get(image_url)
              tmpfile.flush
              FileUtils.cp tmpfile, file_path
            end
          end
        rescue Timeout::Error
          retry_count += 1
        end
      end
      true
    end


    def export_file_name
      [key, suffix].join ?.
    end


    def suffix
      data['file']['type'].split('/').last
    end

  end
end

# require 'rake'

module LocalizedLanguageSelect
  module Generators
    class LocalesGenerator < Rails::Generators::Base
      desc "Copy language locale files"

      class_option :locales, :type => :array, :default => ['all'], :desc => 'locales to generate for'
      class_option :file_ext,  :type => :string, :default => 'rb', :desc => 'file extension for locale files to copy'      

      source_root File.dirname(__FILE__)

      def main_flow      
        copy_locales
      end
  
      protected

      def file_ext
        options[:file_ext]
      end

      def locales
        return Dir.glob("#{locale_dir}/**.#{file_ext}") if options[:locales].include? 'all'        
        options[:locales].map(&:to_sym)
      end

      def locale_dir
        File.expand_path(locale_ref, File.dirname __FILE__)        
      end

      def locale_ref
        "../../../locale"
      end

      def locale_name
        :languages
      end
  
      def copy_locales                 
        locales.each do |locale|       
          locale_file = "#{locale}.#{file_ext}"
          file = File.join(locale_dir, locale_file)
          copy_file File.join(locale_ref, locale_file), "config/locales/#{locale_name}.#{locale}.#{file_ext}" if file.exist?
        end
      end  
    end
  end
end

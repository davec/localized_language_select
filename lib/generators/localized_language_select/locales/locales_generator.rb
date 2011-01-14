# require 'rails/generators/base'
# require 'sugar-high/array'
# require 'active_support/inflector'
# require 'rails3_artifactor'
# require 'logging_assist'

module LocalizedLanguageSelect
  module Generators
    class LocaleGenerator < Rails::Generators::Base
      desc "Copy locale files"

      class_option :locales, :type => :array, :default => ['all'], :desc => 'locales to generate for'

      source_root File.dirname(__FILE__)

      def main_flow      
        copy_locales
      end
  
      protected

      def supported_locales
        [:en, :da]
      end

      def locales
        return supported_locales if options[:locales].include? 'all'
        options[:locales].map(&:to_sym) & supported_locales
      end
  
      def copy_locales
        locales.each do |locale|          
          copy_file "../../../../locale/#{locale}.yml", "config/locales/languages.#{locale}.yml"
        end
      end
    end
  end
end
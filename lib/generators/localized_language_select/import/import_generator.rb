module LocalizedLanguageSelect
  module Generators
    class ImportGenerator < Rails::Generators::Base
      desc "Import language locale files"

      argument      :locales,   :type => :array,  :default => [],     :desc => 'locales to generate for'
      class_option  :file_ext,  :type => :string, :default => 'yml',  :desc => 'file extension for locale files to import'

      source_root File.dirname(__FILE__)

      def main_flow
        raise ArgumentError, "File extension must be yml or rb" if ![:rb, :yml, :yaml].include?(file_ext.to_sym)
        check_hpricot
        import_languages
      end

      protected

      def file_ext        
        options[:file_ext]
      end

      def languages_yaml_content
        languages.inject([]) do |output, language|
          output << "\t\t\t#{language[:code]}: \"#{language[:name]}\""
          output
        end.join("\n")
      end

      def languages_hash_content
        languages.inject([]) do |output, language|
          output << "\t\t\t:#{language[:code]} => \"#{language[:name]}\","
          output
        end.join("\n")
      end

      def get_output lang, file_ext
        send :"#{file_ext}_output", lang
      end

      def yaml_output lang
        %Q{
#{lang}:
  languages:
    #{languages_yaml_content}
}
      end

      def hash_output
        output = <<HASH
{ 
  :#{lang} => {
    :languages => {
      #{languages_hash_content}      
    }
  }
}
HASH
      end
    
      def check_hpricot
        begin
          require 'hpricot'
        rescue LoadError
          puts "Error: Hpricot library required to use this task (localized_language_select:import)"
          exit
        end
      end

      def import_languages
        # Check lang variable
        locales.each do |lang|
          import_language lang
        end
      end

      def valid_lang? lang
        if lang == 'lang' || (/\A[a-z]{2}\z/).match(lang) == nil
          puts "\n[!] Usage: rails g localized_language_select:import de ru --file-ext yml\n\n"
          exit 0
        end
      end
    
      def import_language lang
        valid_lang? lang
        # ----- Get the CLDR HTML     --------------------------------------------------
        begin
          puts "... getting the HTML file for locale '#{locale}'"
          doc = Hpricot( open("http://www.unicode.org/cldr/data/charts/summary/#{locale}.html") )
        rescue => e
          puts "[!] Invalid locale name '#{locale}'! Not found in CLDR (#{e})"
          exit 0
        end
        # require 'ruby-debug'            
        parse_languages doc
      end

      def parse_languages doc
        # ----- Parse the HTML with Hpricot     ----------------------------------------
        puts "... parsing the HTML file"
        languages = []
        doc.search("//tr").each do |row|
          next if !language_row?(row)
          languages << { :code => get_code(row).to_sym, :name => get_name(row).to_s }
        end
        generate_language_locales languages
      end

      def get_code row      
        row.search("td[@class='g']").inner_text.sub('_','-')
      end
      
      def get_name row
        row.search("td[@class='v']").first.inner_text
      end
      
      def language_row? row    
        row.search("td[@class='n']") && n_row?(row) && g_row?(row)
      end

      def n_row? row
        row.search("td[@class='n']").inner_html =~ /^nameslanguage$/
      end

      def g_row? row
        row.search("td[@class='g']").inner_html =~ /^[a-z]{2,3}(?:_([A-Z][a-z]{3}))?(?:_([A-Z]{2}))?$/
      end

      def generate_language_locales languages
        # ----- Prepare the output format     ------------------------------------------
        languages.each do |lang|
          write_locale_file lang
        end
      end

      def write_locale_file locale
        # ----- Write the parsed values into file      ---------------------------------
        puts "\n... writing the output"
        write_file locale
        puts "\n---\nWritten values for the '#{locale}' into file: #{filename}\n"
        # ------------------------------------------------------------------------------
      end
    
      def write_file locale
        filename = File.join(File.dirname(__FILE__), '..', 'locale', "languages.#{locale}.rb")
        filename += '.NEW' if File.exists?(filename) # Append 'NEW' if file exists
        File.open(filename, 'w+') { |f| f << get_output(lang) }
      end
    end
  end
end
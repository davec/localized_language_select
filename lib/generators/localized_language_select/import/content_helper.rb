module Import
  module ContentHelper
    def languages_yaml_content
      languages.inject([]) do |output, language|
        output << "    #{language[:code]}: \"#{language[:name]}\""
        output
      end.join("\n")
    end

    def languages_hash_content
      languages.inject([]) do |output, language|
        output << "    :#{language[:code]} => \"#{language[:name]}\","
        output
      end.join("\n")
    end

    def get_output
      send :"#{file_ext}_output"
    end

    def yaml_output
      %Q{#{locale}:
  languages:
#{languages_yaml_content}
}
    end
    alias_method :yml_output, :yaml_output

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
  end
end

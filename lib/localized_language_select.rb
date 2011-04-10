# = LocalizedLanguageSelect
# 
# View helper for displaying select list with languages:
# 
#     localized_language_select(:user, :language)
# 
# Works just like the default Rails' +country_select+ plugin, but stores languages as
# language *codes*, not *names*, in the database.
# 
# You can easily translate language codes in your application like this:
#     <%= I18n.t @user.language, :scope => 'languages' %>
# 
# Uses the Rails internationalization framework (I18n) for translating the names of languages.
# 
# Use Rake task <tt>rake import:language_select 'de'</tt> for importing language names
# from Unicode.org's CLDR repository (http://www.unicode.org/cldr/data/charts/summary/root.html)
# 
# The code borrows heavily from the LocalizedCountrySelect plugin.
# See http://github.com/karmi/localized_country_select
#

# require 'localized_language_select/i18n'

module LocalizedLanguageSelect
  class << self
    # Returns array with codes and localized language names (according to <tt>I18n.locale</tt>)
    # for <tt><option></tt> tags
    def localized_languages_array options = {}
      res = []
      list = I18n.translate(:languages).each do |key, value| 
        res << [value, key.to_s] if include_language?(key.to_s, options)
      end
      res.sort_by { |country| country.first.parameterize }
    end
    
    def include_language?(key, options)                                           
      if options[:only] 
        return options[:only].include?(key)
      end      
      if options[:except] 
        return !options[:except].include?(key)
      end
      true      
    end      
    
    
    # Return array with codes and localized language names for array of language codes passed as argument
    # == Example
    #   priority_languages_array([:de, :fr, :en])
    #   # => [ ['German', 'de'], ['French', 'fr'], ['English', 'en'] ]
    def priority_languages_array(language_codes=[])
      languages = I18n.translate(:languages)
      language_codes.map { |code| [languages[code.to_sym], code.to_s] }
    end
  end
end

module ActionView
  module Helpers

    module FormOptionsHelper

      # Return select and option tags for the given object and method, using +localized_language_options_for_select+ 
      # to generate the list of option tags. Uses <b>language code</b>, not name as option +value+.
      # Language codes listed as an array of symbols in +priority_languages+ argument will be listed first
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      def localized_language_select(object, method, priority_languages = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).
          to_localized_language_select_tag(priority_languages, options, html_options)
      end

      # Return "named" select and option tags according to given arguments.
      # Use +selected_value+ for setting initial value
      # It behaves likes older object-binded brother +localized_language_select+ otherwise
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      def localized_language_select_tag(name, selected_value = nil, priority_languages = nil, html_options = {})
        content_tag :select,
                    localized_language_options_for_select(selected_value, priority_languages),
                    { "name" => name, "id" => name }.update(html_options.stringify_keys)
      end

      # Returns a string of option tags for languages according to locale. Supply the language code in lower-case ('en', 'de') 
      # as +selected+ to have it marked as the selected option tag.
      # Language codes listed as an array of symbols in +priority_languages+ argument will be listed first
      def localized_language_options_for_select(selected = nil, priority_languages = nil, options = {})
        language_options = ""
        if priority_languages
          language_options += options_for_select(LocalizedLanguageSelect::priority_languages_array(priority_languages), selected)
          language_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        return language_options + options_for_select(LocalizedLanguageSelect::localized_languages_array(options), selected)
      end
      
    end

    class InstanceTag
      def to_localized_language_select_tag(priority_languages, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            localized_language_options_for_select(value, priority_languages, options),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def localized_language_select(method, priority_languages = nil, options = {}, html_options = {})
        @template.localized_language_select(@object_name, method, priority_languages, options.merge(:object => @object), html_options)
      end
    end

  end
end


module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder
    
    protected

      def language_input(method, options)
        html_options = options.delete(:input_html) || {}
        priority_languages = options.delete(:priority_languages) || []

        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]

        label(method, label_options) <<
        localized_language_select(method, priority_languages, strip_formtastic_options(options), html_options)
      end

  end
end


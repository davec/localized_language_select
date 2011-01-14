# encoding: utf-8

# TODO !!! ("stolen" from Formtastic, but can't seem to make it work... waiting for engines to do this magic OOTB !)

# module LocalizedLanguageSelect
#   module I18n
#     DEFAULT_SCOPE = [:languages].freeze
#     DEFAULT_VALUES = YAML.load_file(File.expand_path("../../../locale/en.yml", __FILE__))["en"]["languages"].freeze
# 
#     class << self
#       def translate(*args)
#         key = args.shift.to_sym
#         options = args.extract_options!
#         options.reverse_merge!(:default => DEFAULT_VALUES[key])
#         options[:scope] = [DEFAULT_SCOPE, options[:scope]].flatten.compact
#         ::I18n.translate(key, *(args << options))
#       end
#       alias :t :translate
#     end
#   end
# end   

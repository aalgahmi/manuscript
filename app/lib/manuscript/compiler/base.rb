require "#{__dir__}/../converter/html"

module Manuscript
  module Compiler
    class Base
      def initialize(theme = :default)
        @theme = theme
        @config = YAML.load_file("#{APP_ROOT}/app/config/application.yml")
      end
    
      def config
        @config['manuscript']['compiler']
      end
    
      def theme
        @theme
      end
    
      def content 
        if @content.nil?
          @content = ''
          Dir.glob("#{APP_ROOT}/contents/*").sort.each do |f|
            unless File.directory?(f) || f.start_with?('.')
              @content << File.read(f)
              @content << "\n\n"
            end
          end
        end
        
        @content
      end
    
      def include_styles
        ERB.new(File.read("#{APP_ROOT}/app/assets/styles/#{theme}.css.erb")).result(binding)
      end
      
      def include_style(file)
        File.read("#{APP_ROOT}/app/assets/styles/#{file}")
      end
    
      def compile
        raise StandardError, "No compiler found for the #{target} target."
      end
    end
  end
end
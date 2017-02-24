require "#{__dir__}/../converter/html"

module Manuscript
  module Compiler
    class Base
      def initialize(theme = :default)
        @theme = theme
        @config = YAML.load_file("#{APP_ROOT}/config/application.yml")
        @template = File.read("#{APP_ROOT}/assets/layouts/#{theme}.#{target}.erb")
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
          Dir.glob("#{APP_ROOT}/manuscript/*").sort.each do |f|
            @content << File.read(f)
            @content << "\n\n"
          end
        end
        
        @content
      end
    
      def include_styles
        ERB.new(File.read("#{APP_ROOT}/assets/styles/#{theme}.css.erb")).result(binding)
      end
      
      def include_style(file)
        File.read("#{APP_ROOT}/assets/styles/#{file}")
      end
    
      def compile
        raise StandardError, "No compiler found for the #{target} target."
      end
    end
  end
end
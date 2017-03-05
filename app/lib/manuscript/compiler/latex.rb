require "#{__dir__}/../converter/latex"

module Manuscript
  module Compiler
    class Latex < Base
      def initialize(theme = :default)
        super
        @template = File.read("#{APP_ROOT}/app/assets/layouts/#{theme}.#{target}.erb")
      end
      
      def target 
        'tex'
      end
      
      def compile
        FileUtils.rm_rf Dir.glob("#{APP_ROOT}/output/*")
        FileUtils.cp_r("#{APP_ROOT}/app/assets/images", "#{APP_ROOT}/output/images")
        Dir.chdir("#{APP_ROOT}/contents/figures")
      
        width = config['kramdown']['tex']['max_figure_width'].nil? ? 10000 : config['kramdown']['tex']['max_figure_width'].to_i
        Dir.foreach(".") do |f|
          unless File.directory?(f) || f.start_with?('.')
            image = MiniMagick::Image.open(f)
          
            width = image.width  if width > image.width 
            height = image.height * width / image.width 
          
            image.resize("#{width}x#{height}")
            image.write "#{APP_ROOT}/output/images/#{f}"
          end
        end
      
        File.write("#{APP_ROOT}/output/#{config['output']}.#{target}", ERB.new(@template).result(binding))
      end
    end
  end
end
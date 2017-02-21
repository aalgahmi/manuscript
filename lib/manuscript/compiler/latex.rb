module Manuscript
  module Compiler
    class Latex < Html
      def compile
        `rm -rf #{APP_ROOT}/output/*`

        `mkdir #{APP_ROOT}/output/images`
        Dir.chdir("#{APP_ROOT}/assets/images")
      
        width = config['kramdown']['tex']['max_figure_width'].nil? ? 10000 : config['kramdown']['tex']['max_figure_width'].to_i
        Dir.foreach(".") do |f|
          unless File.directory?(f)
            image = MiniMagick::Image.open(f)
          
            width = image.width  if width > image.width 
            height = image.height * width / image.width 
          
            image.resize("#{width}x#{height}")
            image.write "#{APP_ROOT}/output/images/#{f}"
          end
        end
      
        File.write("#{APP_ROOT}/output/#{config['output']}.#{@target}", ERB.new(@template).result(binding))
      end
    end
  end
end
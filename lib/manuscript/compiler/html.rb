require "#{__dir__}/../converter/html"

module Manuscript
  module Compiler
    class Html < Base
      def target 
        'html'
      end
      
      def compile
        FileUtils.rm_rf Dir.glob("#{APP_ROOT}/output/*")
        FileUtils.cp_r("#{APP_ROOT}/assets/images", "#{APP_ROOT}/output/images")
        File.write("#{APP_ROOT}/output/#{config['output']}.#{target}", ERB.new(@template).result(binding))
      end
    end
  end
end
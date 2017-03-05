require "#{__dir__}/../converter/html"

module Manuscript
  module Compiler
    class Html < Base
      def initialize(theme = :default)
        super
        @template = File.read("#{APP_ROOT}/app/assets/layouts/#{theme}.#{target}.erb")
      end
      
      def target 
        'html'
      end
      
      def compile
        FileUtils.rm_rf Dir.glob("#{APP_ROOT}/output/*")
        FileUtils.cp_r("#{APP_ROOT}/app/assets/images", "#{APP_ROOT}/output/images")
        FileUtils.cp(Dir.glob("#{APP_ROOT}/book/figures/*"), "#{APP_ROOT}/output/images")
        File.write("#{APP_ROOT}/output/#{config['output']}.#{target}", ERB.new(@template).result(binding))
      end
    end
  end
end
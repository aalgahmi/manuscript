module Manuscript
  module Compiler
    class Html
      def initialize(theme = :default, target = :html)
        @theme = theme
        @target = target.to_s
        @config = YAML.load_file("#{APP_ROOT}/config/application.yml")
        @template = File.read("#{APP_ROOT}/assets/layouts/#{theme}.#{target}.erb")
      end
    
      def config
        @config['book']['compiler']
      end
    
      def theme
        @theme
      end
    
      def target
        @target
      end
    
      def book 
        @book ||= %(
* TOC
{:toc}

#{`ls -1 #{APP_ROOT}/manuscript/* | sort | xargs awk 'FNR==1 && NR!=1 {print "\\n"}{print}'`}
        )
      end
    
      def include_styles
        %(<style>#{ERB.new(File.read("#{APP_ROOT}/assets/styles/#{theme}.css.erb")).result(binding)}</style>)
      end
    
      def compile
        `rm -rf #{APP_ROOT}/output/*`
        `cp -R #{APP_ROOT}/assets/images #{APP_ROOT}/output/images`
        File.write("#{APP_ROOT}/output/#{config['output']}.#{@target}", ERB.new(@template).result(binding))
      end
    end
  end
end
require "#{__dir__}/../converter/epub"

module Manuscript
  module Compiler
    class Epub < Html
      @@toc = []
      @@chapters = []
      @@figures = []
      def initialize(theme = :default, target = :html)
        @theme = theme
        @target = target.to_s
        @config = YAML.load_file("#{APP_ROOT}/config/application.yml")
        @template = File.read("#{APP_ROOT}/assets/layouts/epub/#{theme}.xhtml.erb")
        @cover_template = File.read("#{APP_ROOT}/assets/layouts/epub/cover.xhtml.erb")
        @opf_templage = File.read("#{APP_ROOT}/assets/layouts/epub/package.opf.erb")
        @css_templage = File.read("#{APP_ROOT}/assets/layouts/epub/css/styles.css.erb")
      end
    
      def content 
        @content
      end
      
      def include_opf_manifest_items 
        items = ''
        @manifest_items.each do |i|
          items << %(\n    <item id="#{i[:id]}" href="#{i[:href]}" media-type="#{i[:type]}"#{i[:properties].nil? ? '' : " properties=\"#{i[:properties]}\""}/>)
        end
        
        items
      end
      
      def include_opf_spine_items 
        items = ''
        @spine_items.each do |i|
          items << %(\n    <itemref idref="#{i[:idref]}"#{i[:linear].nil? ? '' : " linear=\"#{i[:linear]}\""}/>)
        end
        
        items
      end
    
      def publish
        require 'zip'
        path = "."
        archive = "manuscript.epub"
        Zip::File.open("#{path}/#{archive}", Zip::File::CREATE) do |zip|
          Dir["**/**"].reject{|f| f == archive && f.start_with?('.')}.each do |f|
            zip.add(f.sub(path +'/',''), f) 
          end
        end
        
        FileUtils.rm_rf "./contents"
        FileUtils.rm_rf "./META-INF"
        FileUtils.rm "mimetype"
      end
      
      def compile
        @manifest_items = []
        @spine_items = []
        FileUtils.rm_rf Dir.glob("#{APP_ROOT}/output/*")
        
        Dir.mkdir "#{APP_ROOT}/output/contents"
        Dir.chdir "#{APP_ROOT}/output"
        
        FileUtils.cp_r(Dir.glob("#{APP_ROOT}/assets/images"), "./contents/")
        count = 0
        Dir.foreach("./contents/images") do |f|
          unless File.directory?(f) || f.start_with?('.')
            count += 1
            @manifest_items << {id: %(img-#{"%03d" % count}), href: "images/#{f}", type: "image/#{File.extname(f) == 'jpg' ? 'jpeg' : File.extname(f)}"}
            if "images/#{f}" == (config['epub']['cover_image'] || 'images/cover-image.png')
              @manifest_items.last[:properties] = 'cover-image' 
              File.write("./contents/cover.xhtml", ERB.new(@cover_template).result(binding))
              @manifest_items << {id: 'cover', href: "cover.xhtml", type: 'application/xhtml+xml'}
              @spine_items << {idref: 'cover'}
            end
          end
        end
        
        FileUtils.cp_r("#{APP_ROOT}/assets/layouts/epub/META-INF", ".")
        FileUtils.cp("#{APP_ROOT}/assets/layouts/epub/mimetype", ".")
        
        Dir.mkdir "#{APP_ROOT}/output/contents/css"
        File.write("#{APP_ROOT}/output/contents/css/styles.css", ERB.new(@css_templage).result(binding))
        @manifest_items << {id: 'style', href: 'css/styles.css', type: 'text/css'}
        
        count = 0
        Dir.foreach("#{APP_ROOT}/manuscript") do |f|
          unless File.directory?(f) || f.start_with?('.')
            count += 1
            fname = File.basename(f, ".*")
            @content = File.read("#{APP_ROOT}/manuscript/#{f}")
            
            if @content.include?("{:toc}")
              @manifest_items << {id: 'toc', href: "toc.xhtml", type: 'application/xhtml+xml', properties: 'nav'} 
              @spine_items << {idref: 'toc'}
              fname = 'toc'
            else
              @@file = "#{fname}.xhtml"
              @manifest_items << {id: %(chp-#{"%03d" % count}), href: "#{fname}.xhtml", type: 'application/xhtml+xml'}
              @spine_items << {idref: %(chp-#{"%03d" % count})} 
            end
            
            File.write("./contents/#{fname}.xhtml.erb", ERB.new(@template).result(binding).sub(/&nbsp;/, " "))
          end
        end
        
        Dir.glob("./contents/*.xhtml.erb") do |f|
          result = ERB.new(File.read(f)).result(binding)
          @@figures.each do |f|
            result.sub!(/<a href="##{f.first}">.*?<\/a>/, %(#{f.last}))
          end
          
          File.write("./contents/#{File.basename(f, ".*")}", result)
        end
        FileUtils.rm Dir.glob("./contents/*.xhtml.erb")
        
        File.write("./contents/package.opf", ERB.new(@opf_templage).result(binding))
        self.publish
      end
      
      def include_toc
        toc = ""
        @@toc.each_with_index do |t, i|
          indent = '  ' * t[:level]
          if i == 0 || ((i + 1) < @@toc.count && @@toc[i + 1][:level] > t[:level])
            toc << %(<li>\n<a href="#{t[:file]}##{t[:id]}">#{t[:name]}</a>\n)
            toc << %(<ol>\n) if (i + 1) < @@toc.count
          elsif (i + 1) < @@toc.count && @@toc[i + 1][:level] == t[:level]
            toc << %(<li><a href="#{t[:file]}##{t[:id]}">#{t[:name]}</a></li>\n)
          elsif (i + 1) < @@toc.count && @@toc[i + 1][:level] < t[:level]
            toc << %(<li><a href="#{t[:file]}##{t[:id]}">#{t[:name]}</a></li>\n)
            toc << "</ol>\n</li>\n" * (t[:level] - @@toc[i + 1][:level])
          end
        end
        toc << "</ol>\n</li>\n" * @@toc.last[:level]
        
        %(<nav epub:type="toc">\n<h3>Table of contents</h3>\n<ol>#{toc}</ol>\n</nav>)
      end
      
      def self.add_to_toc(name, level, id, role)
        @@toc << {file: @@file, name: name, level: level, id: id, role: role}
      end
      
      def self.add_to_chapters(id)
        @@chapters << [id, []]
      end
      
      def self.label_figure(id)
        @@chapters.last.last << id
        @@figures << [id, "Figure #{@@chapters.count}.#{@@chapters.last.last.count}"]
        @@figures.last.last
      end
    end
  end
end
module Kramdown
  module Converter
    class Html < Base
      def convert_p(el, indent)
        if el.options[:transparent]
          inner(el, indent)
        elsif !el.children.nil? && el.children.count == 1 && el.children.first.type == :img
          convert_figure(el.children.first, indent)
        else
          format_as_block_html(el.type, el.attr, inner(el, indent), indent)
        end
      end

      def convert_figure(el, indent)
        id = %(#{el.attr['alt'] || generate_id(el.attr['title'])})
        el.attr['alt'] = el.attr['title'] unless el.attr['title'].nil?
        caption = "#{(el.attr['title'] ? "<figcaption><span>#{Manuscript::Compiler::Epub.label_figure(id)}</span>: #{el.attr['title']}</figcaption>" : "")}"
        %(#{' '*indent}<figure id="#{id}">#{caption}<img#{html_attributes(el.attr)} /></figure>\n)
      end
      
      def convert_header(el, indent)
        attr = el.attr.dup
        if @options[:auto_ids] && !attr['id']
          attr['id'] = generate_id(el.options[:raw_text])
        end
        
        @toc << [el.options[:level], attr['id'], el.children] if attr['id'] && in_toc?(el)
        level = attr['role'] == 'part' ? 0 : output_header_level(el.options[:level])
        Manuscript::Compiler::Epub.add_to_toc(el.options[:raw_text], level, attr['id'], attr['role']) if level <= 2
        if attr['role'] == 'part'
          %(#{' '*indent}<div id="#{attr['id']}" class="part header">#{inner(el, indent)}</div>)
        else
          if level == 1
            Manuscript::Compiler::Epub.add_to_chapters(attr['id'])
            format_as_block_html("h#{level}", attr, %(<span class="u-pull-right">#{@chapter_counter}</span> #{inner(el, indent)}), indent)
          else
            format_as_block_html("h#{level}", attr, inner(el, indent), indent)
          end
        end
      end
      
      def convert_a(el, indent)
        format_as_span_html(el.type, el.attr, inner(el, indent))
      end
      
      def convert_root(el, indent)
        result = inner(el, indent)
        if @footnote_location
          result.sub!(/#{@footnote_location}/, footnote_content.gsub(/\\/, "\\\\\\\\"))
        else
          result << footnote_content
        end
        if @toc_code
          result = "<%= include_toc %>"
        end
        result
      end
    end
  end
end
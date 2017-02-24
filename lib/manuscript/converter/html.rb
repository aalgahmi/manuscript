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
        @figure_counter = (@figure_counter || 0) + 1
        id = %(#{el.attr['alt'] || generate_id(el.attr['title'])})
        el.attr['alt'] = el.attr['title'] unless el.attr['title'].nil?
        caption = "#{(el.attr['title'] ? "<figcaption><span>Figure #{@chapter_counter}.#{@figure_counter}</span>: #{el.attr['title']}</figcaption>" : "")}"
        %(#{' '*indent}<figure id="#{id}"><img#{html_attributes(el.attr)} />#{caption}</figure>\n)
      end
      
      def convert_header(el, indent)
        attr = el.attr.dup
        if @options[:auto_ids] && !attr['id']
          attr['id'] = generate_id(el.options[:raw_text])
        end
        
        @toc << [el.options[:level], attr['id'], el.children] if attr['id'] && in_toc?(el)
        
        level = output_header_level(el.options[:level])
        if level == 1 && ( !attr['role'] || attr['role'] == 'chapter')
          attr['role'] = 'chapter'
          @chapter_counter = (@chapter_counter || 0) + 1
          @figure_counter = 0
          format_as_block_html("h#{level}", attr, %(<span class="u-pull-right">#{@chapter_counter}</span> #{inner(el, indent)}), indent)
        else
          format_as_block_html("h#{level}", attr, inner(el, indent), indent)
        end
      end
      
      def convert_a(el, indent)
        format_as_span_html(el.type, el.attr, inner(el, indent))
      end
    end
  end
end
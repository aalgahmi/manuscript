module Kramdown
  module Converter
    class Latex < Base
      def convert_header(el, opts)
        type = @options[:latex_headers][output_header_level(el.options[:level]) - 1]
        if ((id = el.attr['id']) ||
            (@options[:auto_ids] && (id = generate_id(el.options[:raw_text])))) && in_toc?(el)
          if el.attr['role'] == 'part'
            "\\part{#{inner(el, opts)}}\\hypertarget{#{id}}{}\\label{#{id}}\n\n"
          else
            "\\#{type}{#{inner(el, opts)}}\\hypertarget{#{id}}{}\\label{#{id}}\n\n"
          end
        else
          "\\#{type}*{#{inner(el, opts)}}\n\n"
        end
      end
      
      def convert_standalone_image(el, opts, img)
        @figure_labels = (@figure_labels || [])
        attrs = attribute_list(el)
        label =  el.children.first.attr['alt'] || generate_id(el.children.first.attr['title'])
        caption = escape(el.children.first.attr['title'] || el.children.first.attr['alt'])
        @figure_labels << label
        "\\begin{figure}#{attrs}\n\\begin{center}\n#{img}\n\\end{center}\n\\caption{#{caption}}\n\\label{#{label}}\n#{latex_link_target(el, true)}\n\\end{figure}#{attrs}\n"
      end
      
      def convert_a(el, opts)
        url = el.attr['href']
        if !@figure_labels.nil? && @figure_labels.include?(url[1..-1])
          "#{inner(el, opts)}~\\ref{#{url[1..-1]}}"
        elsif url.start_with?('#')
          "\\hyperlink{#{escape(url[1..-1])}}{#{inner(el, opts)}}"
        else
          "\\href{#{escape(url)}}{#{inner(el, opts)}}"
        end
      end
      
      def convert_codeblock(el, opts)
        show_whitespace = el.attr['class'].to_s =~ /\bshow-whitespaces\b/
        lang = extract_code_language(el.attr)
        
        if @options[:syntax_highlighter_opts] && @options[:syntax_highlighter_opts][:line_numbers]
          @syntax_highlighter_opts_line_number = @options[:syntax_highlighter_opts][:line_numbers]
          if el.value.strip.lines.count < 2
            @options[:syntax_highlighter_opts][:line_numbers] = false
          end
        end
        
        if @options[:syntax_highlighter] == :minted &&
            (highlighted_code = highlight_code(el.value, lang, :block))
          @data[:packages] << 'minted'
          @options[:syntax_highlighter_opts][:line_numbers] = @syntax_highlighter_opts_line_number if @syntax_highlighter_opts_line_number
          "#{latex_link_target(el)}#{highlighted_code}\n"
        elsif show_whitespace || lang
          options = []
          options << "showspaces=%s,showtabs=%s" % (show_whitespace ? ['true', 'true'] : ['false', 'false'])
          options << "language=#{lang}" if lang
          options << "basicstyle=\\ttfamily\\footnotesize,columns=fixed,frame=tlbr"
          id = el.attr['id']
          options << "label=#{id}" if id
          attrs = attribute_list(el)
          @options[:syntax_highlighter_opts][:line_numbers] = @syntax_highlighter_opts_line_number if @syntax_highlighter_opts_line_number
          "#{latex_link_target(el)}\\begin{lstlisting}[#{options.join(',')}]\n#{el.value}\n\\end{lstlisting}#{attrs}\n"
        else
          @options[:syntax_highlighter_opts][:line_numbers] = @syntax_highlighter_opts_line_number if @syntax_highlighter_opts_line_number
          "#{latex_link_target(el)}\\begin{verbatim}#{el.value}\\end{verbatim}\n"
        end
      end
    end
  end
end
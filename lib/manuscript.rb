require 'erb'
require "#{__dir__}/manuscript/compiler/html"

APP_ROOT = "#{__dir__}/.."

TARGETS = ['html', 'tex', 'epub']

TARGET =  case ARGV[0]
          when 'html'
            Manuscript::Compiler::Html
          when 'tex'
            require "#{__dir__}/manuscript/compiler/latex"
            Manuscript::Compiler::Latex
          when 'epub'
            require "#{__dir__}/manuscript/compiler/epub"
            Manuscript::Compiler::Epub
          end

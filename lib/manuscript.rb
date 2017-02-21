require 'erb'
require "#{__dir__}/manuscript/compiler/html"
require "#{__dir__}/manuscript/compiler/latex"
require "#{__dir__}/manuscript/converter/html"
require "#{__dir__}/manuscript/converter/latex"

APP_ROOT = "#{__dir__}/.."
TARGETS = {
  'html' => Manuscript::Compiler::Html, 
  'tex'  => Manuscript::Compiler::Latex
}



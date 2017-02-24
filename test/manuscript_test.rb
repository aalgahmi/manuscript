require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require "#{__dir__}/../lib/manuscript"
require 'minitest/autorun'

class ManuscriptTest < Minitest::Test
  def setup 
    FileUtils.rm_rf Dir.glob("#{APP_ROOT}/output/*")
  end
  
  def test_html_compiler
    Manuscript::Compiler::Html.new(:default, 'html').compile
    assert File.exist?("#{APP_ROOT}/output/manuscript.html")
  end
  
  def test_latex_compiler
    require "#{APP_ROOT}/lib/manuscript/compiler/latex"
    Manuscript::Compiler::Latex.new(:default, 'tex').compile
    assert File.exist?("#{APP_ROOT}/output/manuscript.tex")
  end
  
  def test_epub_compiler
    require "#{APP_ROOT}/lib/manuscript/compiler/epub"
    Manuscript::Compiler::Epub.new(:default, 'epub').compile
    assert File.exist?("#{APP_ROOT}/output/manuscript.epub")
  end
end
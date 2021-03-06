APP_ROOT = "#{__dir__}/../.."

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'minitest/autorun'
require "#{APP_ROOT}/app/lib/manuscript/compiler/base"

class ManuscriptTest < Minitest::Test
  def setup 
    FileUtils.rm_rf Dir.glob("#{APP_ROOT}/output/*")
    @config = YAML.load_file("#{APP_ROOT}/app/config/application.yml")['manuscript']['compiler']
  end
  
  def test_html_compiler
    require "#{APP_ROOT}/app/lib/manuscript/compiler/html"
    Manuscript::Compiler::Html.new(:default).compile
    assert File.exist?("#{APP_ROOT}/output/#{@config['output']}.html")
  end
  
  def test_latex_compiler
    require "#{APP_ROOT}/app/lib/manuscript/compiler/latex"
    Manuscript::Compiler::Latex.new(:default).compile
    assert File.exist?("#{APP_ROOT}/output/#{@config['output']}.tex")
  end
  
  def test_epub_compiler
    require "#{APP_ROOT}/app/lib/manuscript/compiler/epub"
    Manuscript::Compiler::Epub.new(:default).compile
    assert File.exist?("#{APP_ROOT}/output/#{@config['output']}.epub")
  end
end
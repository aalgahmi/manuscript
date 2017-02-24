require 'erb'
require "#{__dir__}/manuscript/compiler/base"
require "#{__dir__}/manuscript/compiler/#{ARGV[0]}"

TARGET =  Object.const_get("Manuscript::Compiler::#{ARGV[0].capitalize}")

FileUtils.mkdir_p("#{APP_ROOT}/output")


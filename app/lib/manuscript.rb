require 'erb'
require "#{APP_ROOT}/app/lib/manuscript/compiler/base"
require "#{APP_ROOT}/app/lib/manuscript/compiler/#{ARGV[0]}"

TARGET =  Object.const_get("Manuscript::Compiler::#{ARGV[0].capitalize}")

FileUtils.mkdir_p("#{APP_ROOT}/output")


target_argv = case ARGV[0]
              when 'pdf'
                'latex'
              when 'mobi'
                'epub'
              else
                ARGV[0]
              end

require 'erb'
require "#{APP_ROOT}/app/lib/manuscript/compiler/base"
require "#{APP_ROOT}/app/lib/manuscript/compiler/#{target_argv}"

TARGET =  Object.const_get("Manuscript::Compiler::#{target_argv.capitalize}")

FileUtils.mkdir_p("#{APP_ROOT}/output")


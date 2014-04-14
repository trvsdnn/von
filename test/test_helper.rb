$LOAD_PATH.unshift(File.expand_path('../../test', __FILE__))

require 'rubygems'
require 'bundler'
Bundler.setup

require 'minitest/autorun'
require 'minitest/pride'
require 'fakeredis'
require 'mocha/mini_test'
require 'timecop'

require 'von'
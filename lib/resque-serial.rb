require 'rubygems'
require 'resque'
require 'active_support/core_ext/string/inflections'

require 'resque-serial/version'
require 'resque-serial/extender'
require 'resque-serial/lockable'
require 'resque-serial/sync_job'
require 'resque-serial/async_job'
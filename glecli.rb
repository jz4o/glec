# glecli
# Glec on Command Line Interface
#

$:.unshift File.dirname(__FILE__)

require 'glec'
require 'optparse'

params = ARGV.getopts(
  '',
  "owner:#{DEFAULT_OWNER}",
  "repo:#{DEFAULT_REPO}",
  "user:#{DEFAULT_USER}",
  "type:#{DEFAULT_TYPE}"
).map{ |k,v| [k.to_sym, v] }.to_h

Glec.start(params)

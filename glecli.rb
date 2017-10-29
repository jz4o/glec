# glecli
# Glec on Command Line Interface
#

require_relative './glec'
require 'optparse'

include Glec

params = ARGV.getopts(
  '',
  "owner:#{DEFAULT_OWNER}",
  "repo:#{DEFAULT_REPO}",
  "user:#{DEFAULT_USER}",
  "type:#{DEFAULT_TYPE}"
).map { |k, v| [k.to_sym, v] }.to_h

puts Glec.start(params)

require 'open3'
require 'find'
require 'stringio'

require 'lvar_send/silencer'

LvarSend::Silencer.silently do
  require 'parser/current'
end
require 'git_diff'

require "lvar_send/version"
require 'lvar_send/cli'
require 'lvar_send/runner'
require 'lvar_send/walker'

module LvarSend
  # Your code goes here...
end

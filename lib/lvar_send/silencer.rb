module LvarSend
  module Silencer
    def self.silently
      stderr = $stderr
      $stderr = StringIO.new
      yield
    ensure
      $stderr = stderr
    end
  end
end

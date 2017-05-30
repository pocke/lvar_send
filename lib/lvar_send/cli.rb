module LvarSend
  class CLI
    def initialize(argv)
      @argv = argv
    end

    def run
      before = @argv[0]
      after  = @argv[1]
      Runner.new(before, after).run
      return 0
    end
  end
end

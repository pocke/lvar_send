module LvarSend
  class Runner
    def initialize(before_dir, after_dir)
      @before = before_dir
      @after = after_dir
    end

    def run
      lvar_positions = node_positions(root_dir: @before, type: :lvar)
      require 'pp'
      pp lvar_positions

      puts '----------------------------'
      cond = lambda do |node|
        recv, _name, *args = *node
        recv.nil? && args.empty?
      end
      send_positions = node_positions(root_dir: @before, type: :send, &cond)
      pp send_positions
      return 0
    end

    private

    def node_positions(root_dir:, type:, &cond)
      Walker.walk(root_dir).map do |path|
        nodes = nodes(path: path, type: type)
        nodes = nodes.select{|node| cond.call(node)} if cond

        positions = nodes.map do |node|
          loc = node.loc.expression
          {
            line: loc.line,
            column: loc.column,
            name: node_to_name(node),
          }
        end
        [path, positions]
      end.to_h
    end

    def nodes(path:, type:)
      ast = Parser::CurrentRuby.parse(File.read(path))
      return [] unless ast
      find_nodes(ast, type: type)
    end

    def find_nodes(node, type:)
      [node.type == type ? node : nil].concat(node.children.map do |n|
        find_nodes(n, type: type) if n.is_a?(Parser::AST::Node)
      end).flatten.compact
    end

    def node_to_name(node)
      case node.type
      when :lvar
        node.children[0]
      when :send
        node.children[1]
      else
        raise "#{node} type is not supported!"
      end
    end

    # TODO: diff
    # @param a [Hash{line:, column:, name:}] an position
    # @param b [Hash{line:, column:, name:}] an position
    # @param diff [WIP] WIP
    def same_position?(a, b, diff: nil)
      a.line == b.line &&
        a.column == b.column &&
        a.name == b.name
    end
  end
end

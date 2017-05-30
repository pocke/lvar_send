module LvarSend
  class Runner
    def initialize(before_dir, after_dir)
      @before = before_dir
      @after = after_dir
    end

    def run
      patches = dir_to_patches(@before, @after)
        .select{|patch| Walker.ruby_file?(patch.file)}
      patches.each do |patch|
        file = patch.file
        before_path = file.start_with?(@after) ? file.sub(@after, @before) : file

        lvar_positions = positions(path: before_path, type: :lvar)
        p lvar_positions
        send_positions = positions(path: file, type: :send, &simple_send_node?)
        p send_positions
      end

      return 0
    end

    private

    def positions(path:, type:, &cond)
      ast = Parser::CurrentRuby.parse(File.read(path))
      return [] unless ast
      nodes = find_nodes(ast, type: type)
      nodes = nodes.select{|node| cond.call(node)} if cond
      nodes.map do |node|
        loc = node.loc.expression
        {
          line: loc.line,
          column: loc.column,
          name: node_to_name(node),
        }
      end
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

    # @param a [Hash{line:, column:, name:}] an position
    # @param b [Hash{line:, column:, name:}] an position
    # @param diff [WIP] WIP
    def same_position?(a, b, diff: nil)
      a.line == b.line &&
        a.column == b.column &&
        a.name == b.name
    end

    # @param before [String] a directory
    # @param after [String] a directory
    def dir_to_patches(before, after)
      diff, _stderr, _status = Open3.capture3('git', 'diff', '--no-index', before, after)

      GitDiffParser.parse(diff)
    end

    def simple_send_node?
      lambda do |node|
        recv, _name, *args = *node
        recv.nil? && args.empty?
      end
    end
  end
end

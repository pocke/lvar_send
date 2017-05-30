module LvarSend
  class Runner
    def initialize(before_dir, after_dir)
      @before = before_dir
      @after = after_dir
    end

    def run
      diffs = dir_to_patches(@before, @after)
        .select{|diff| Walker.ruby_file?(diff.a_path)}
      diffs.each do |diff|
        before_path = diff.a_path
        after_path = diff.b_path

        lvar_positions = positions(path: before_path, type: :lvar)
        send_positions = positions(path: after_path, type: :send, &simple_send_node?)

        # OPTIMIZE
        lvar_positions.each do |lvar_pos|
          send_positions.each do |send_pos|
            puts "#{before_path}:#{lvar_pos[:line]}#{lvar_pos[:col]} #{lvar_pos[:name]} is not lvar" if same_position?(lvar_pos, send_pos, patch: 'TODO')
          end
        end
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
    # @param patch [GitDiffParser::Patch]
    def same_position?(a, b, patch:)
      a[:line] == b[:line] &&
        a[:column] == b[:column] &&
        a[:name] == b[:name]
    end

    # @param before [String] a directory
    # @param after [String] a directory
    def dir_to_patches(before, after)
      diff, _stderr, _status = Open3.capture3('git', 'diff', '--no-index', before, after)

      GitDiff.from_string(diff).files
    end

    def simple_send_node?
      lambda do |node|
        recv, _name, *args = *node
        recv.nil? && args.empty?
      end
    end
  end
end

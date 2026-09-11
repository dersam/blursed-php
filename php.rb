require "prism"

class String
  def method_missing(name, ...)
    self + name.to_s
  end

  def call(rhs)
    self + rhs
  end

  def PHP_EOL
    self + "\n"
  end
end

module PHP
  class Exec
    PHP_EOL = "\n"

    def echo(*parts)
      print parts.join                               # echo "a", "b";  (no newline, like PHP)
    end
    def array(*items) = items                         # array(1, 2, 3)
    def isset(x) = !x.nil?                             # isset($x)
    def count(x) = x.size                              # count($x)
    def strlen(s) = s.length
    def implode(glue, xs) = xs.join(glue)             # implode(", ", $x)
    def null; nil; end                                 # null

    def function(input)                               # function greet($who) { return ... }
      name, blk, params = input
      define_singleton_method(:__fn_, &blk)           # block becomes a Method so `return` scopes to it
      fn = method(:__fn_)
      define_singleton_method(name) do |*args, **kwargs|
        params.each_with_index do |param, index|
          value = args[index]
          eval("#{param} = value", binding)
        end
        fn.call
      end
    end

    def method_missing(name, *args, **kwargs, &block)
      return nil if %i(to_a to_hash to_io to_str to_ary to_int).include?(name)

      if block                                         # function greet($who) { ... }
        [name, block, @function_params.fetch(name)] # Fetch the parameters for this function that we parsed earlier
      else
        [name, block]
      end
    end

    def run_file(path)
      src = File.read(path)
      @function_params = collect_function_params(Prism.parse(src).value)
      instance_eval(src, path)
    end

    private

    def collect_function_params(node, functions = {})
      if node.is_a?(Prism::CallNode) && node.name == :function
        declaration = node.arguments&.arguments&.first
        unless declaration.is_a?(Prism::CallNode) && declaration.block
          raise SyntaxError, "unsupported function declaration"
        end

        parameters = declaration.arguments&.arguments || []
        unless parameters.all? { |parameter| parameter.is_a?(Prism::GlobalVariableReadNode) }
          raise SyntaxError, "function parameters must be simple variables"
        end

        functions[declaration.name] = parameters.map(&:name)
      end

      node.compact_child_nodes.each { |child| collect_function_params(child, functions) }
      functions
    end
  end

  # Perform heinous nonsense
  print "#"
  Exec.new.run_file("rb.php")
end

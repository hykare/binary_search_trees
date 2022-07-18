class Node
  attr_accessor :data, :left, :right

  include Comparable

  def initialize(data = nil)
    @data = data
    @left = nil
    @right = nil
  end

  def <=>(other)
    data <=> other.data
  end

  def to_s
    data.to_s
  end

  def preorder(block)
    block.call self
    left&.preorder block
    right&.preorder block
  end

  def inorder(block)
    left&.inorder block
    block.call self
    right&.inorder block
  end

  def postorder(block)
    left&.postorder block
    right&.postorder block
    block.call self
  end

  def height
    return 0 if left.nil? && right.nil?
    return 1 + left.height if right.nil?
    return 1 + right.height if left.nil?

    [1 + left.height, 1 + right.height].max
  end
end

class Tree
  attr_accessor :root

  def initialize(array)
    array = array.uniq.sort
    @root = build_tree(array)
  end

  def build_tree(array)
    return nil if array.empty?

    mid = array.size / 2 # middle or middle-right element
    left_sub_array = array[0..(mid - 1)]
    right_sub_array = array[(mid + 1)..]

    node = Node.new(array[mid])
    node.left = build_tree(left_sub_array) unless mid.zero?
    node.right = build_tree(right_sub_array)
    node
  end

  def height
    root.height
  end

  def depth(node)
    current_node = root
    depth = 0
    until current_node.nil?
      return depth if current_node == node

      current_node = if node < current_node
                       current_node.left
                     else
                       current_node.right
                     end
      depth += 1
    end
    nil
  end

  def rebalance
    values = []
    level_order { |element| values.push(element) }
    initialize(values)
  end

  def balanced?
    level_order.all? { |node| ((node.left&.height || -1) - (node.right&.height || -1)).abs < 2 }

    # level_order.all? do |node|
    #   left_height = node&.left&.height || -1
    #   right_height = node&.right&.height || -1
    #   (left_height - right_height).abs < 2
    # end
  end

  def insert(value)
    node = Node.new(value)
    if root.nil?
      self.root = node
      return node
    end

    current_node = root
    loop do
      if node < current_node
        if current_node.left.nil?
          current_node.left = node
          return
        else
          current_node = current_node.left
        end
      elsif current_node.right.nil?
        current_node.right = node
        return
      else
        current_node = current_node.right
      end
    end
  end

  def insert_arr(arr)
    arr.each { |element| insert(element) }
  end

  def delete(value)
    # find the node and its parent
    node = root
    parent = nil
    is_left_child = nil
    until node.nil?
      break if node.data == value

      parent = node
      if value < node.data
        node = node.left
        is_left_child = true
      else
        node = node.right
        is_left_child = false
      end
    end

    # value is not in tree
    return if node.nil?

    # has 0 or 1 children
    unless node.left && node.right
      child = node.left || node.right

      if node == root
        self.root = child
        return node
      end

      if is_left_child
        parent.left = child
      else
        parent.right = child
      end
      return node
    end

    # has 2 children

    # find the smallest node of right subtree
    replacement_node = node.right
    replacement_parent = node.right
    until replacement_node.left.nil?
      replacement_parent = replacement_node
      replacement_node = replacement_node.left
    end

    # hook up replacement to parent node
    if node == root
      self.root = replacement_node
    elsif is_left_child
      parent.left = replacement_node
    else
      parent.right = replacement_node
    end
    # connect left subtree to replacement
    replacement_node.left = node.left
    # if there were no nodes in between node and its replacement, return
    return node if node.right == replacement_node

    # otherwise connect replacement's possible children to subtree and the subtree to replacement
    replacement_parent.left = replacement_node.right
    replacement_node.right = node.right
    node
  end

  def find(value)
    current_node = root
    until current_node.nil?
      return current_node if value == current_node.data

      current_node = if value < current_node.data
                       current_node.left
                     else
                       current_node.right
                     end
    end
    nil
  end

  # postorder backwards
  def something_nonrecursive
    stack = [root]
    until stack.empty?
      node = stack.pop
      stack.push(node.left) unless node.left.nil?
      stack.push(node.right) unless node.right.nil?
      yield node
    end
  end

  def preorder(&block)
    root.preorder block
  end

  def inorder(&block)
    root.inorder block
  end

  def postorder(&block)
    root.postorder block
  end

  def level_order
    queue = []
    return_array = []
    queue.push root
    until queue.empty?
      node = queue.shift
      return_array << node
      queue.push(node.left) unless node.left.nil?
      queue.push(node.right) unless node.right.nil?
      yield node if block_given?
    end
    return_array
  end

  def pretty_print(node = @root, prefix = '', is_left: true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", is_left: false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", is_left: true) if node.left
  end
end

arr = [7, 5, 6, 4, 10, 8, 9, 11]

tree = Tree.new []
tree.insert_arr arr

puts "height: #{tree.height}"
puts "balanced: #{tree.balanced?}"
tree.pretty_print

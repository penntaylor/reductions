
module Enumerable

  # Returns an Array containing all the intermediate values collected when
  # performing +Enumerable#reduce+. It accepts the same parameters and block
  # as +Enumerable#reduce+, with the addition of the named parameter +use_reduce+
  #
  # *WARNING:* If you have monkey-patched +Enumerable#reduce+, you should pass 
  # +use\_reduce: true+ in the parameter list.
  #
  # @param [Object] init an initial value for the reduction. Just like the one for reduce....
  #
  # @param [Symbol] sym symbol representing a binary operation. Just like the one for reduce....
  #
  # @param [Bool] use_reduce: (named parameter) uses Enumerable#reduce in the
  #               implementation if true. Defaults to false for faster execution.
  #
  # @param [Block] block a block to use instead of a symbol. Just like the one for reduce....
  #
  # @return [Array] the array of intermediate values
  #
  # @example
  #   # These attempt to follow the examples used for Enumerable#reduce
  #
  #   # Sum some numbers
  #   (5..10).reductions(:+)                              # => [5, 11, 18, 26, 35, 45]
  #   # Multiply some numbers
  #   (5..10).reductions(1, :*)                           # => [1, 5, 30, 210, 1680, 15120, 151200]
  #   # Same using a block
  #   (5..10).reductions(1) { |product, n| product * n }  # => [1, 5, 30, 210, 1680, 15120, 151200]
  #   # Force the use of Enumerable#reduce
  #   (5..10).reductions(1, :*, use_reduce: true)         # => [1, 5, 30, 210, 1680, 15120, 151200]
  #
  def reductions(init=nil,sym=nil,use_reduce: false,&block)

    if sym == nil && block == nil && (init.kind_of?(Symbol) || init.kind_of?(String))
      sym = init
      init = nil
    end

    raise LocalJumpError.new("no block given") if !sym && !block

    sz = get_reductions_prealloc_size

    acc = init ? Array.new(sz + 1) : Array.new(sz)

    # Use the slower version if requested
    return reductions2(init: init,sym: sym,acc: acc,&block) if use_reduce

    # Direct access reductions with no initial value are faster than
    # each style reductions with no initial value because the latter
    # are forced to perform a boolean test at each iteration
    direct = self.respond_to?(:[])

    # presence or absence of init changes how we treat index
    # We use +yield+ rather than +block.call+ wherever possible since yield
    # executes with less overhead.
    if block && !init
      if direct
        acc[0] = self[0]
        sz -= 1
        sz.times do |j|
          acc[j+1] = yield(acc[j],self[j+1])
        end
      else
        self.each_with_index do |k,j|
          if j == 0
            acc[0] = k
          else
            acc[j] = yield(acc[j-1],k)
          end
        end
      end

    elsif block && init
      acc[0] = init
      self.each_with_index do |k,j|
        acc[j+1] = yield(acc[j],k)
      end

    elsif !block && !init
      if direct
        acc[0] = self[0]
        sz -= 1
        sz.times do |j|
          acc[j+1] = acc[j].method(sym).call(self[j+1])
        end
      else
        self.each_with_index do |k,j|
          if j == 0
            acc[0] = k
          else
            acc[j] = acc[j-1].method(sym).call(k)
          end
        end
      end

    elsif !block && init
      acc[0] = init
      self.each_with_index do |k,j|
        acc[j+1] = acc[j].method(sym).call(k)
      end
    end

    return acc
  end



  private
  # Returns the allocation size we need for the results.
  def get_reductions_prealloc_size
    if self.respond_to?(:size)
      return self.size
    else
      # Works for any Enumerable, but generally slower than #size
      return self.count
    end
  end


  private
  # Variant of reductions that uses Enumerable#reduce directly in its
  # implementation, while still getting the advantages of result array
  # pre-allocation. Parameter checking and array allocation occurs in
  # #reductions, which then optionally calls this function.
  def reductions2(init: nil,sym: nil, acc: [],&block)

    acc[0] = init if init
    idx = init ? 1 : 0
    iv = [idx,acc]

    if block
      return self.reduce(iv) do |acc,n|
        idx = acc[0]
        v = acc[1]
        if idx == 0
          v[0] = n
        else
          v[idx] = yield(v[idx - 1],n)
        end
        acc[0] = idx + 1
        acc
      end.last
    else
      return self.reduce(iv) do |acc,n|
        idx = acc[0]
        v = acc[1]
        if idx == 0
          v[0] = n
        else
          v[idx] = v[idx - 1].method(sym).call(n)
        end
        acc[0] = idx + 1
        acc
      end.last
    end
  end

end

(1..5).reductions(:+,use_reduce: true)

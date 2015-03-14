#!/usr/bin/env ruby

require 'benchmark'
require 'reductions'

# For comparison purposes, monkey-patch in a naive implementation. Ignore all
# the setup and just look at the two return statements to understand what this
# is doing.
module Enumerable
  def naive_reductions(init=nil,sym=nil,&block)
    if sym == nil && block == nil && (init.kind_of?(Symbol) || init.kind_of?(String))
      sym = init
      init = nil
    end

    raise LocalJumpError.new("no block given") if !sym && !block

    iv = init ? [init] : []
    if block
      return self.reduce(iv){|acc,n| acc += acc.last ? [yield(acc.last,n)] : [n]}
    else
      return self.reduce(iv){|acc,n| acc += acc.last ? [acc.last.method(sym).call(n)] : [n]}
    end
  end
end


# And now the benchmarking:

br = (1..100000)
ba = br.to_a

Benchmark.bmbm(29) do |b|
  b.report('100K reduce') {ba.reduce{|a,n| a + n}}
  b.report('100K reductions direct access') {ba.reductions{|a,n| a + n}}
  b.report('100K reductions each-style') {br.reductions{|a,n| a + n}}
  b.report('100K reductions use_reduce') {br.reductions(use_reduce: true){|a,n| a + n}}
  b.report('100K naive reductions') {br.naive_reductions{|a,n| a + n}}
end

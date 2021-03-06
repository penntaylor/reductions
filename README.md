Reductions
==========

Reductions is an addition to Ruby's Enumerable module that returns
an array containing all of the intermediate values that would be
generated in a call to Enumerable#reduce.

Installation
============

`gem install reductions`

Usage
=====

    require 'reductions'

    (5..10).reductions(:+)           # => [5, 11, 18, 26, 35, 45]
    (5..10).reductions{|a,b| a + b}  # => [5, 11, 18, 26, 35, 45]

    # (5..10).reduce(:+)  would result in 45

**If you have monkey-patched Enumerable#reduce** and need to
ensure #reductions works according to your patched #reduce, pass
`use_reduce: true` to reductions:

    (5..10).reductions(:+,use_reduce: true)
    (5..10).reductions(use_reduce: true){|a,b| a + b}

Using this flag increases the required execution time. See Benchmarking
section for performance difference.


Why a gem for this?
-------------------

You _could_ just provide a block to Enumerable#reduce that does the same
thing:

    (5..10).reduce([]){|acc,n| acc += acc.last ? [acc.last + n] : [n] }

However, a gem is preferable for two key reasons:

*  It allows for more compact, more understandable code. Compare the above with
   `(5..10).reductions(:+)`.
*  There are significant performance problems with the "provide a block to reduce"
   approach once you get into reductions with tens of thousands of elements. See
   "naïve reductions" in the Benchmarking section.


Benchmarking
------------
The case being benchmarked here is `(1..100000).reductions{|a,b| a + b}`

                                   user     system      total        real
    reduce                     0.010000   0.000000   0.010000 (  0.017606)
    reductions                 0.040000   0.000000   0.040000 (  0.036335)
    reductions use_reduce      0.050000   0.000000   0.050000 (  0.051783)
    naïve reductions          15.190000   0.530000  15.720000 ( 15.699648)

* `reduce` is a plain #reduce, included here to give a reference point for performance.
* `reductions` is the reduction using the exact case shown above.
    Notice the full reduction --which returns an array
    with 100,000 entries-- took only **~2** times as long as a plain reduce!
* `reductions use_reduce` is the reduction with the `use_reduce` flag set to
    true. This reduction uses #reduce in its implementation.
* `naïve reductions` is the reduction using reduce as shown in the "Why a gem for this?"
    section. The large number of incremental Array allocations makes
    it _really_ slow, in this case taking more than 400 times as long
    as the `reductions` version.

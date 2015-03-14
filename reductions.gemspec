Gem::Specification.new do |s|
  s.name        = 'reductions'
  s.version     = '0.1.0'
  s.date        = '2015-03-13'
  s.summary     = "Adds reductions capability to Enumerable"
  s.description = <<-END
    Reductions is an addition to Enumerable that returns
    an array containing all of the intermediate values that would
    be generated in a call to Enumerable#reduce.

    (5..10).reductions(:+)    # => [5, 11, 18, 26, 35, 45]
  END
  s.author      = "Penn Taylor"
  s.email       = 'rpenn3@gmail.com'
  s.files       =  ['lib/reductions.rb', 
                    'README.md',
                    'benchmarks/run_benchmarks.rb',
                   'tests/unit_tests.rb'] 
  s.homepage    = 'https://github.com/penntaylor/reductions'
  s.license     = 'MIT'
end

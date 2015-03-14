#!/usr/bin/env ruby

require 'minitest/autorun'
require 'reductions'

class TestReductions < Minitest::Test

  def test_simple_block_reduction_esr
    assert_equal [1,3,6,10,15], (1..5).reductions{|a,b| a + b}
  end

  def test_simple_block_reduction_dar
    assert_equal [1,3,6,10,15], (1..5).to_a.reductions{|a,b| a + b}
  end

  def test_simple_block_reduction2
    assert_equal [1,3,6,10,15], (1..5).reductions(use_reduce: true){|a,b| a + b}
  end

  def test_simple_sym_reduction_esr
    assert_equal [1,3,6,10,15], (1..5).reductions(:+)
  end

  def test_simple_sym_reduction_dar
    assert_equal [1,3,6,10,15], (1..5).to_a.reductions(:+)
  end

  def test_simple_sym_reduction2
    assert_equal [1,3,6,10,15], (1..5).reductions(:+,use_reduce: true)
  end

  def test_simple_string_reduction_esr
    assert_equal [1,3,6,10,15], (1..5).reductions('+')
  end

  def test_simple_string_reduction_dar
    assert_equal [1,3,6,10,15], (1..5).to_a.reductions('+')
  end

  def test_simple_string_reduction2
    assert_equal [1,3,6,10,15], (1..5).reductions('+',use_reduce: true)
  end

  def test_init_block_reduction_esr
    assert_equal [2,3,5,8,12,17], (1..5).reductions(2){|a,b| a + b}
  end

  def test_init_block_reduction_dar
    assert_equal [2,3,5,8,12,17], (1..5).to_a.reductions(2){|a,b| a + b}
  end

  def test_init_block_reduction2
    assert_equal [2,3,5,8,12,17], (1..5).reductions(2,use_reduce: true){|a,b| a + b}
  end

  def test_init_sym_reduction_esr
    assert_equal [2,3,5,8,12,17], (1..5).reductions(2,:+)
  end

  def test_init_sym_reduction_dar
    assert_equal [2,3,5,8,12,17], (1..5).to_a.reductions(2,:+)
  end

  def test_init_sym_reduction2
    assert_equal [2,3,5,8,12,17], (1..5).reductions(2,:+,use_reduce: true)
  end

  def test_raises_no_block
    assert_raises(LocalJumpError){ (1..5).reductions }
  end

end

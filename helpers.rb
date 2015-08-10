require 'binding_of_caller'

module Hacks
  def self.caller_object(num=0)
    binding.of_caller(2+num).eval('self')
  end
end
  end
end

class Proc
  def << block
    proc { |*args| self.call( block.to_proc.call(*args) ) }
  end
end

class Object
  def enum_func
    binding.of_caller(1).eval('return enum_for(__method__) unless block_given?')
  end

  def use
    yield self
  end
end

module Enumerable
  def eager
    enum_func
    self.to_a.each do |a|
      yield a
    end
  end
end

class Array
  def delete_first(obj)
    self.delete_at(self.index(obj))
  end

  def find_object
    self.each do |x|
      if yield x then return x end
    end
    return nil
  end

  def neighborhood
    ret = []
    (-1..1).each do |i|
      (-1..1).each do |j|
        ret << [self[0]+i, self[1]+j]
      end
    end
    return ret
  end

  def move(dir, amt)
    ret = self.dup
    a = (dir == 'x' ? 0 : 1)
    ret[a]+=amt
    return ret
  end

  def partition
    ret = []
    yret = []
    self.each do |x|
      yx = yield x
      if not
        yret.map.with_index do |r, i|
          if r == yx
            ret[i] << x
            true
          else
            false
          end
        end.any?
      then
        ret << [x]
        yret << yx
      end
    end
    return ret
  end
end

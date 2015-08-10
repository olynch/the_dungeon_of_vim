require 'binding_of_caller'

module Hacks
  def self.caller_object(num=0)
    binding.of_caller(2+num).eval('self')
  end
end

module DynamicBinding
  class LookupStack
    def initialize(bindings = [])
      @bindings = bindings
    end

    def method_missing(m, *args)
      @bindings.reverse_each do |bind|
        begin
          method = eval("method(%s)" % m.inspect, bind)
        rescue NameError
        else
          return method.call(*args)
        end
        begin
          value = eval(m.to_s, bind)
          return value
        rescue NameError
        end
      end
      raise NoMethodError, "No such variable or method: %s" % m
    end

    def pop_binding
      @bindings.pop
    end

    def push_binding(bind)
      @bindings.push bind
    end

    def push_instance(obj)
      @bindings.push obj.instance_eval { binding }
    end

    def push_hash(vars)
      push_instance Struct.new(*vars.keys).new(*vars.values)
    end

    def get_binding
      instance_eval { binding }
    end

    def run_proc(p, *args)
      instance_exec(*args, &p)
    end

    def push_method(name, p, obj=nil)
      x = Object.new
      singleton = class << x; self; end
      singleton.send(:define_method, name, lambda { |*args|
        obj.instance_exec(*args, &p)
      })
      push_instance x
    end
  end
end

class Proc
  def call_with_binding(bind, *args)
    DynamicBinding::LookupStack.new([bind]).run_proc(self, *args)
  end

  def << block
    s = self
    proc {|*args| instance_exec(instance_exec(*args, &block), &s)}
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

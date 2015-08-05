require 'pry.rb'
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
binding.pry

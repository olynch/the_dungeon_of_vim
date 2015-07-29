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
  end
end

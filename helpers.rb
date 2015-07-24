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
end

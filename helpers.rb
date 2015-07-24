class Array
  def delete_first(obj)
    self.delete_at(self.index(obj))
  end
end

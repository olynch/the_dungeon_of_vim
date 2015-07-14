module Hacks
  require 'binding_of_caller'
  def self.caller_object
    binding.of_caller(2).eval('self')
  end
end

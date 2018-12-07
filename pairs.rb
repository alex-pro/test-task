class Array
  def pairs(target_value)
    store = {}
    result = []
    self.each_with_index do |element, index|
      key = store.key(target_value - element)
      if key
        result << [store[key], element]
        store.delete(key)
      else
        store[index] = element
      end
    end
    result
  end
end

p [1,3,5,4,6,0,2,-1].pairs(4)
p [1,3,1].pairs(4)
p [1,3,3,3,3,1,1].pairs(4)

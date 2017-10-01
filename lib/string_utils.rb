class String
  def include_one_of?(*array)
    array.flatten.each do |str|
      return true if self.include?(str)
    end
    return false
  end
  def capitalize_first
    self.slice(0,1).capitalize + self.slice(1..-1)
  end
  def capitalize_first!
    self.replace(self.capitalize_first)
  end
  def lowercase_first
    str = to_s
    str[0,1].downcase + str[1..-1]
  end
  def delete_last_path_component!
    self.replace(self.split(File::SEPARATOR)[0..-2].join(File::SEPARATOR))
  end
  def delete_last_path_component
    self.split(File::SEPARATOR)[0..-2].join(File::SEPARATOR)
  end
end
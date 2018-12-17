

def gena_system(*args)
  if $verbose
    system *args
  else
    system *args, :out => ['/dev/null', 'a'], :err => ['/dev/null', 'a']
  end
end

class String
  def include_one_of?(*array)
    array.flatten.each do |str|
      return true if self.include?(str)
    end
    false
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
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
  end
  def path_intersection(other)
    component_start = 0
    (0..[other.size, self.size].min).each { |i|

      if self[i] == '/'
        component_start = i
      end

      if self[i] != other[i]
        if i > 0
          return self[0..component_start]
        else
          return ''
        end
      end
    }
    self
  end

  def delete_last_path_component
    self.split(File::SEPARATOR)[0..-2].join(File::SEPARATOR)
  end
end

def common_path(paths)
  common = ''
  paths.each do |file|
    path_components = file.to_s
    if common.empty?
      common = path_components
    else
      common = common.path_intersection path_components
    end
  end

  if File.file? common
    common = common.delete_last_path_component
  end
  if common[-1] == '/'
    common = common[0..-2]
  end
  common
end

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end
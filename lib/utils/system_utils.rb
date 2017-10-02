

def gena_system(*args)
  if $verbose
    system *args
  else
    system *args, :out => ['/dev/null', 'a'], :err => ['/dev/null', 'a']
  end
end
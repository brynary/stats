class Memcached
  
  def decrement(key, offset=1)
  end
  
  def increment(key, offset=1)
  end
  
  def replace(key, value, timeout=0, marshal=true)
  end
  
  def prepend(key, value)
  end
  
  def append(key, value)
  end
  
  def delete(key)
  end
  
  def set(key, value, timeout=0, marshal=true)
  end
  
  def add(key, value, timeout=0, marshal=true)
  end
  
  def get(keys, marshal=true)
  end

  class NotFound < StandardError
  end

end
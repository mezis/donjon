module Kernel
  def assert(condition, message = nil, error: RuntimeError)
    return if condition
    raise error.new(message || 'assertion failed')
  end
end

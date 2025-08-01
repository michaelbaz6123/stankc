class TypeError < Exception
  def to_s
    "TypeError : #{@message}"
  end

  def put_backtrace
    backtrace.each do |ln| puts ln end
  end
end
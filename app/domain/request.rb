class Request < Struct.new(:verb, :path, :output, :status)
  def verify
  end
end

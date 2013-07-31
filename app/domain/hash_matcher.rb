class HashMatcher < Struct.new(:hash)
  def to_json(options={})
    hash.to_json
  end

  def as_json(options={})
    hash.as_json
  end

  def ===(other)
    other && other.kind_of?(Hash) && hash.all? do |key, value|
      value === other[key.to_s]
    end
  end
end

class IntMatcher
  def ===(other)
    other.kind_of?(Integer)
  end

  def as_json(options={})
    "[an integer]"
  end
end

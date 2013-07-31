module Examples
  extend Enumerable

  def self.shuffle
    examples.shuffle
  end

  def self.each
    examples.each { |example| yield example }
  end

  def self.register(&block)
    examples << Example.new(block)
  end

  def self.examples
    @examples ||= []
  end
  private_class_method :examples
end

require File.join(Rails.root, "app", "domain", "examples", "basic.rb")
require File.join(Rails.root, "app", "domain", "examples", "hard.rb")

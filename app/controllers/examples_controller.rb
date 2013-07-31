class ExamplesController < ApplicationController
  def index
    @descriptions = Examples.map(&:describe)
  end
end

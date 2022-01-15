# frozen_string_literal: true

GREEN = "\e[32m"
RED = "\e[31m"
RESET = "\e[0m"

def describe(_description, &block)
  block.call
end

def it(description, &block)
  $stdout.write "Example #{description}: "
  block.call
  puts "#{GREEN}(Passed)#{RESET}"
rescue StandardError => e
  puts 'Failed!!!'
  puts [e.backtrace.reverse, e].flatten
                               .map { |line| "\t#{line}" }
                               .join("\n")
end

def expect(actual)
  Actual.new(actual)
end

def eq(expected)
  Expectation::Equal.new(expected)
end

module Expectation
  class Equal
    def initialize(expected)
      @expected = expected
    end

    def run(actual)
      raise AssertionError, "Expected #{expected.inspect} but got #{actual.inspect}" unless actual == expected
    end

    private

    attr_reader :expected
  end
end

class Actual
  def initialize(actual)
    @actual = actual
  end

  def to(expectation)
    expectation.run(@actual)
  end

  attr_reader :actual
end

class AssertionError < RuntimeError; end

# class ComparisonAssertion
#   def initialize(actual)
#     @actual = actual
#   end

#   def ==(other)
#     raise AssertionError, "Expected #{other.inspect} but got #{actual.inspect}" unless actual == other
#   end

#   private

#   attr_reader :actual
# end

class Object
  def should
    ComparisonAssertion.new(self)
  end
end

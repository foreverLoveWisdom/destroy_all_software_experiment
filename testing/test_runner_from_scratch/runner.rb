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

def expect(actual = nil, &block)
  Actual.new(actual || block)
end

def eq(expected_value)
  Expectations::Equal.new(expected_value)
end

def raise_error(exception_class)
  Expectations::Error.new(exception_class)
end

module Expectations
  class Equal
    def initialize(expected_value)
      @expected_value = expected_value
    end

    def run(actual)
      unless actual == expected_value
        raise AssertionError,
              "Expected #{expected_value.inspect} but got #{actual.inspect}"
      end
    end

    private

    attr_reader :expected_value
  end

  class Error
    def initialize(exception_class)
      @exception_class = exception_class
    end

    def run(actual_block)
      actual_block.call
    rescue exception_class
      nil
    rescue StandardError => e
      raise AssertionError, format('Expected to see error %s, but saw %s', exception_class.inspect, e.inspect)
    end

    private

    attr_reader :exception_class
  end
end

class Actual
  def initialize(actual)
    @actual = actual
  end

  def to(expected_expectation)
    expected_expectation.run(actual)
  end

  attr_reader :actual
end

class AssertionError < RuntimeError; end

class ComparisonAssertion
  def initialize(actual)
    @actual = actual
  end

  def ==(other)
    raise AssertionError, "Expected #{other.inspect} but got #{actual.inspect}" unless actual == other
  end

  private

  attr_reader :actual
end

class Object
  def should
    ComparisonAssertion.new(self)
  end
end

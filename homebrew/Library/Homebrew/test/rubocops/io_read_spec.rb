# typed: false
# frozen_string_literal: true

require "rubocops/io_read"

describe RuboCop::Cop::Homebrew::IORead do
  subject(:cop) { described_class.new }

  it "reports an offense when `IO.read` is used with a pipe character" do
    expect_offense(<<~RUBY)
      IO.read("|echo test")
      ^^^^^^^^^^^^^^^^^^^^^ The use of `IO.read` is a security risk.
    RUBY
  end

  it "does not report an offense when `IO.read` is used without a pipe character" do
    expect_no_offenses(<<~RUBY)
      IO.read("file.txt")
    RUBY
  end

  it "reports an offense when `IO.read` is used with untrustworthy input" do
    expect_offense(<<~RUBY)
      input = "input value from an unknown source"
      IO.read(input)
      ^^^^^^^^^^^^^^ The use of `IO.read` is a security risk.
    RUBY
  end

  it "reports an offense when `IO.read` is used with a dynamic string starting with a pipe character" do
    expect_offense(<<~'RUBY')
      input = "test"
      IO.read("|echo #{input}")
      ^^^^^^^^^^^^^^^^^^^^^^^^^ The use of `IO.read` is a security risk.
    RUBY
  end

  it "reports an offense when `IO.read` is used with a dynamic string at the start" do
    expect_offense(<<~'RUBY')
      input = "|echo test"
      IO.read("#{input}.txt")
      ^^^^^^^^^^^^^^^^^^^^^^^ The use of `IO.read` is a security risk.
    RUBY
  end

  it "does not report an offense when `IO.read` is used with a dynamic string safely" do
    expect_no_offenses(<<~'RUBY')
      input = "test"
      IO.read("somefile#{input}.txt")
    RUBY
  end

  it "reports an offense when `IO.read` is used with a concatenated string starting with a pipe character" do
    expect_offense(<<~'RUBY')
      input = "|echo test"
      IO.read("|echo " + input)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ The use of `IO.read` is a security risk.
    RUBY
  end

  it "reports an offense when `IO.read` is used with a concatenated string starting with untrustworthy input" do
    expect_offense(<<~'RUBY')
      input = "|echo test"
      IO.read(input + ".txt")
      ^^^^^^^^^^^^^^^^^^^^^^^ The use of `IO.read` is a security risk.
    RUBY
  end

  it "does not report an offense when `IO.read` is used with a concatenated string safely" do
    expect_no_offenses(<<~'RUBY')
      input = "test"
      IO.read("somefile" + input + ".txt")
    RUBY
  end
end

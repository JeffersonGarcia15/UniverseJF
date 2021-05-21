# typed: false
# frozen_string_literal: true

require "rubocops/lines"

describe RuboCop::Cop::FormulaAudit::AssertStatements do
  subject(:cop) { described_class.new }

  context "when auditing formula assertions" do
    it "reports an offense when assert ... include is used" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url 'https://brew.sh/foo-1.0.tgz'
          assert File.read("inbox").include?("Sample message 1")
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `assert_match` instead of `assert ...include?`
        end
      RUBY
    end

    it "reports an offense when assert ... exist? is used without a negation" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url 'https://brew.sh/foo-1.0.tgz'
          assert File.exist? "default.ini"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `assert_predicate <path_to_file>, :exist?` instead of `assert File.exist? "default.ini"`
        end
      RUBY
    end

    it "reports an offense when assert ... exist? is used with a negation" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url 'https://brew.sh/foo-1.0.tgz'
          assert !File.exist?("default.ini")
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `refute_predicate <path_to_file>, :exist?` instead of `assert !File.exist?("default.ini")`
        end
      RUBY
    end

    it "reports an offense when assert ... executable? is used without a negation" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          desc "foo"
          url 'https://brew.sh/foo-1.0.tgz'
          assert File.executable? f
                 ^^^^^^^^^^^^^^^^^^ Use `assert_predicate <path_to_file>, :executable?` instead of `assert File.executable? f`
        end
      RUBY
    end
  end
end

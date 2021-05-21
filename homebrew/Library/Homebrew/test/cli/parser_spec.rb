# typed: false
# frozen_string_literal: true

require_relative "../../cli/parser"

describe Homebrew::CLI::Parser do
  describe "test switch options" do
    subject(:parser) {
      described_class.new do
        switch "--more-verbose", description: "Flag for higher verbosity"
        switch "--pry", env: :pry
      end
    }

    before do
      allow(Homebrew::EnvConfig).to receive(:pry?).and_return(true)
    end

    context "when using binary options" do
      subject(:parser) {
        described_class.new do
          switch "--[no-]positive"
        end
      }

      it "does not create no_positive?" do
        args = parser.parse(["--no-positive"])
        expect { args.no_positive? }.to raise_error(NoMethodError)
      end

      it "sets the positive name to false if the negative flag is passed" do
        args = parser.parse(["--no-positive"])
        expect(args).not_to be_positive
      end

      it "sets the positive name to true if the positive flag is passed" do
        args = parser.parse(["--positive"])
        expect(args).to be_positive
      end

      it "does not set the positive name if the positive flag is not passed" do
        args = parser.parse([])
        expect(args.positive?).to be nil
      end
    end

    context "when using negative options" do
      subject(:parser) {
        described_class.new do
          switch "--no-positive"
        end
      }

      it "does not set the positive name" do
        args = parser.parse(["--no-positive"])
        expect { args.positive? }.to raise_error(NoMethodError)
      end

      it "fails when using the positive name" do
        expect {
          parser.parse(["--positive"])
        }.to raise_error(/invalid option/)
      end

      it "sets the negative name to true if the negative flag is passed" do
        args = parser.parse(["--no-positive"])
        expect(args.no_positive?).to be true
      end
    end

    context "when `ignore_invalid_options` is true" do
      it "passes through invalid options" do
        args = parser.parse(["-v", "named-arg", "--not-a-valid-option"], ignore_invalid_options: true)
        expect(args.remaining).to eq ["named-arg", "--not-a-valid-option"]
        expect(args.named).to be_empty
      end
    end

    it "parses short option" do
      args = parser.parse(["-v"])
      expect(args).to be_verbose
    end

    it "parses a single valid option" do
      args = parser.parse(["--verbose"])
      expect(args).to be_verbose
    end

    it "parses a valid option along with few unnamed args" do
      args = parser.parse(%w[--verbose unnamed args])
      expect(args).to be_verbose
      expect(args.named).to eq %w[unnamed args]
    end

    it "parses a single option and checks other options to be false" do
      args = parser.parse(["--verbose"])
      expect(args).to be_verbose
      expect(args.more_verbose?).to be false
    end

    it "raises an exception and outputs help text when an invalid option is passed" do
      expect { parser.parse(["--random"]) }.to raise_error(OptionParser::InvalidOption, /--random/)
                                           .and output(/Usage: brew/).to_stderr
    end

    it "maps environment var to an option" do
      args = parser.parse([])
      expect(args.pry?).to be true
    end
  end

  describe "test long flag options" do
    subject(:parser) {
      described_class.new do
        flag        "--filename=", description: "Name of the file"
        comma_array "--files",     description: "Comma separated filenames"
      end
    }

    it "parses a long flag option with its argument" do
      args = parser.parse(["--filename=random.txt"])
      expect(args.filename).to eq "random.txt"
    end

    it "raises an exception when a flag's required value is not passed" do
      expect { parser.parse(["--filename"]) }.to raise_error(OptionParser::MissingArgument, /--filename/)
    end

    it "parses a comma array flag option" do
      args = parser.parse(["--files=random1.txt,random2.txt"])
      expect(args.files).to eq %w[random1.txt random2.txt]
    end
  end

  describe "test short flag options" do
    subject(:parser) {
      described_class.new do
        flag "-f", "--filename=", description: "Name of the file"
      end
    }

    it "parses a short flag option with its argument" do
      args = parser.parse(["--filename=random.txt"])
      expect(args.filename).to eq "random.txt"
      expect(args.f).to eq "random.txt"
    end
  end

  describe "test constraints for flag options" do
    subject(:parser) {
      described_class.new do
        flag      "--flag1="
        flag      "--flag3="
        flag      "--flag2=", required_for: "--flag1="
        flag      "--flag4=", depends_on: "--flag3="

        conflicts "--flag1=", "--flag3="
      end
    }

    it "raises exception on required_for constraint violation" do
      expect { parser.parse(["--flag1=flag1"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception on depends_on constraint violation" do
      expect { parser.parse(["--flag2=flag2"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
      expect { parser.parse(["--flag4=flag4"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception for conflict violation" do
      expect { parser.parse(["--flag1=flag1", "--flag3=flag3"]) }.to raise_error(Homebrew::CLI::OptionConflictError)
    end

    it "raises no exception" do
      args = parser.parse(["--flag1=flag1", "--flag2=flag2"])
      expect(args.flag1).to eq "flag1"
      expect(args.flag2).to eq "flag2"
    end

    it "raises no exception for optional dependency" do
      args = parser.parse(["--flag3=flag3"])
      expect(args.flag3).to eq "flag3"
    end
  end

  describe "test invalid constraints" do
    subject(:parser) {
      described_class.new do
        flag      "--flag1="
        flag      "--flag2=", depends_on: "--flag1="
        conflicts "--flag1=", "--flag2="
      end
    }

    it "raises exception due to invalid constraints" do
      expect { parser.parse([]) }.to raise_error(Homebrew::CLI::InvalidConstraintError)
    end
  end

  describe "test constraints for switch options" do
    subject(:parser) {
      described_class.new do
        switch      "-a", "--switch-a", env: "switch_a"
        switch      "-b", "--switch-b", env: "switch_b"
        switch      "--switch-c", required_for: "--switch-a"
        switch      "--switch-d", depends_on: "--switch-b"

        conflicts "--switch-a", "--switch-b"
      end
    }

    it "raises exception on required_for constraint violation" do
      expect { parser.parse(["--switch-a"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception on depends_on constraint violation" do
      expect { parser.parse(["--switch-c"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
      expect { parser.parse(["--switch-d"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception for conflict violation" do
      expect { parser.parse(["-ab"]) }.to raise_error(Homebrew::CLI::OptionConflictError)
    end

    it "raises no exception" do
      args = parser.parse(["--switch-a", "--switch-c"])
      expect(args.switch_a?).to be true
      expect(args.switch_c?).to be true
    end

    it "raises no exception for optional dependency" do
      args = parser.parse(["--switch-b"])
      expect(args.switch_b?).to be true
    end

    it "prioritizes cli arguments over env vars when they conflict" do
      allow(Homebrew::EnvConfig).to receive(:switch_a?).and_return(true)
      allow(Homebrew::EnvConfig).to receive(:switch_b?).and_return(false)
      args = parser.parse(["--switch-b"])
      expect(args.switch_a?).to be false
      expect(args).to be_switch_b
    end

    it "raises an exception on constraint violation when both are env vars" do
      allow(Homebrew::EnvConfig).to receive(:switch_a?).and_return(true)
      allow(Homebrew::EnvConfig).to receive(:switch_b?).and_return(true)
      expect { parser.parse([]) }.to raise_error(Homebrew::CLI::OptionConflictError)
    end
  end

  describe "test immutability of args" do
    subject(:parser) {
      described_class.new do
        switch "-a", "--switch-a"
        switch "-b", "--switch-b"
      end
    }

    it "raises exception when arguments were already parsed" do
      parser.parse(["--switch-a"])
      expect { parser.parse(["--switch-b"]) }.to raise_error(RuntimeError, /Arguments were already parsed!/)
    end
  end

  describe "test inferrability of args" do
    subject(:parser) {
      described_class.new do
        switch "--switch-a"
        switch "--switch-b"
        switch "--foo-switch"
        flag "--flag-foo="
        comma_array "--comma-array-foo"
      end
    }

    it "parses a valid switch that uses `_` instead of `-`" do
      args = parser.parse(["--switch_a"])
      expect(args).to be_switch_a
    end

    it "parses a valid flag that uses `_` instead of `-`" do
      args = parser.parse(["--flag_foo=foo.txt"])
      expect(args.flag_foo).to eq "foo.txt"
    end

    it "parses a valid comma_array that uses `_` instead of `-`" do
      args = parser.parse(["--comma_array_foo=foo.txt,bar.txt"])
      expect(args.comma_array_foo).to eq %w[foo.txt bar.txt]
    end

    it "raises an error when option is ambiguous" do
      expect { parser.parse(["--switch"]) }.to raise_error(RuntimeError, /ambiguous option: --switch/)
    end

    it "inferrs the option from an abbreviated name" do
      args = parser.parse(["--foo"])
      expect(args).to be_foo_switch
    end
  end

  describe "test argv extensions" do
    subject(:parser) {
      described_class.new do
        switch "--foo"
        flag   "--bar"
        switch "-s"
      end
    }

    it "#options_only" do
      args = parser.parse(["--foo", "--bar=value", "-v", "-s", "a", "b", "cdefg"])
      expect(args.options_only).to eq %w[--verbose --foo --bar=value -s]
    end

    it "#flags_only" do
      args = parser.parse(["--foo", "--bar=value", "-v", "-s", "a", "b", "cdefg"])
      expect(args.flags_only).to eq %w[--verbose --foo --bar=value]
    end

    it "#named returns an array of non-option arguments" do
      args = parser.parse(["foo", "-v", "-s"])
      expect(args.named).to eq ["foo"]
    end

    it "#named returns an empty array when there are no named arguments" do
      args = parser.parse([])
      expect(args.named).to be_empty
    end
  end

  describe "usage banner generation" do
    it "includes `[options]` if more than two non-global options are available" do
      parser = described_class.new do
        switch "--foo"
        switch "--baz"
        switch "--bar"
      end
      expect(parser.generate_help_text).to match(/\[options\]/)
    end

    it "includes individual options if less than two non-global options are available" do
      parser = described_class.new do
        switch "--foo"
        switch "--bar"
      end
      expect(parser.generate_help_text).to match(/\[--foo\] \[--bar\]/)
    end

    it "formats flags correctly when less than two non-global options are available" do
      parser = described_class.new do
        flag "--foo"
        flag "--bar="
      end
      expect(parser.generate_help_text).to match(/\[--foo\] \[--bar=\]/)
    end

    it "formats comma arrays correctly when less than two non-global options are available" do
      parser = described_class.new do
        comma_array "--foo"
      end
      expect(parser.generate_help_text).to match(/\[--foo=\]/)
    end

    it "doesn't include `[options]` if non non-global options are available" do
      parser = described_class.new
      expect(parser.generate_help_text).not_to match(/\[options\]/)
    end

    it "includes a description" do
      parser = described_class.new do
        description <<~EOS
          This command does something
        EOS
      end
      expect(parser.generate_help_text).to match(/This command does something/)
    end

    it "allows the usage banner to be overridden" do
      parser = described_class.new do
        usage_banner "`test` [foo] <bar>"
      end
      expect(parser.generate_help_text).to match(/test \[foo\] bar/)
    end

    it "allows a usage banner and a description to be overridden" do
      parser = described_class.new do
        usage_banner "`test` [foo] <bar>"
        description <<~EOS
          This command does something
        EOS
      end
      expect(parser.generate_help_text).to match(/test \[foo\] bar/)
      expect(parser.generate_help_text).to match(/This command does something/)
    end

    it "shows the correct usage for no named argument" do
      parser = described_class.new do
        named_args :none
      end
      expect(parser.generate_help_text).to match(/^Usage: [^\[]+$/s)
    end

    it "shows the correct usage for a single typed argument" do
      parser = described_class.new do
        named_args :formula, number: 1
      end
      expect(parser.generate_help_text).to match(/^Usage: .* formula$/s)
    end

    it "shows the correct usage for a subcommand argument with a maximum" do
      parser = described_class.new do
        named_args %w[off on], max: 1
      end
      expect(parser.generate_help_text).to match(/^Usage: .* \[subcommand\]$/s)
    end

    it "shows the correct usage for multiple typed argument with no maximum or minimum" do
      parser = described_class.new do
        named_args [:tap, :command]
      end
      expect(parser.generate_help_text).to match(/^Usage: .* \[tap|command ...\]$/s)
    end

    it "shows the correct usage for a subcommand argument with a minimum of 1" do
      parser = described_class.new do
        named_args :installed_formula, min: 1
      end
      expect(parser.generate_help_text).to match(/^Usage: .* installed_formula \[...\]$/s)
    end

    it "shows the correct usage for a subcommand argument with a minimum greater than 1" do
      parser = described_class.new do
        named_args :installed_formula, min: 2
      end
      expect(parser.generate_help_text).to match(/^Usage: .* installed_formula ...$/s)
    end
  end

  describe "named_args" do
    let(:parser_none) {
      described_class.new do
        named_args :none
      end
    }
    let(:parser_number) {
      described_class.new do
        named_args number: 1
      end
    }

    it "doesn't allow :none passed with a number" do
      expect do
        described_class.new do
          named_args :none, number: 1
        end
      end.to raise_error(ArgumentError, /Do not specify both `number`, `min` or `max` with `named_args :none`/)
    end

    it "doesn't allow number and min" do
      expect do
        described_class.new do
          named_args number: 1, min: 1
        end
      end.to raise_error(ArgumentError, /Do not specify both `number` and `min` or `max`/)
    end

    it "doesn't accept fewer than the passed number of arguments" do
      expect { parser_number.parse([]) }.to raise_error(Homebrew::CLI::NumberOfNamedArgumentsError)
    end

    it "doesn't accept more than the passed number of arguments" do
      expect { parser_number.parse(["foo", "bar"]) }.to raise_error(Homebrew::CLI::NumberOfNamedArgumentsError)
    end

    it "accepts the passed number of arguments" do
      expect { parser_number.parse(["foo"]) }.not_to raise_error
    end

    it "doesn't accept any arguments with :none" do
      expect { parser_none.parse(["foo"]) }
        .to raise_error(Homebrew::CLI::MaxNamedArgumentsError, /This command does not take named arguments/)
    end

    it "accepts no arguments with :none" do
      expect { parser_none.parse([]) }.not_to raise_error
    end

    it "displays the correct error message with no arg types and min" do
      parser = described_class.new do
        named_args min: 2
      end
      expect { parser.parse([]) }.to raise_error(
        Homebrew::CLI::MinNamedArgumentsError, /This command requires at least 2 named arguments/
      )
    end

    it "displays the correct error message with no arg types and number" do
      parser = described_class.new do
        named_args number: 2
      end
      expect { parser.parse([]) }.to raise_error(
        Homebrew::CLI::NumberOfNamedArgumentsError, /This command requires exactly 2 named arguments/
      )
    end

    it "displays the correct error message with no arg types and max" do
      parser = described_class.new do
        named_args max: 1
      end
      expect { parser.parse(%w[foo bar]) }.to raise_error(
        Homebrew::CLI::MaxNamedArgumentsError, /This command does not take more than 1 named argument/
      )
    end

    it "displays the correct error message with an array of strings" do
      parser = described_class.new do
        named_args %w[on off], number: 1
      end
      expect { parser.parse([]) }.to raise_error(
        Homebrew::CLI::NumberOfNamedArgumentsError, /This command requires exactly 1 subcommand/
      )
    end

    it "displays the correct error message with an array of symbols" do
      parser = described_class.new do
        named_args [:formula, :cask], min: 1
      end
      expect { parser.parse([]) }.to raise_error(
        Homebrew::CLI::MinNamedArgumentsError, /This command requires at least 1 formula or cask argument/
      )
    end

    it "displays the correct error message with an array of symbols and max" do
      parser = described_class.new do
        named_args [:formula, :cask], max: 1
      end
      expect { parser.parse(%w[foo bar]) }.to raise_error(
        Homebrew::CLI::MaxNamedArgumentsError, /This command does not take more than 1 formula or cask argument/
      )
    end
  end
end

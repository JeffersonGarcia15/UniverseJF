# typed: true
# frozen_string_literal: true

require "cli/parser"
require "release_notes"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def release_notes_args
    Homebrew::CLI::Parser.new do
      usage_banner "`release-notes` [<options>] [<previous_tag>] [<end_ref>]"
      description <<~EOS
        Print the merged pull requests on Homebrew/brew between two Git refs.
        If no <previous_tag> is provided it defaults to the latest tag.
        If no <end_ref> is provided it defaults to `origin/master`.

        If `--markdown` and a <previous_tag> are passed, an extra line containing
        a link to the Homebrew blog will be adding to the output. Additionally,
        a warning will be shown if the latest minor release was less than one month ago.
      EOS
      switch "--markdown",
             description: "Print as a Markdown list."

      named_args max: 2

      hide_from_man_page!
    end
  end

  def release_notes
    odisabled "`brew release-notes`", "`brew release`"
  end
end

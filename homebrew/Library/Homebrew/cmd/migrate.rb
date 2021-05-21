# typed: true
# frozen_string_literal: true

require "migrator"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def migrate_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Migrate renamed packages to new names, where <formula> are old names of
        packages.
      EOS
      switch "-f", "--force",
             description: "Treat installed <formula> and provided <formula> as if they are from "\
                          "the same taps and migrate them anyway."

      named_args :installed_formula, min: 1
    end
  end

  def migrate
    args = migrate_args.parse

    args.named.to_resolved_formulae.each do |f|
      if f.oldname
        rack = HOMEBREW_CELLAR/f.oldname
        raise NoSuchKegError, f.oldname if !rack.exist? || rack.subdirs.empty?

        odie "#{rack} is a symlink" if rack.symlink?
      end

      migrator = Migrator.new(f, force: args.force?)
      migrator.migrate
    end
  end
end

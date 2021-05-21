# typed: true
# frozen_string_literal: true

require "cli/parser"
require "formula"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def unbottled_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Show the unbottled dependents of formulae.
      EOS
      flag   "--tag=",
             description: "Use the specified bottle tag (e.g. `big_sur`) instead of the current OS."
      switch "--dependents",
             description: "Skip getting analytics data and sort by number of dependents instead."
      switch "--total",
             description: "Print the number of unbottled and total formulae."

      conflicts "--dependents", "--total"

      named_args :formula
    end
  end

  sig { void }
  def unbottled
    args = unbottled_args.parse

    Formulary.enable_factory_cache!

    @bottle_tag = if (tag = args.tag)
      Utils::Bottles::Tag.from_symbol(tag.to_sym)
    else
      Utils::Bottles.tag
    end

    if args.named.blank?
      ohai "Getting formulae..."
    elsif args.total?
      raise UsageError, "cannot specify `<formula>` and `--total`."
    end

    formulae, all_formulae, formula_installs =
      formulae_all_installs_from_args(args)
    deps_hash, uses_hash = deps_uses_from_formulae(all_formulae)

    if args.dependents?
      formula_dependents = {}
      formulae = formulae.sort_by do |f|
        dependents = uses_hash[f.name]&.length || 0
        formula_dependents[f.name] ||= dependents
      end.reverse
    end

    if args.total?
      output_total(formulae)
      return
    end

    noun, hash = if args.named.present?
      [nil, {}]
    elsif args.dependents?
      ["dependents", formula_dependents]
    else
      ["installs", formula_installs]
    end

    output_unbottled(formulae, deps_hash, noun, hash, args.named.present?)
  end

  def formulae_all_installs_from_args(args)
    if args.named.present?
      formulae = all_formulae = args.named.to_formulae
    elsif args.total?
      formulae = all_formulae = Formula.to_a
    elsif args.dependents?
      formulae = all_formulae = Formula.to_a

      @sort = " (sorted by number of dependents)"
    else
      formula_installs = {}

      ohai "Getting analytics data..."
      analytics = Utils::Analytics.formulae_brew_sh_json("analytics/install/90d.json")

      if analytics.blank?
        raise UsageError,
              "default sort by analytics data requires " \
              "`HOMEBREW_NO_GITHUB_API` and `HOMEBREW_NO_ANALYTICS` to be unset"
      end

      formulae = analytics["items"].map do |i|
        f = i["formula"].split.first
        next if f.include?("/")
        next if formula_installs[f].present?

        formula_installs[f] = i["count"]
        begin
          Formula[f]
        rescue FormulaUnavailableError
          nil
        end
      end.compact
      @sort = " (sorted by installs in the last 90 days; top 10,000 only)"

      all_formulae = Formula
    end

    [formulae, all_formulae, formula_installs]
  end

  def deps_uses_from_formulae(all_formulae)
    ohai "Populating dependency tree..."

    deps_hash = {}
    uses_hash = {}

    all_formulae.each do |f|
      next unless f.core_formula?

      deps = f.recursive_dependencies do |_, dep|
        Dependency.prune if dep.optional?
      end.map(&:to_formula)
      deps_hash[f.name] = deps

      deps.each do |dep|
        uses_hash[dep.name] ||= []
        uses_hash[dep.name] << f
      end
    end

    [deps_hash, uses_hash]
  end

  def output_total(formulae)
    ohai "Unbottled :#{@bottle_tag} formulae"
    unbottled_formulae = 0

    formulae.each do |f|
      next if f.bottle_specification.tag?(@bottle_tag)
      next if f.bottle_unneeded?

      unbottled_formulae += 1
    end

    puts "#{unbottled_formulae}/#{formulae.length} remaining."
  end

  def output_unbottled(formulae, deps_hash, noun, hash, any_named_args)
    ohai ":#{@bottle_tag} bottle status#{@sort}"
    any_found = T.let(false, T::Boolean)

    formulae.each do |f|
      name = f.name.downcase
      if f.bottle_specification.tag?(@bottle_tag, no_older_versions: true)
        puts "#{Tty.bold}#{Tty.green}#{name}#{Tty.reset}: already bottled" if any_named_args
        next
      end

      if f.disabled?
        puts "#{Tty.bold}#{Tty.green}#{name}#{Tty.reset}: formula disabled" if any_named_args
        next
      end

      requirements = f.recursive_requirements
      if @bottle_tag.linux?
        if requirements.any?(MacOSRequirement)
          puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: requires macOS" if any_named_args
          next
        end
      elsif requirements.any?(LinuxRequirement)
        puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: requires Linux" if any_named_args
        next
      else
        macos_version = @bottle_tag.to_macos_version
        macos_satisfied = requirements.all? do |r|
          case r
          when MacOSRequirement
            next true unless r.version_specified?

            macos_version.public_send(r.comparator, r.version)
          when XcodeRequirement
            next true unless r.version

            Version.new(MacOS::Xcode.latest_version(macos: macos_version)) >= r.version
          when ArchRequirement
            arch = r.arch
            arch = :intel if arch == :x86_64
            arch = :arm64 if arch == :arm

            arch == macos_version.arch
          else
            true
          end
        end
        unless macos_satisfied
          puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: doesn't support this macOS" if any_named_args
          next
        end
      end

      if f.bottle_unneeded? || f.bottle_disabled?
        reason = if f.bottle_unneeded?
          "unneeded"
        else
          "disabled"
        end
        puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: bottle #{reason}" if any_named_args
        next
      end

      deps = Array(deps_hash[f.name]).reject do |dep|
        dep.bottle_specification.tag?(@bottle_tag, no_older_versions: true) || dep.bottle_unneeded?
      end

      if deps.blank?
        count = " (#{hash[f.name]} #{noun})" if noun
        puts "#{Tty.bold}#{Tty.green}#{name}#{Tty.reset}#{count}: ready to bottle"
        next
      end

      any_found ||= true
      count = " (#{hash[f.name]} #{noun})" if noun
      puts "#{Tty.bold}#{Tty.yellow}#{name}#{Tty.reset}#{count}: unbottled deps: #{deps.join(" ")}"
    end
    return if any_found
    return if any_named_args

    puts "No unbottled dependencies found!"
  end
end

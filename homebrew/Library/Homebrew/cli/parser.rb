# typed: false
# frozen_string_literal: true

require "env_config"
require "cask/config"
require "cli/args"
require "optparse"
require "set"
require "utils/tty"

COMMAND_DESC_WIDTH = 80
OPTION_DESC_WIDTH = 43

module Homebrew
  module CLI
    class Parser
      extend T::Sig

      attr_reader :processed_options, :hide_from_man_page, :named_args_type

      def self.from_cmd_path(cmd_path)
        cmd_args_method_name = Commands.args_method_name(cmd_path)

        begin
          Homebrew.send(cmd_args_method_name) if require?(cmd_path)
        rescue NoMethodError => e
          raise if e.name != cmd_args_method_name

          nil
        end
      end

      def self.global_cask_options
        [
          [:flag, "--appdir=", {
            description: "Target location for Applications " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:appdir]}`).",
          }],
          [:flag, "--colorpickerdir=", {
            description: "Target location for Color Pickers " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:colorpickerdir]}`).",
          }],
          [:flag, "--prefpanedir=", {
            description: "Target location for Preference Panes " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:prefpanedir]}`).",
          }],
          [:flag, "--qlplugindir=", {
            description: "Target location for QuickLook Plugins " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:qlplugindir]}`).",
          }],
          [:flag, "--mdimporterdir=", {
            description: "Target location for Spotlight Plugins " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:mdimporterdir]}`).",
          }],
          [:flag, "--dictionarydir=", {
            description: "Target location for Dictionaries " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:dictionarydir]}`).",
          }],
          [:flag, "--fontdir=", {
            description: "Target location for Fonts " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:fontdir]}`).",
          }],
          [:flag, "--servicedir=", {
            description: "Target location for Services " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:servicedir]}`).",
          }],
          [:flag, "--input-methoddir=", {
            description: "Target location for Input Methods " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:input_methoddir]}`).",
          }],
          [:flag, "--internet-plugindir=", {
            description: "Target location for Internet Plugins " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:internet_plugindir]}`).",
          }],
          [:flag, "--audio-unit-plugindir=", {
            description: "Target location for Audio Unit Plugins " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:audio_unit_plugindir]}`).",
          }],
          [:flag, "--vst-plugindir=", {
            description: "Target location for VST Plugins " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:vst_plugindir]}`).",
          }],
          [:flag, "--vst3-plugindir=", {
            description: "Target location for VST3 Plugins " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:vst3_plugindir]}`).",
          }],
          [:flag, "--screen-saverdir=", {
            description: "Target location for Screen Savers " \
                         "(default: `#{Cask::Config::DEFAULT_DIRS[:screen_saverdir]}`).",
          }],
          [:comma_array, "--language", {
            description: "Comma-separated list of language codes to prefer for cask installation. " \
                         "The first matching language is used, otherwise it reverts to the cask's " \
                         "default language. The default value is the language of your system.",
          }],
        ]
      end

      sig { returns(T::Array[[String, String, String]]) }
      def self.global_options
        [
          ["-d", "--debug",   "Display any debugging information."],
          ["-q", "--quiet",   "Make some output more quiet."],
          ["-v", "--verbose", "Make some output more verbose."],
          ["-h", "--help",    "Show this message."],
        ]
      end

      # FIXME: Block should be `T.nilable(T.proc.bind(Parser).void)`.
      # See https://github.com/sorbet/sorbet/issues/498.
      sig { params(block: T.proc.bind(Parser).void).void.checked(:never) }
      def initialize(&block)
        @parser = OptionParser.new

        @parser.summary_indent = " " * 2

        # Disable default handling of `--version` switch.
        @parser.base.long.delete("version")

        # Disable default handling of `--help` switch.
        @parser.base.long.delete("help")

        @args = Homebrew::CLI::Args.new

        @command_name = caller_locations(2, 1).first.label.chomp("_args").tr("_", "-")

        @constraints = []
        @conflicts = []
        @switch_sources = {}
        @processed_options = []
        @non_global_processed_options = []
        @named_args_type = nil
        @max_named_args = nil
        @min_named_args = nil
        @description = nil
        @usage_banner = nil
        @hide_from_man_page = false
        @formula_options = false
        @cask_options = false

        self.class.global_options.each do |short, long, desc|
          switch short, long, description: desc, env: option_to_name(long), method: :on_tail
        end

        instance_eval(&block) if block

        generate_banner
      end

      def switch(*names, description: nil, replacement: nil, env: nil, required_for: nil, depends_on: nil,
                 method: :on)
        global_switch = names.first.is_a?(Symbol)
        return if global_switch

        description = option_to_description(*names) if description.nil?
        if replacement.nil?
          process_option(*names, description, type: :switch)
        else
          description += " (disabled#{"; replaced by #{replacement}" if replacement.present?})"
        end
        @parser.public_send(method, *names, *wrap_option_desc(description)) do |value|
          odisabled "the `#{names.first}` switch", replacement unless replacement.nil?
          value = if names.any? { |name| name.start_with?("--[no-]") }
            value
          else
            true
          end

          set_switch(*names, value: value, from: :args)
        end

        names.each do |name|
          set_constraints(name, required_for: required_for, depends_on: depends_on)
        end

        env_value = env?(env)
        set_switch(*names, value: env_value, from: :env) unless env_value.nil?
      end
      alias switch_option switch

      def env?(env)
        return if env.blank?

        Homebrew::EnvConfig.try(:"#{env}?")
      end

      def description(text = nil)
        return @description if text.blank?

        @description = text.chomp
      end

      def usage_banner(text)
        @usage_banner, @description = text.chomp.split("\n\n", 2)
      end

      def usage_banner_text
        @parser.banner
      end

      def comma_array(name, description: nil)
        name = name.chomp "="
        description = option_to_description(name) if description.nil?
        process_option(name, description, type: :comma_array)
        @parser.on(name, OptionParser::REQUIRED_ARGUMENT, Array, *wrap_option_desc(description)) do |list|
          @args[option_to_name(name)] = list
        end
      end

      def flag(*names, description: nil, replacement: nil, required_for: nil,
               depends_on: nil, hidden: false)
        required, flag_type = if names.any? { |name| name.end_with? "=" }
          [OptionParser::REQUIRED_ARGUMENT, :required_flag]
        else
          [OptionParser::OPTIONAL_ARGUMENT, :optional_flag]
        end
        names.map! { |name| name.chomp "=" }
        description = option_to_description(*names) if description.nil?
        if replacement.nil?
          process_option(*names, description, type: flag_type, hidden: hidden)
        else
          description += " (disabled#{"; replaced by #{replacement}" if replacement.present?})"
        end
        @parser.on(*names, *wrap_option_desc(description), required) do |option_value|
          odisabled "the `#{names.first}` flag", replacement unless replacement.nil?
          names.each do |name|
            @args[option_to_name(name)] = option_value
          end
        end

        names.each do |name|
          set_constraints(name, required_for: required_for, depends_on: depends_on)
        end
      end

      def conflicts(*options)
        @conflicts << options.map { |option| option_to_name(option) }
      end

      def option_to_name(option)
        option.sub(/\A--?(\[no-\])?/, "")
              .tr("-", "_")
              .delete("=")
      end

      def name_to_option(name)
        if name.length == 1
          "-#{name}"
        else
          "--#{name.tr("_", "-")}"
        end
      end

      def option_to_description(*names)
        names.map { |name| name.to_s.sub(/\A--?/, "").tr("-", " ") }.max
      end

      def parse_remaining(argv, ignore_invalid_options: false)
        i = 0
        remaining = []

        argv, non_options = split_non_options(argv)

        while i < argv.count
          begin
            begin
              arg = argv[i]

              remaining << arg unless @parser.parse([arg]).empty?
            rescue OptionParser::MissingArgument
              raise if i + 1 >= argv.count

              args = argv[i..(i + 1)]
              @parser.parse(args)
              i += 1
            end
          rescue OptionParser::InvalidOption
            if ignore_invalid_options
              remaining << arg
            else
              $stderr.puts generate_help_text
              raise
            end
          end

          i += 1
        end

        [remaining, non_options]
      end

      sig { params(argv: T::Array[String], ignore_invalid_options: T::Boolean).returns(Args) }
      def parse(argv = ARGV.freeze, ignore_invalid_options: false)
        raise "Arguments were already parsed!" if @args_parsed

        # If we accept formula options, parse once allowing invalid options
        # so we can get the remaining list containing formula names.
        if @formula_options
          remaining, non_options = parse_remaining(argv, ignore_invalid_options: true)

          argv = [*remaining, "--", *non_options]

          formulae(argv).each do |f|
            next if f.options.empty?

            f.options.each do |o|
              name = o.flag
              description = "`#{f.name}`: #{o.description}"
              if name.end_with? "="
                flag   name, description: description
              else
                switch name, description: description
              end

              conflicts "--cask", name
            end
          end
        end

        remaining, non_options = parse_remaining(argv, ignore_invalid_options: ignore_invalid_options)

        named_args = if ignore_invalid_options
          []
        else
          remaining + non_options
        end

        unless ignore_invalid_options
          check_constraint_violations
          check_named_args(named_args)
        end

        @args.freeze_named_args!(named_args, cask_options: @cask_options)
        @args.freeze_remaining_args!(non_options.empty? ? remaining : [*remaining, "--", non_options])
        @args.freeze_processed_options!(@processed_options)
        @args.freeze

        @args_parsed = true

        if !ignore_invalid_options && @args.help?
          puts generate_help_text
          exit
        end

        @args
      end

      def generate_help_text
        Formatter.wrap(@parser.to_s, COMMAND_DESC_WIDTH)
                 .sub(/^/, "#{Tty.bold}Usage: brew#{Tty.reset} ")
                 .gsub(/`(.*?)`/m, "#{Tty.bold}\\1#{Tty.reset}")
                 .gsub(%r{<([^\s]+?://[^\s]+?)>}) { |url| Formatter.url(url) }
                 .gsub(/\*(.*?)\*|<(.*?)>/m) do |underlined|
                   underlined[1...-1].gsub(/^(\s*)(.*?)$/, "\\1#{Tty.underline}\\2#{Tty.reset}")
                 end
      end

      def cask_options
        self.class.global_cask_options.each do |method, *args, **options|
          send(method, *args, **options)
          conflicts "--formula", args.last
        end
        @cask_options = true
      end

      sig { void }
      def formula_options
        @formula_options = true
      end

      sig {
        params(
          type:   T.any(Symbol, T::Array[String], T::Array[Symbol]),
          number: T.nilable(Integer),
          min:    T.nilable(Integer),
          max:    T.nilable(Integer),
        ).void
      }
      def named_args(type = nil, number: nil, min: nil, max: nil)
        if number.present? && (min.present? || max.present?)
          raise ArgumentError, "Do not specify both `number` and `min` or `max`"
        end

        if type == :none && (number.present? || min.present? || max.present?)
          raise ArgumentError, "Do not specify both `number`, `min` or `max` with `named_args :none`"
        end

        @named_args_type = type

        if type == :none
          @max_named_args = 0
        elsif number.present?
          @min_named_args = @max_named_args = number
        elsif min.present? || max.present?
          @min_named_args = min
          @max_named_args = max
        end
      end

      def max_named(_count)
        odisabled "`max_named`", "`named_args max:`"
      end

      def min_named(_count_or_type)
        odisabled "`min_named`", "`named_args min:`"
      end

      def named(_count_or_type)
        odisabled "`named`", "`named_args`"
      end

      sig { void }
      def hide_from_man_page!
        @hide_from_man_page = true
      end

      private

      SYMBOL_TO_USAGE_MAPPING = {
        text_or_regex: "<text>|`/`<regex>`/`",
        url:           "<URL>",
      }.freeze

      def generate_usage_banner
        command_names = ["`#{@command_name}`"]
        aliases_to_skip = %w[instal uninstal]
        command_names += Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.map do |command_alias, command|
          next if aliases_to_skip.include? command_alias

          "`#{command_alias}`" if command == @command_name
        end.compact.sort

        options = if @non_global_processed_options.empty?
          ""
        elsif @non_global_processed_options.count > 2
          " [<options>]"
        else
          required_argument_types = [:required_flag, :comma_array]
          @non_global_processed_options.map do |option, type|
            next " [<#{option}>`=`]" if required_argument_types.include? type

            " [<#{option}>]"
          end.join
        end

        named_args = ""
        if @named_args_type.present? && @named_args_type != :none
          arg_type = if @named_args_type.is_a? Array
            types = @named_args_type.map do |type|
              next unless type.is_a? Symbol
              next SYMBOL_TO_USAGE_MAPPING[type] if SYMBOL_TO_USAGE_MAPPING.key?(type)

              "<#{type}>"
            end.compact
            types << "<subcommand>" if @named_args_type.any?(String)
            types.join("|")
          elsif SYMBOL_TO_USAGE_MAPPING.key? @named_args_type
            SYMBOL_TO_USAGE_MAPPING[@named_args_type]
          else
            "<#{@named_args_type}>"
          end

          named_args = if @min_named_args.blank? && @max_named_args == 1
            " [#{arg_type}]"
          elsif @min_named_args.blank?
            " [#{arg_type} ...]"
          elsif @min_named_args == 1 && @max_named_args == 1
            " #{arg_type}"
          elsif @min_named_args == 1
            " #{arg_type} [...]"
          else
            " #{arg_type} ..."
          end
        end

        "#{command_names.join(", ")}#{options}#{named_args}"
      end

      def generate_banner
        @usage_banner ||= generate_usage_banner

        @parser.banner = <<~BANNER
          #{@usage_banner}

          #{@description}

        BANNER
      end

      def set_switch(*names, value:, from:)
        names.each do |name|
          @switch_sources[option_to_name(name)] = from
          @args["#{option_to_name(name)}?"] = value
        end
      end

      def disable_switch(*names)
        names.each do |name|
          @args["#{option_to_name(name)}?"] = if name.start_with?("--[no-]")
            nil
          else
            false
          end
        end
      end

      def option_passed?(name)
        @args[name.to_sym] || @args["#{name}?".to_sym]
      end

      def wrap_option_desc(desc)
        Formatter.wrap(desc, OPTION_DESC_WIDTH).split("\n")
      end

      def set_constraints(name, depends_on:, required_for:)
        secondary = option_to_name(name)
        unless required_for.nil?
          primary = option_to_name(required_for)
          @constraints << [primary, secondary, :mandatory]
        end

        return if depends_on.nil?

        primary = option_to_name(depends_on)
        @constraints << [primary, secondary, :optional]
      end

      def check_constraints
        @constraints.each do |primary, secondary, constraint_type|
          primary_passed = option_passed?(primary)
          secondary_passed = option_passed?(secondary)

          primary = name_to_option(primary)
          secondary = name_to_option(secondary)

          if :mandatory.equal?(constraint_type) && primary_passed && !secondary_passed
            raise OptionConstraintError.new(primary, secondary)
          end
          raise OptionConstraintError.new(primary, secondary, missing: true) if secondary_passed && !primary_passed
        end
      end

      def check_conflicts
        @conflicts.each do |mutually_exclusive_options_group|
          violations = mutually_exclusive_options_group.select do |option|
            option_passed? option
          end

          next if violations.count < 2

          env_var_options = violations.select do |option|
            @switch_sources[option_to_name(option)] == :env
          end

          select_cli_arg = violations.count - env_var_options.count == 1
          raise OptionConflictError, violations.map(&method(:name_to_option)) unless select_cli_arg

          env_var_options.each(&method(:disable_switch))
        end
      end

      def check_invalid_constraints
        @conflicts.each do |mutually_exclusive_options_group|
          @constraints.each do |p, s|
            next unless Set[p, s].subset?(Set[*mutually_exclusive_options_group])

            raise InvalidConstraintError.new(p, s)
          end
        end
      end

      def check_constraint_violations
        check_invalid_constraints
        check_conflicts
        check_constraints
      end

      def check_named_args(args)
        types = Array(@named_args_type).map do |type|
          next type if type.is_a? Symbol

          :subcommand
        end.compact.uniq

        exception = if @min_named_args && @max_named_args && @min_named_args == @max_named_args &&
                       args.size != @max_named_args
          NumberOfNamedArgumentsError.new(@min_named_args, types: types)
        elsif @min_named_args && args.size < @min_named_args
          MinNamedArgumentsError.new(@min_named_args, types: types)
        elsif @max_named_args && args.size > @max_named_args
          MaxNamedArgumentsError.new(@max_named_args, types: types)
        end

        raise exception if exception
      end

      def process_option(*args, type:, hidden: false)
        option, = @parser.make_switch(args)
        @processed_options.reject! { |existing| existing.second == option.long.first } if option.long.first.present?
        @processed_options << [option.short.first, option.long.first, option.arg, option.desc.first]

        if type == :switch
          disable_switch(*args)
        else
          args.each do |name|
            @args[option_to_name(name)] = nil
          end
        end

        return if self.class.global_options.include? [option.short.first, option.long.first, option.desc.first]

        @non_global_processed_options << [option.long.first || option.short.first, type]
      end

      def split_non_options(argv)
        if (sep = argv.index("--"))
          [argv.take(sep), argv.drop(sep + 1)]
        else
          [argv, []]
        end
      end

      def formulae(argv)
        argv, non_options = split_non_options(argv)

        named_args = argv.reject { |arg| arg.start_with?("-") } + non_options
        spec = if argv.include?("--HEAD")
          :head
        else
          :stable
        end

        # Only lowercase names, not paths, bottle filenames or URLs
        named_args.map do |arg|
          next if arg.match?(HOMEBREW_CASK_TAP_CASK_REGEX)

          begin
            Formulary.factory(arg, spec, flags: argv.select { |a| a.start_with?("--") })
          rescue FormulaUnavailableError
            nil
          end
        end.compact.uniq(&:name)
      end
    end

    class OptionConstraintError < UsageError
      def initialize(arg1, arg2, missing: false)
        message = if missing
          "`#{arg2}` cannot be passed without `#{arg1}`."
        else
          "`#{arg1}` and `#{arg2}` should be passed together."
        end
        super message
      end
    end

    class OptionConflictError < UsageError
      def initialize(args)
        args_list = args.map(&Formatter.public_method(:option))
                        .join(" and ")
        super "Options #{args_list} are mutually exclusive."
      end
    end

    class InvalidConstraintError < UsageError
      def initialize(arg1, arg2)
        super "`#{arg1}` and `#{arg2}` cannot be mutually exclusive and mutually dependent simultaneously."
      end
    end

    class MaxNamedArgumentsError < UsageError
      extend T::Sig

      sig { params(maximum: Integer, types: T::Array[Symbol]).void }
      def initialize(maximum, types: [])
        super case maximum
        when 0
          "This command does not take named arguments."
        else
          types << :named if types.empty?
          arg_types = types.map { |type| type.to_s.tr("_", " ") }
                           .to_sentence two_words_connector: " or ", last_word_connector: " or "

          "This command does not take more than #{maximum} #{arg_types} #{"argument".pluralize(maximum)}."
        end
      end
    end

    class MinNamedArgumentsError < UsageError
      extend T::Sig

      sig { params(minimum: Integer, types: T::Array[Symbol]).void }
      def initialize(minimum, types: [])
        types << :named if types.empty?
        arg_types = types.map { |type| type.to_s.tr("_", " ") }
                         .to_sentence two_words_connector: " or ", last_word_connector: " or "

        super "This command requires at least #{minimum} #{arg_types} #{"argument".pluralize(minimum)}."
      end
    end

    class NumberOfNamedArgumentsError < UsageError
      extend T::Sig

      sig { params(minimum: Integer, types: T::Array[Symbol]).void }
      def initialize(minimum, types: [])
        types << :named if types.empty?
        arg_types = types.map { |type| type.to_s.tr("_", " ") }
                         .to_sentence two_words_connector: " or ", last_word_connector: " or "

        super "This command requires exactly #{minimum} #{arg_types} #{"argument".pluralize(minimum)}."
      end
    end
  end
end

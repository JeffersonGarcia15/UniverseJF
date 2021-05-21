# typed: true
# frozen_string_literal: true

require "exceptions"
require "hardware"
require "version"

module OS
  module Mac
    # A macOS version.
    #
    # @api private
    class Version < ::Version
      extend T::Sig

      SYMBOLS = {
        big_sur:     "11",
        catalina:    "10.15",
        mojave:      "10.14",
        high_sierra: "10.13",
        sierra:      "10.12",
        el_capitan:  "10.11",
        yosemite:    "10.10",
      }.freeze

      sig { params(version: Symbol).returns(T.attached_class) }
      def self.from_symbol(version)
        str = SYMBOLS.fetch(version) { raise MacOSVersionError, version }
        new(str)
      end

      sig { params(value: T.nilable(String)).void }
      def initialize(value)
        version ||= value

        raise MacOSVersionError, version unless /\A1\d+(?:\.\d+){0,2}\Z/.match?(version)

        super(version)

        @comparison_cache = {}
      end

      sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
      def <=>(other)
        @comparison_cache.fetch(other) do
          if SYMBOLS.key?(other) && to_sym == other
            0
          else
            v = SYMBOLS.fetch(other) { other.to_s }
            @comparison_cache[other] = super(::Version.new(v))
          end
        end
      end

      sig { returns(T.self_type) }
      def strip_patch
        # Big Sur is 11.x but Catalina is 10.15.x.
        if major >= 11
          self.class.new(major.to_s)
        else
          major_minor
        end
      end

      sig { returns(Symbol) }
      def to_sym
        @to_sym ||= SYMBOLS.invert.fetch(strip_patch.to_s, :dunno)
      end

      sig { returns(String) }
      def pretty_name
        @pretty_name ||= to_sym.to_s.split("_").map(&:capitalize).join(" ").freeze
      end

      # For {OS::Mac::Version} compatibility.
      sig { returns(T::Boolean) }
      def requires_nehalem_cpu?
        unless Hardware::CPU.intel?
          raise "Unexpected architecture: #{Hardware::CPU.arch}. This only works with Intel architecture."
        end

        Hardware.oldest_cpu(self) == :nehalem
      end
      # https://en.wikipedia.org/wiki/Nehalem_(microarchitecture)
      # Ensure any extra methods are also added to version/null.rb
      alias requires_sse4? requires_nehalem_cpu?
      alias requires_sse41? requires_nehalem_cpu?
      alias requires_sse42? requires_nehalem_cpu?
      alias requires_popcnt? requires_nehalem_cpu?
    end
  end
end

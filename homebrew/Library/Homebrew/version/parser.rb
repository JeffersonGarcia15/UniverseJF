# typed: true
# frozen_string_literal: true

class Version
  # @api private
  class Parser
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { abstract.params(spec: Pathname).returns(T.nilable(String)) }
    def parse(spec); end
  end

  # @api private
  class RegexParser < Parser
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { params(regex: Regexp, block: T.nilable(T.proc.params(arg0: String).returns(String))).void }
    def initialize(regex, &block)
      super()
      @regex = regex
      @block = block
    end

    sig { override.params(spec: Pathname).returns(T.nilable(String)) }
    def parse(spec)
      match = @regex.match(self.class.process_spec(spec))
      return if match.blank?

      version = match.captures.first
      return if version.blank?
      return @block.call(version) if @block.present?

      version
    end

    sig { abstract.params(spec: Pathname).returns(String) }
    def self.process_spec(spec); end
  end

  # @api private
  class UrlParser < RegexParser
    extend T::Sig

    sig { override.params(spec: Pathname).returns(String) }
    def self.process_spec(spec)
      spec.to_s
    end
  end

  # @api private
  class StemParser < RegexParser
    extend T::Sig

    SOURCEFORGE_DOWNLOAD_REGEX = %r{(?:sourceforge\.net|sf\.net)/.*/download$}.freeze
    NO_FILE_EXTENSION_REGEX = /\.[^a-zA-Z]+$/.freeze

    sig { override.params(spec: Pathname).returns(String) }
    def self.process_spec(spec)
      return spec.basename.to_s if spec.directory?

      spec_s = spec.to_s
      return spec.dirname.stem if spec_s.match?(SOURCEFORGE_DOWNLOAD_REGEX)
      return spec.basename.to_s if spec_s.match?(NO_FILE_EXTENSION_REGEX)

      spec.stem
    end
  end
end

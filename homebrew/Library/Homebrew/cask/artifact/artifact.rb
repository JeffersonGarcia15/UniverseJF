# typed: true
# frozen_string_literal: true

require "cask/artifact/moved"

require "extend/hash_validator"
using HashValidator

module Cask
  module Artifact
    # Generic artifact corresponding to the `artifact` stanza.
    #
    # @api private
    class Artifact < Moved
      extend T::Sig

      sig { returns(String) }
      def self.english_name
        "Generic Artifact"
      end

      sig { params(cask: Cask, args: T.untyped).returns(T.attached_class) }
      def self.from_args(cask, *args)
        source, options = args

        raise CaskInvalidError.new(cask.token, "No source provided for #{english_name}.") if source.blank?

        unless options.try(:key?, :target)
          raise CaskInvalidError.new(cask.token, "#{english_name} '#{source}' requires a target.")
        end

        new(cask, source, **options)
      end

      sig { params(target: T.any(String, Pathname)).returns(Pathname) }
      def resolve_target(target)
        super(target, base_dir: nil)
      end

      sig { params(cask: Cask, source: T.any(String, Pathname), target: T.any(String, Pathname)).void }
      def initialize(cask, source, target:)
        super(cask, source, target: target)
      end
    end
  end
end

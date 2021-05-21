# typed: false
# frozen_string_literal: true

module Homebrew
  module Livecheck
    # The `Livecheck::Strategy` module contains the various strategies as well
    # as some general-purpose methods for working with them. Within the context
    # of the `brew livecheck` command, strategies are established procedures
    # for finding new software versions at a given source.
    #
    # @api private
    module Strategy
      extend T::Sig

      module_function

      # Strategy priorities informally range from 1 to 10, where 10 is the
      # highest priority. 5 is the default priority because it's roughly in
      # the middle of this range. Strategies with a priority of 0 (or lower)
      # are ignored.
      DEFAULT_PRIORITY = 5
      private_constant :DEFAULT_PRIORITY

      # Creates and/or returns a `@strategies` `Hash`, which maps a snake
      # case strategy name symbol (e.g. `:page_match`) to the associated
      # {Strategy}.
      #
      # At present, this should only be called after tap strategies have been
      # loaded, otherwise livecheck won't be able to use them.
      # @return [Hash]
      def strategies
        return @strategies if defined? @strategies

        @strategies = {}
        constants.sort.each do |strategy_symbol|
          key = strategy_symbol.to_s.underscore.to_sym
          strategy = const_get(strategy_symbol)
          @strategies[key] = strategy
        end
        @strategies
      end
      private_class_method :strategies

      # Returns the {Strategy} that corresponds to the provided `Symbol` (or
      # `nil` if there is no matching {Strategy}).
      #
      # @param symbol [Symbol] the strategy name in snake case as a `Symbol`
      #   (e.g. `:page_match`)
      # @return [Strategy, nil]
      def from_symbol(symbol)
        strategies[symbol]
      end

      # Returns an array of strategies that apply to the provided URL.
      #
      # @param url [String] the URL to check for matching strategies
      # @param livecheck_strategy [Symbol] a {Strategy} symbol from the
      #   `livecheck` block
      # @param regex_provided [Boolean] whether a regex is provided in the
      #   `livecheck` block
      # @return [Array]
      def from_url(url, livecheck_strategy: nil, url_provided: nil, regex_provided: nil, block_provided: nil)
        usable_strategies = strategies.values.select do |strategy|
          if strategy == PageMatch
            # Only treat the `PageMatch` strategy as usable if a regex is
            # present in the `livecheck` block
            next if !regex_provided && !block_provided
          elsif strategy.const_defined?(:PRIORITY) &&
                !strategy::PRIORITY.positive? &&
                from_symbol(livecheck_strategy) != strategy
            # Ignore strategies with a priority of 0 or lower, unless the
            # strategy is specified in the `livecheck` block
            next
          end

          strategy.respond_to?(:match?) && strategy.match?(url)
        end

        # Sort usable strategies in descending order by priority, using the
        # DEFAULT_PRIORITY when a strategy doesn't contain a PRIORITY constant
        usable_strategies.sort_by do |strategy|
          (strategy.const_defined?(:PRIORITY) ? -strategy::PRIORITY : -DEFAULT_PRIORITY)
        end
      end

      def self.page_headers(url)
        headers = []

        [:default, :browser].each do |user_agent|
          args = [
            "--head",                 # Only work with the response headers
            "--request", "GET",       # Use a GET request (instead of HEAD)
            "--silent",               # Silent mode
            "--location",             # Follow redirects
            "--connect-timeout", "5", # Max time allowed for connection (secs)
            "--max-time", "10"        # Max time allowed for transfer (secs)
          ]

          stdout, _, status = curl_with_workarounds(
            *args, url,
            print_stdout: false, print_stderr: false,
            debug: false, verbose: false,
            user_agent: user_agent, retry: false
          )

          while stdout.match?(/\AHTTP.*\r$/)
            h, stdout = stdout.split("\r\n\r\n", 2)

            headers << h.split("\r\n").drop(1)
                        .map { |header| header.split(/:\s*/, 2) }
                        .to_h.transform_keys(&:downcase)
          end

          return headers if status.success?
        end

        headers
      end

      # Fetches the content at the URL and returns a hash containing the
      # content and, if there are any redirections, the final URL.
      #
      # @param url [String] the URL of the content to check
      # @return [Hash]
      sig { params(url: String).returns(T::Hash[Symbol, T.untyped]) }
      def self.page_content(url)
        original_url = url

        # Manually handling `URI#open` redirections allows us to detect the
        # resolved URL while also supporting HTTPS to HTTP redirections (which
        # are normally forbidden by `OpenURI`).
        begin
          content = URI.parse(url).open(redirect: false, &:read)
        rescue OpenURI::HTTPRedirect => e
          url = e.uri.to_s
          retry
        end

        data = { content: content }
        data[:final_url] = url unless url == original_url
        data
      end
    end
  end
end

require_relative "strategy/apache"
require_relative "strategy/bitbucket"
require_relative "strategy/cpan"
require_relative "strategy/electron_builder"
require_relative "strategy/extract_plist"
require_relative "strategy/git"
require_relative "strategy/github_latest"
require_relative "strategy/gnome"
require_relative "strategy/gnu"
require_relative "strategy/hackage"
require_relative "strategy/header_match"
require_relative "strategy/launchpad"
require_relative "strategy/npm"
require_relative "strategy/page_match"
require_relative "strategy/pypi"
require_relative "strategy/sourceforge"
require_relative "strategy/sparkle"
require_relative "strategy/xorg"

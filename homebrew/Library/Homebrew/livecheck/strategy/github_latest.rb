# typed: false
# frozen_string_literal: true

module Homebrew
  module Livecheck
    module Strategy
      # The {GithubLatest} strategy identifies versions of software at
      # github.com by checking a repository's "latest" release page.
      #
      # GitHub URLs take a few different formats:
      #
      # * `https://github.com/example/example/releases/download/1.2.3/example-1.2.3.tar.gz`
      # * `https://github.com/example/example/archive/v1.2.3.tar.gz`
      # * `https://github.com/downloads/example/example/example-1.2.3.tar.gz`
      #
      # A repository's `/releases/latest` URL normally redirects to a release
      # tag (e.g., `/releases/tag/1.2.3`). When there isn't a "latest" release,
      # it will redirect to the `/releases` page.
      #
      # This strategy should only be used when we know the upstream repository
      # has a "latest" release and the tagged release is appropriate to use
      # (e.g., "latest" isn't wrongly pointing to an unstable version, not
      # picking up the actual latest version, etc.). The strategy can only be
      # applied by using `strategy :github_latest` in a `livecheck` block.
      #
      # The default regex identifies versions like `1.2.3`/`v1.2.3` in `href`
      # attributes containing the tag URL (e.g.,
      # `/example/example/releases/tag/v1.2.3`). This is a common tag format
      # but a modified regex can be provided in a `livecheck` block to override
      # the default if a repository uses a different format (e.g.,
      # `example-1.2.3`, `1.2.3d`, `1.2.3-4`, etc.).
      #
      # @api public
      class GithubLatest
        extend T::Sig

        NICE_NAME = "GitHub - Latest"

        # A priority of zero causes livecheck to skip the strategy. We do this
        # for {GithubLatest} so we can selectively apply the strategy using
        # `strategy :github_latest` in a `livecheck` block.
        PRIORITY = 0

        # The `Regexp` used to determine if the strategy applies to the URL.
        URL_MATCH_REGEX = %r{
          ^https?://github\.com
          /(?:downloads/)?(?<username>[^/]+) # The GitHub username
          /(?<repository>[^/]+)              # The GitHub repository name
        }ix.freeze

        # Whether the strategy can be applied to the provided URL.
        #
        # @param url [String] the URL to match against
        # @return [Boolean]
        def self.match?(url)
          URL_MATCH_REGEX.match?(url)
        end

        # Generates a URL and regex (if one isn't provided) and passes them
        # to {PageMatch.find_versions} to identify versions in the content.
        #
        # @param url [String] the URL of the content to check
        # @param regex [Regexp] a regex used for matching versions in content
        # @return [Hash]
        sig {
          params(
            url:   String,
            regex: T.nilable(Regexp),
            cask:  T.nilable(Cask::Cask),
            block: T.nilable(T.proc.params(arg0: String).returns(T.any(T::Array[String], String))),
          ).returns(T::Hash[Symbol, T.untyped])
        }
        def self.find_versions(url, regex, cask: nil, &block)
          match = url.sub(/\.git$/i, "").match(URL_MATCH_REGEX)

          # Example URL: `https://github.com/example/example/releases/latest`
          page_url = "https://github.com/#{match[:username]}/#{match[:repository]}/releases/latest"

          # The default regex is the same for all URLs using this strategy
          regex ||= %r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i

          PageMatch.find_versions(page_url, regex, cask: cask, &block)
        end
      end
    end
  end
end

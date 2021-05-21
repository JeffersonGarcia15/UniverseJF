# typed: true
# frozen_string_literal: true

require "bundle_version"
require_relative "page_match"

module Homebrew
  module Livecheck
    module Strategy
      # The {Sparkle} strategy fetches content at a URL and parses
      # it as a Sparkle appcast in XML format.
      #
      # @api private
      class Sparkle
        extend T::Sig

        # A priority of zero causes livecheck to skip the strategy. We only
        # apply {Sparkle} using `strategy :sparkle` in a `livecheck` block,
        # as we can't automatically determine when this can be successfully
        # applied to a URL without fetching the content.
        PRIORITY = 0

        # The `Regexp` used to determine if the strategy applies to the URL.
        URL_MATCH_REGEX = %r{^https?://}i.freeze

        # Whether the strategy can be applied to the provided URL.
        # The strategy will technically match any HTTP URL but is
        # only usable with a `livecheck` block containing a regex
        # or block.
        sig { params(url: String).returns(T::Boolean) }
        def self.match?(url)
          URL_MATCH_REGEX.match?(url)
        end

        # @api private
        Item = Struct.new(
          # @api public
          :title,
          # @api private
          :pub_date,
          # @api public
          :url,
          # @api private
          :bundle_version,
          keyword_init: true,
        ) do
          extend T::Sig

          extend Forwardable

          # @api public
          delegate version: :bundle_version

          # @api public
          delegate short_version: :bundle_version
        end

        sig { params(content: String).returns(T.nilable(Item)) }
        def self.item_from_content(content)
          Homebrew.install_bundler_gems!
          require "nokogiri"

          xml = Nokogiri::XML(content)
          xml.remove_namespaces!

          items = xml.xpath("//rss//channel//item").map do |item|
            enclosure = (item > "enclosure").first

            url = enclosure&.attr("url")
            short_version = enclosure&.attr("shortVersionString")
            version = enclosure&.attr("version")

            url ||= (item > "link").first&.text
            short_version ||= (item > "shortVersionString").first&.text&.strip
            version ||= (item > "version").first&.text&.strip

            title = (item > "title").first&.text&.strip
            pub_date = (item > "pubDate").first&.text&.strip&.yield_self { |d| Time.parse(d) }

            if (match = title&.match(/(\d+(?:\.\d+)*)\s*(\([^)]+\))?\Z/))
              short_version ||= match[1]
              version ||= match[2]
            end

            bundle_version = BundleVersion.new(short_version, version) if short_version || version

            next if (os = enclosure&.attr("os")) && os != "osx"

            data = {
              title:          title,
              pub_date:       pub_date,
              url:            url,
              bundle_version: bundle_version,
            }.compact

            Item.new(**data) unless data.empty?
          end.compact

          items.max_by { |item| [item.pub_date, item.bundle_version] }
        end

        # Checks the content at the URL for new versions.
        sig {
          params(
            url:   String,
            regex: T.nilable(Regexp),
            cask:  T.nilable(Cask::Cask),
            block: T.nilable(T.proc.params(arg0: Item).returns(String)),
          ).returns(T::Hash[Symbol, T.untyped])
        }
        def self.find_versions(url, regex, cask: nil, &block)
          raise ArgumentError, "The #{T.must(name).demodulize} strategy does not support a regex." if regex

          match_data = { matches: {}, regex: regex, url: url }

          match_data.merge!(Strategy.page_content(url))
          content = match_data.delete(:content)

          if (item = item_from_content(content))
            match = if block
              value = block.call(item)

              unless T.unsafe(value).is_a?(String)
                raise TypeError, "Return value of `strategy :sparkle` block must be a string."
              end

              value
            else
              item.bundle_version&.nice_version
            end

            match_data[:matches][match] = Version.new(match) if match
          end

          match_data
        end
      end
    end
  end
end

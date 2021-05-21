# typed: false
# frozen_string_literal: true

homebrew_bootsnap_enabled = !ENV["HOMEBREW_NO_BOOTSNAP"] && ENV["HOMEBREW_BOOTSNAP"]

# portable ruby doesn't play nice with bootsnap
# Can't use .exclude? here because we haven't required active_support yet.
homebrew_bootsnap_enabled &&= !ENV["HOMEBREW_RUBY_PATH"].to_s.include?("/vendor/portable-ruby/") # rubocop:disable Rails/NegateInclude

homebrew_bootsnap_enabled &&= if ENV["HOMEBREW_MACOS_VERSION"]
  # Apple Silicon doesn't play nice with bootsnap
  ENV["HOMEBREW_PROCESSOR"] == "Intel" &&
    # we need some development tools to build bootsnap native code
    (File.directory?("/Applications/Xcode.app") || File.directory?("/Library/Developer/CommandLineTools"))
else
  File.executable?("/usr/bin/clang") || File.executable?("/usr/bin/gcc")
end

if homebrew_bootsnap_enabled
  begin
    require "bootsnap"
  rescue LoadError
    unless ENV["HOMEBREW_BOOTSNAP_RETRY"]
      Homebrew.install_bundler_gems!(only_warn_on_failure: true)

      ENV["HOMEBREW_BOOTSNAP_RETRY"] = "1"
      exec ENV["HOMEBREW_BREW_FILE"], *ARGV
    end
  end

  ENV.delete("HOMEBREW_BOOTSNAP_RETRY")

  if defined?(Bootsnap)
    cache = ENV["HOMEBREW_CACHE"] || ENV["HOMEBREW_DEFAULT_CACHE"]
    # Can't use .blank? here because we haven't required active_support yet.
    raise "Needs HOMEBREW_CACHE or HOMEBREW_DEFAULT_CACHE!" if cache.nil? || cache.empty? # rubocop:disable Rails/Blank

    Bootsnap.setup(
      cache_dir:          cache,
      load_path_cache:    true,
      compile_cache_iseq: true,
      compile_cache_yaml: true,
    )
  else
    $stderr.puts "Error: HOMEBREW_BOOTSNAP could not `require \"bootsnap\"`!\n\n"
  end
end

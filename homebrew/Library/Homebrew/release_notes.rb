# typed: true
# frozen_string_literal: true

# Helper functions for generating release notes.
#
# @api private
module ReleaseNotes
  extend T::Sig

  module_function

  sig {
    params(start_ref: T.any(String, Version), end_ref: T.any(String, Version), markdown: T.nilable(T::Boolean))
      .returns(String)
  }
  def generate_release_notes(start_ref, end_ref, markdown: false)
    log_output = Utils.popen_read(
      "git", "-C", HOMEBREW_REPOSITORY, "log", "--pretty=format:'%s >> - %b%n'", "#{start_ref}..#{end_ref}"
    ).lines.grep(/Merge pull request/)

    log_output.map! do |s|
      matches = s.match(%r{.*Merge pull request #(?<pr>\d+) from (?<user>[^/]+)/[^>]*>> - (?<body>.*)})
      body = if matches[:body].empty?
        s.gsub(/.*(Merge pull request .*) >> - .*/, "\\1").chomp
      else
        matches[:body]
      end
      "https://github.com/Homebrew/brew/pull/#{matches[:pr]} (@#{matches[:user]}) - #{body}\n"
    end

    if markdown
      log_output.map! do |s|
        /(.*\d)+ \(@(.+)\) - (.*)/ =~ s
        "- [#{Regexp.last_match(3)}](#{Regexp.last_match(1)}) (@#{Regexp.last_match(2)})\n"
      end
    end

    log_output.join
  end
end

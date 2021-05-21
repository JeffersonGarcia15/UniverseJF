# typed: false
# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "brew sh" do
  it_behaves_like "parseable arguments"

  it "runs a shell with the Homebrew environment", :integration_test do
    expect { brew "sh", "SHELL" => which("true") }
      .to output(/Your shell has been configured/).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end

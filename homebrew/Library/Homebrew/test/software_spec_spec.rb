# typed: false
# frozen_string_literal: true

require "software_spec"

describe SoftwareSpec do
  alias_matcher :have_defined_resource, :be_resource_defined
  alias_matcher :have_defined_option, :be_option_defined

  subject(:spec) { described_class.new }

  let(:owner) { double(name: "some_name", full_name: "some_name", tap: "homebrew/core") }

  describe "#resource" do
    it "defines a resource" do
      spec.resource("foo") { url "foo-1.0" }
      expect(spec).to have_defined_resource("foo")
    end

    it "sets itself to be the resource's owner" do
      spec.resource("foo") { url "foo-1.0" }
      spec.owner = owner
      spec.resources.each_value do |r|
        expect(r.owner).to eq(spec)
      end
    end

    it "receives the owner's version if it has no own version" do
      spec.url("foo-42")
      spec.resource("bar") { url "bar" }
      spec.owner = owner

      expect(spec.resource("bar").version).to eq("42")
    end

    it "raises an error when duplicate resources are defined" do
      spec.resource("foo") { url "foo-1.0" }
      expect {
        spec.resource("foo") { url "foo-1.0" }
      }.to raise_error(DuplicateResourceError)
    end

    it "raises an error when accessing missing resources" do
      spec.owner = owner
      expect {
        spec.resource("foo")
      }.to raise_error(ResourceMissingError)
    end
  end

  describe "#owner" do
    it "sets the owner" do
      spec.owner = owner
      expect(spec.owner).to eq(owner)
    end

    it "sets the name" do
      spec.owner = owner
      expect(spec.name).to eq(owner.name)
    end
  end

  describe "#option" do
    it "defines an option" do
      spec.option("foo")
      expect(spec).to have_defined_option("foo")
    end

    it "raises an error when it begins with dashes" do
      expect {
        spec.option("--foo")
      }.to raise_error(ArgumentError)
    end

    it "raises an error when name is empty" do
      expect {
        spec.option("")
      }.to raise_error(ArgumentError)
    end

    it "special cases the cxx11 option" do
      spec.option(:cxx11)
      expect(spec).to have_defined_option("c++11")
      expect(spec).not_to have_defined_option("cxx11")
    end

    it "supports options with descriptions" do
      spec.option("bar", "description")
      expect(spec.options.first.description).to eq("description")
    end

    it "defaults to an empty string when no description is given" do
      spec.option("foo")
      expect(spec.options.first.description).to eq("")
    end
  end

  describe "#deprecated_option" do
    it "allows specifying deprecated options" do
      spec.deprecated_option("foo" => "bar")
      expect(spec.deprecated_options).not_to be_empty
      expect(spec.deprecated_options.first.old).to eq("foo")
      expect(spec.deprecated_options.first.current).to eq("bar")
    end

    it "allows specifying deprecated options as a Hash from an Array/String to an Array/String" do
      spec.deprecated_option(["foo1", "foo2"] => "bar1", "foo3" => ["bar2", "bar3"])
      expect(spec.deprecated_options).to include(DeprecatedOption.new("foo1", "bar1"))
      expect(spec.deprecated_options).to include(DeprecatedOption.new("foo2", "bar1"))
      expect(spec.deprecated_options).to include(DeprecatedOption.new("foo3", "bar2"))
      expect(spec.deprecated_options).to include(DeprecatedOption.new("foo3", "bar3"))
    end

    it "raises an error when empty" do
      expect {
        spec.deprecated_option({})
      }.to raise_error(ArgumentError)
    end
  end

  describe "#depends_on" do
    it "allows specifying dependencies" do
      spec.depends_on("foo")
      expect(spec.deps.first.name).to eq("foo")
    end

    it "allows specifying optional dependencies" do
      spec.depends_on "foo" => :optional
      expect(spec).to have_defined_option("with-foo")
    end

    it "allows specifying recommended dependencies" do
      spec.depends_on "bar" => :recommended
      expect(spec).to have_defined_option("without-bar")
    end
  end

  describe "#uses_from_macos" do
    it "allows specifying dependencies", :needs_linux do
      spec.uses_from_macos("foo")

      expect(spec.deps.first.name).to eq("foo")
    end

    it "works with tags", :needs_linux do
      spec.uses_from_macos("foo" => :build)

      expect(spec.deps.first.name).to eq("foo")
      expect(spec.deps.first.tags).to include(:build)
    end

    it "ignores OS version specifications", :needs_linux do
      spec.uses_from_macos("foo", since: :mojave)
      spec.uses_from_macos("bar" => :build, :since => :mojave)

      expect(spec.deps.first.name).to eq("foo")
      expect(spec.deps.last.name).to eq("bar")
      expect(spec.deps.last.tags).to include(:build)
    end
  end

  specify "explicit options override defaupt depends_on option description" do
    spec.option("with-foo", "blah")
    spec.depends_on("foo" => :optional)
    expect(spec.options.first.description).to eq("blah")
  end

  describe "#patch" do
    it "adds a patch" do
      spec.patch(:p1, :DATA)
      expect(spec.patches.count).to eq(1)
      expect(spec.patches.first.strip).to eq(:p1)
    end
  end
end

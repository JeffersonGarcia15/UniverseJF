# typed: false
# frozen_string_literal: true

require "installed_dependents"

describe InstalledDependents do
  include FileUtils

  def setup_test_keg(name, version)
    path = HOMEBREW_CELLAR/name/version
    (path/"bin").mkpath

    %w[hiworld helloworld goodbye_cruel_world].each do |file|
      touch path/"bin"/file
    end

    Keg.new(path)
  end

  let!(:keg) { setup_test_keg("foo", "1.0") }

  describe "::find_some_installed_dependents" do
    def stub_formula_name(name)
      f = formula(name) { url "foo-1.0" }
      stub_formula_loader f
      stub_formula_loader f, "homebrew/core/#{f}"
      f
    end

    def setup_test_keg(name, version)
      f = stub_formula_name(name)
      keg = super
      Tab.create(f, DevelopmentTools.default_compiler, :libcxx).write
      keg
    end

    before do
      keg.link
    end

    def alter_tab(keg = dependent)
      tab = Tab.for_keg(keg)
      yield tab
      tab.write
    end

    # 1.1.6 is the earliest version of Homebrew that generates correct runtime
    # dependency lists in {Tab}s.
    def dependencies(deps, homebrew_version: "1.1.6")
      alter_tab do |tab|
        tab.homebrew_version = homebrew_version
        tab.tabfile = dependent/Tab::FILENAME
        tab.runtime_dependencies = deps
      end
    end

    def unreliable_dependencies(deps)
      # 1.1.5 is (hopefully!) the last version of Homebrew that generates
      # incorrect runtime dependency lists in {Tab}s.
      dependencies(deps, homebrew_version: "1.1.5")
    end

    let(:dependent) { setup_test_keg("bar", "1.0") }

    specify "a dependency with no Tap in Tab" do
      tap_dep = setup_test_keg("baz", "1.0")

      # allow tap_dep to be linked too
      FileUtils.rm_r tap_dep/"bin"
      tap_dep.link

      alter_tab(keg) { |t| t.source["tap"] = nil }

      dependencies nil
      Formula["bar"].class.depends_on "foo"
      Formula["bar"].class.depends_on "baz"

      result = described_class.find_some_installed_dependents([keg, tap_dep])
      expect(result).to eq([[keg, tap_dep], ["bar"]])
    end

    specify "no dependencies anywhere" do
      dependencies nil
      expect(described_class.find_some_installed_dependents([keg])).to be nil
    end

    specify "missing Formula dependency" do
      dependencies nil
      Formula["bar"].class.depends_on "foo"
      expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
    end

    specify "uninstalling dependent and dependency" do
      dependencies nil
      Formula["bar"].class.depends_on "foo"
      expect(described_class.find_some_installed_dependents([keg, dependent])).to be nil
    end

    specify "renamed dependency" do
      dependencies nil

      stub_formula_loader Formula["foo"], "homebrew/core/foo-old"
      renamed_path = HOMEBREW_CELLAR/"foo-old"
      (HOMEBREW_CELLAR/"foo").rename(renamed_path)
      renamed_keg = Keg.new(renamed_path/"1.0")

      Formula["bar"].class.depends_on "foo"

      result = described_class.find_some_installed_dependents([renamed_keg])
      expect(result).to eq([[renamed_keg], ["bar"]])
    end

    specify "empty dependencies in Tab" do
      dependencies []
      expect(described_class.find_some_installed_dependents([keg])).to be nil
    end

    specify "same name but different version in Tab" do
      dependencies [{ "full_name" => "foo", "version" => "1.1" }]
      expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
    end

    specify "different name and same version in Tab" do
      stub_formula_name("baz")
      dependencies [{ "full_name" => "baz", "version" => keg.version.to_s }]
      expect(described_class.find_some_installed_dependents([keg])).to be nil
    end

    specify "same name and version in Tab" do
      dependencies [{ "full_name" => "foo", "version" => "1.0" }]
      expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
    end

    specify "fallback for old versions" do
      unreliable_dependencies [{ "full_name" => "baz", "version" => "1.0" }]
      Formula["bar"].class.depends_on "foo"
      expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
    end

    specify "non-opt-linked" do
      keg.remove_opt_record
      dependencies [{ "full_name" => "foo", "version" => "1.0" }]
      expect(described_class.find_some_installed_dependents([keg])).to be nil
    end

    specify "keg-only" do
      keg.unlink
      Formula["foo"].class.keg_only "a good reason"
      dependencies [{ "full_name" => "foo", "version" => "1.1" }] # different version
      expect(described_class.find_some_installed_dependents([keg])).to eq([[keg], ["bar"]])
    end

    def stub_cask_name(name, version, dependency)
      c = Cask::CaskLoader.load(+<<-RUBY)
        cask "#{name}" do
          version "#{version}"

          url "c-1"
          depends_on formula: "#{dependency}"
        end
      RUBY

      stub_cask_loader c
      c
    end

    def setup_test_cask(name, version, dependency)
      c = stub_cask_name(name, version, dependency)
      Cask::Caskroom.path.join(name, c.version).mkpath
      c
    end

    specify "identify dependent casks" do
      setup_test_cask("qux", "1.0.0", "foo")
      dependents = described_class.find_some_installed_dependents([keg]).last
      expect(dependents.include?("qux")).to eq(true)
    end
  end
end

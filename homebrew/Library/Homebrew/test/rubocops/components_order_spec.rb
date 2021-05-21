# typed: false
# frozen_string_literal: true

require "rubocops/components_order"

describe RuboCop::Cop::FormulaAudit::ComponentsOrder do
  subject(:cop) { described_class.new }

  context "when auditing formula components order" do
    it "reports and corrects an offense when `uses_from_macos` precedes `depends_on`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"

          uses_from_macos "apple"
          depends_on "foo"
          ^^^^^^^^^^^^^^^^ `depends_on` (line 6) should be put before `uses_from_macos` (line 5)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"

          depends_on "foo"

          uses_from_macos "apple"
        end
      RUBY
    end

    it "reports and corrects an offense when `license` precedes `sha256`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          license "0BSD"
          sha256 "samplesha256"
          ^^^^^^^^^^^^^^^^^^^^^ `sha256` (line 5) should be put before `license` (line 4)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
          sha256 "samplesha256"
          license "0BSD"
        end
      RUBY
    end

    it "reports and corrects an offense when `bottle` precedes `livecheck`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"

          bottle :unneeded

          livecheck do
          ^^^^^^^^^^^^ `livecheck` (line 7) should be put before `bottle` (line 5)
            url "https://brew.sh/foo/versions/"
            regex(/href=.+?foo-(\d+(?:\.\d+)+)\.t/)
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"

          livecheck do
            url "https://brew.sh/foo/versions/"
            regex(/href=.+?foo-(\d+(?:\.\d+)+)\.t/)
          end

          bottle :unneeded
        end
      RUBY
    end

    it "reports and corrects an offense when `url` precedes `homepage`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          homepage "https://brew.sh"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ `homepage` (line 3) should be put before `url` (line 2)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"
          url "https://brew.sh/foo-1.0.tgz"
        end
      RUBY
    end

    it "reports and corrects an offense when `resource` precedes `depends_on`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          resource "foo2" do
            url "https://brew.sh/foo-2.0.tgz"
          end

          depends_on "openssl"
          ^^^^^^^^^^^^^^^^^^^^ `depends_on` (line 8) should be put before `resource` (line 4)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          depends_on "openssl"

          resource "foo2" do
            url "https://brew.sh/foo-2.0.tgz"
          end
        end
      RUBY
    end

    it "reports and corrects an offense when `test` precedes `plist`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          test do
            expect(shell_output("./dogs")).to match("Dogs are terrific")
          end

          def plist
          ^^^^^^^^^ `plist` (line 8) should be put before `test` (line 4)
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          def plist
          end

          test do
            expect(shell_output("./dogs")).to match("Dogs are terrific")
          end
        end
      RUBY
    end

    it "reports and corrects an offense when `install` precedes `depends_on`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          def install
          end

          depends_on "openssl"
          ^^^^^^^^^^^^^^^^^^^^ `depends_on` (line 7) should be put before `install` (line 4)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          depends_on "openssl"

          def install
          end
        end
      RUBY
    end

    it "reports and corrects an offense when `test` precedes `depends_on`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          def install
          end

          def test
          end

          depends_on "openssl"
          ^^^^^^^^^^^^^^^^^^^^ `depends_on` (line 10) should be put before `install` (line 4)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"

          depends_on "openssl"

          def install
          end

          def test
          end
        end
      RUBY
    end

    it "reports and corrects an offense when only one of many `depends_on` precedes `conflicts_with`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          depends_on "autoconf" => :build
          conflicts_with "visionmedia-watch"
          depends_on "automake" => :build
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `depends_on` (line 4) should be put before `conflicts_with` (line 3)
          depends_on "libtool" => :build
          depends_on "pkg-config" => :build
          depends_on "gettext"
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          depends_on "autoconf" => :build
          depends_on "automake" => :build
          depends_on "libtool" => :build
          depends_on "pkg-config" => :build
          depends_on "gettext"
          conflicts_with "visionmedia-watch"
        end
      RUBY
    end

    it "reports and corrects an offense when the `on_macos` block precedes `uses_from_macos`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_macos do
            depends_on "readline"
          end
          uses_from_macos "bar"
          ^^^^^^^^^^^^^^^^^^^^^ `uses_from_macos` (line 6) should be put before `on_macos` (line 3)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "bar"

          on_macos do
            depends_on "readline"
          end
        end
      RUBY
    end

    it "reports and corrects an offense when the `on_linux` block precedes `uses_from_macos`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_linux do
            depends_on "readline"
          end
          uses_from_macos "bar"
          ^^^^^^^^^^^^^^^^^^^^^ `uses_from_macos` (line 6) should be put before `on_linux` (line 3)
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          uses_from_macos "bar"

          on_linux do
            depends_on "readline"
          end
        end
      RUBY
    end

    it "reports and corrects an offense when the `on_linux` block precedes the `on_macos` block" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_linux do
            depends_on "vim"
          end
          on_macos do
          ^^^^^^^^^^^ `on_macos` (line 6) should be put before `on_linux` (line 3)
            depends_on "readline"
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_macos do
            depends_on "readline"
          end

          on_linux do
            depends_on "vim"
          end
        end
      RUBY
    end
  end

  it "reports and corrects an offense when `depends_on` precedes `deprecate!`" do
    expect_offense(<<~RUBY)
      class Foo < Formula
        url "https://brew.sh/foo-1.0.tgz"

        depends_on "openssl"

        deprecate! because: "has been replaced by bar"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `deprecate!` (line 6) should be put before `depends_on` (line 4)
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo < Formula
        url "https://brew.sh/foo-1.0.tgz"

        deprecate! because: "has been replaced by bar"

        depends_on "openssl"
      end
    RUBY
  end

  context "when formula has no OS-specific blocks" do
    it "reports no offenses" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"

          depends_on "pkg-config" => :build

          def install
          end
        end
      RUBY
    end
  end

  context "when formula has OS-specific block(s)" do
    it "reports no offenses when `on_macos` and `on_linux` are used correctly" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"

          depends_on "pkg-config" => :build

          uses_from_macos "libxml2"

          on_macos do
            depends_on "perl"

            resource "resource1" do
              url "https://brew.sh/resource1.tar.gz"
              sha256 "a2f5650770e1c87fb335af19a9b7eb73fc05ccf22144eb68db7d00cd2bcb0902"

              patch do
                url "https://raw.githubusercontent.com/Homebrew/formula-patches/0ae366e6/patch3.diff"
                sha256 "89fa3c95c329ec326e2e76493471a7a974c673792725059ef121e6f9efb05bf4"
              end
            end

            resource "resource2" do
              url "https://brew.sh/resource2.tar.gz"
              sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
            end

            patch do
              url "https://raw.githubusercontent.com/Homebrew/formula-patches/0ae366e6/patch1.diff"
              sha256 "89fa3c95c329ec326e2e76493471a7a974c673792725059ef121e6f9efb05bf4"
            end

            patch do
              url "https://raw.githubusercontent.com/Homebrew/formula-patches/0ae366e6/patch2.diff"
              sha256 "89fa3c95c329ec326e2e76493471a7a974c673792725059ef121e6f9efb05bf4"
            end
          end

          on_linux do
            depends_on "readline"
          end

          def install
          end
        end
      RUBY
    end

    it "reports no offenses when `on_macos` is used correctly" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"

          on_macos do
            disable! because: :does_not_build
            depends_on "readline"
          end

          def install
          end
        end
      RUBY
    end

    it "reports no offenses when `on_linux` is used correctly" do
      expect_no_offenses(<<~RUBY)
        class Foo < Formula
          homepage "https://brew.sh"

          on_linux do
            deprecate! because: "it's deprecated"
            depends_on "readline"
          end

          def install
          end
        end
      RUBY
    end

    it "reports an offense when there are multiple `on_macos` blocks" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_macos do
            depends_on "readline"
          end

          on_macos do
          ^^^^^^^^^^^ there can only be one `on_macos` block in a formula.
            depends_on "foo"
          end
        end
      RUBY
    end

    it "reports an offense when there are multiple `on_linux` blocks" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_linux do
            depends_on "readline"
          end

          on_linux do
          ^^^^^^^^^^^ there can only be one `on_linux` block in a formula.
            depends_on "foo"
          end
        end
      RUBY
    end

    it "reports an offense when the `on_macos` block contains nodes other than `depends_on`, `patch` or `resource`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_macos do
            depends_on "readline"
            uses_from_macos "ncurses"
            ^^^^^^^^^^^^^^^^^^^^^^^^^ `on_macos` cannot include `uses_from_macos`. [...]
          end
        end
      RUBY
    end

    it "reports an offense when the `on_linux` block contains nodes other than `depends_on`, `patch` or `resource`" do
      expect_offense(<<~RUBY)
        class Foo < Formula
          url "https://brew.sh/foo-1.0.tgz"
          on_linux do
            depends_on "readline"
            uses_from_macos "ncurses"
            ^^^^^^^^^^^^^^^^^^^^^^^^^ `on_linux` cannot include `uses_from_macos`. [...]
          end
        end
      RUBY
    end

    context "when in a resource block" do
      it "reports no offenses for a valid `on_macos` and `on_linux` block" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            homepage "https://brew.sh"

            resource do
              on_macos do
                url "https://brew.sh/resource1.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports no offenses for a valid `on_macos` and `on_linux` block (with `version`)" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            homepage "https://brew.sh"

            resource do
              on_macos do
                url "https://brew.sh/resource1.tar.gz"
                version "1.2.3"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                version "1.2.3"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports an offense if there are two `on_macos` blocks" do
        expect_offense(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
            ^^^^^^^^^^^ there can only be one `on_macos` block in a resource block.
              on_macos do
                url "https://brew.sh/resource1.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_macos do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports an offense if there are two `on_linux` blocks" do
        expect_offense(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
            ^^^^^^^^^^^ there can only be one `on_linux` block in a resource block.
              on_linux do
                url "https://brew.sh/resource1.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports no offenses if there is an `on_macos` block but no `on_linux` block" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"
            resource do
              on_macos do
                url "https://brew.sh/resource1.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports no offenses if there is an `on_linux` block but no `on_macos` block" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"
            resource do
              on_linux do
                url "https://brew.sh/resource1.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports an offense if the content of an `on_macos` block is improperly formatted" do
        expect_offense(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
              ^^^^^^^^^^^ `on_macos` blocks within `resource` blocks must contain at least `url` and `sha256` and at most `url`, `mirror`, `version` and `sha256` (in order).
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                url "https://brew.sh/resource2.tar.gz"
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports no offenses if the content of an `on_macos` block in a resource contains a mirror" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
                url "https://brew.sh/resource2.tar.gz"
                mirror "https://brew.sh/mirror/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports no offenses if an `on_macos` block has if-else branches that are properly formatted" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
                if foo == :bar
                  url "https://brew.sh/resource2.tar.gz"
                  sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                else
                  url "https://brew.sh/resource1.tar.gz"
                  sha256 "686372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                end
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports an offense if an `on_macos` block has if-else branches that aren't properly formatted" do
        expect_offense(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
              ^^^^^^^^^^^ `on_macos` blocks within `resource` blocks must contain at least `url` and `sha256` and at most `url`, `mirror`, `version` and `sha256` (in order).
                if foo == :bar
                  url "https://brew.sh/resource2.tar.gz"
                  sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                else
                  sha256 "686372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                  url "https://brew.sh/resource1.tar.gz"
                end
              end

              on_linux do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end
            end
          end
        RUBY
      end

      it "reports an offense if the content of an `on_linux` block is improperly formatted" do
        expect_offense(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
              ^^^^^^^^^^^ `on_linux` blocks within `resource` blocks must contain at least `url` and `sha256` and at most `url`, `mirror`, `version` and `sha256` (in order).
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                url "https://brew.sh/resource2.tar.gz"
              end
            end
          end
        RUBY
      end

      it "reports no offenses if an `on_linux` block has if-else branches that are properly formatted" do
        expect_no_offenses(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
                if foo == :bar
                  url "https://brew.sh/resource2.tar.gz"
                  sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                else
                  url "https://brew.sh/resource1.tar.gz"
                  sha256 "686372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                end
              end
            end
          end
        RUBY
      end

      it "reports an offense if an `on_linux` block has if-else branches that aren't properly formatted" do
        expect_offense(<<~RUBY)
          class Foo < Formula
            url "https://brew.sh/foo-1.0.tgz"

            resource do
              on_macos do
                url "https://brew.sh/resource2.tar.gz"
                sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
              end

              on_linux do
              ^^^^^^^^^^^ `on_linux` blocks within `resource` blocks must contain at least `url` and `sha256` and at most `url`, `mirror`, `version` and `sha256` (in order).
                if foo == :bar
                  url "https://brew.sh/resource2.tar.gz"
                  sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                else
                  sha256 "686372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
                  url "https://brew.sh/resource1.tar.gz"
                end
              end
            end
          end
        RUBY
      end
    end
  end
end

# Fish shell completions for Homebrew

# A note about aliases:
#
# * When defining completions for the (sub)commands themselves, only the full names are used, as they
#   are more descriptive and worth completing. Aliases are usually shorter than the full names, and
#   exist exactly to save time for users who already know what they want and are going to type the
#   command anyway (i.e. without completion).
# * Nevertheless, it's important to support aliases in the completions for their arguments/options.

##########################
## COMMAND LINE PARSING ##
##########################

function __fish_brew_args -d "Returns a list of all arguments given to brew"

    set -l tokens (commandline -opc)
    set -e tokens[1] # remove 'brew'
    for t in $tokens
        echo $t
    end
end

function __fish_brew_opts -d "Only arguments starting with a dash (options)"
    string match --all -- '-*' (__fish_brew_args)
end

# This can be used either to get the first argument or to match it against a given list of commands
#
# Usage examples (for `completion -n '...'`):
# * `__fish_brew_command` returns the command (first arg of brew) or exits with 1
# * `not __fish_brew_command` returns true when brew doesn't have a command yet
# * `__fish_brew_command list ls` returns true when brew command is _either_ `list` _or_ `ls`
#
function __fish_brew_command -d "Helps matching the first argument of brew"
    set args (__fish_brew_args)
    set -q args[1]; or return 1

    if count $argv
        contains -- $args[1] $argv
    else
        echo $args[1]
    end
end

function __fish_brew_subcommand -a cmd -d "Helps matching the second argument of brew"
    set args (__fish_brew_args)

    __fish_brew_command $cmd
    and set -q args[2]
    and set -l sub $args[2]
    or return 1

    set -e argv[1]
    if count $argv
        contains -- $sub $argv
    else
        echo $sub
    end
end

# This can be used to match any given option against the given list of arguments:
# * to add condition on interdependent options
# * to add condition on mutually exclusive options
#
# Usage examples (for `completion -n '...'`):
# * `__fish_brew_opt -s --long` returns true if _either_ `-s` _or_ `--long` is present
# * `not __fish_brew_opt --foo --bar` will work only if _neither_ `--foo` _nor_ `--bar` are present
#
function __fish_brew_opt -d "Helps matching brew options against the given list"

    not count $argv
    or contains -- $argv[1] (__fish_brew_opts)
    or begin
        set -q argv[2]
        and __fish_brew_opt $argv[2..-1]
    end
end


######################
## SUGGESTION LISTS ##
######################
# These functions return lists of suggestions for arguments completion

function __fish_brew_ruby_parse_json -a file parser -d 'Parses given JSON file with Ruby'
    # parser is any chain of methods to call on the parsed JSON
    ruby -e "require('json'); JSON.parse(File.read('$file'))$parser"
end

function __fish_brew_suggest_formulae_all -d 'Lists all available formulae with their descriptions'
    # store the brew cache path in a var (because calling (brew --cache) is slow)
    set -q __brew_cache_path
    or set -gx __brew_cache_path (brew --cache)

    if test -f "$__brew_cache_path/descriptions.json"
        __fish_brew_ruby_parse_json "$__brew_cache_path/descriptions.json" \
            '.each{ |k, v| puts([k, v].reject(&:nil?).join("\t")) }'
    else
        brew formulae
    end
end

function __fish_brew_suggest_formulae_installed
    brew list --formula
end

function __fish_brew_suggest_formulae_outdated -d "List of outdated formulae with the information about potential upgrade"
    brew outdated --formula --verbose \
        # replace first space with tab to make the following a description in the completions list:
        | string replace -r '\s' '\t'
end

function __fish_brew_suggest_formula_options -a formula -d "List installation options for a given formula"
    function list_pairs
        set -q argv[2]; or return 0
        echo $argv[1]\t$argv[2]
        set -e argv[1..2]
        list_pairs $argv
    end

    # brew options lists options name and its description on different lines
    list_pairs (brew options $formula | string trim)
end

function __fish_brew_suggest_casks_all -d "Lists locally available casks"
    brew casks
end

function __fish_brew_suggest_casks_installed -d "Lists installed casks"
    brew list --cask -1
end

function __fish_brew_suggest_casks_outdated -d "Lists outdated casks with the information about potential upgrade"
    brew outdated --cask --verbose \
        # replace first space with tab to make the following a description in the completions list:
        | string replace -r '\s' '\t'
end

function __fish_brew_suggest_taps_installed -d "List all available taps"
    brew tap
end

function __fish_brew_suggest_commands -d "Lists all commands names, including aliases"
    if test -f (brew --cache)/all_commands_list.txt
        cat (brew --cache)/all_commands_list.txt | \grep -v instal\$
    else
        cat (brew --repo)/completions/internal_commands_list.txt | \grep -v instal\$
    end
end

function __fish_brew_suggest_diagnostic_check -d "List available diagnostic checks"
    brew doctor --list-checks
end

# TODO: any better way to list available services?
function __fish_brew_suggest_services -d "Lists available services"
    set -l list (brew services list)
    set -e list[1] # Header
    for line in $list
        echo (string split ' ' $line)[1]
    end
end


##########################
## COMPLETION SHORTCUTS ##
##########################

function __fish_brew_complete_cmd -a cmd -d "A shortcut for defining brew commands completions"
    set -e argv[1]
    complete -f -c brew -n 'not __fish_brew_command' -a $cmd -d $argv
end

function __fish_brew_complete_arg -a cond -d "A shortcut for defining arguments completion for brew commands"
    set -e argv[1]
    # NOTE: $cond can be just a name of a command (or several) or additionally any other condition
    complete -f -c brew -n "__fish_brew_command $cond" $argv
end

function __fish_brew_complete_sub_cmd -a cmd sub -d "A shortcut for defining brew subcommands completions"
    set -e argv[1..2]
    if count $argv > /dev/null
        __fish_brew_complete_arg "$cmd; and [ (count (__fish_brew_args)) = 1 ]" -a $sub -d $argv
    else
        __fish_brew_complete_arg "$cmd; and [ (count (__fish_brew_args)) = 1 ]" -a $sub
    end
end

function __fish_brew_complete_sub_arg -a cmd sub -d "A shortcut for defining brew subcommand arguments completions"
    set -e argv[1..2]
    # NOTE: $sub can be just a name of a subcommand (or several) or additionally any other condition
    complete -f -c brew -n "__fish_brew_subcommand $cmd $sub" $argv
end


##############
## COMMANDS ##
##############


__fish_brew_complete_cmd '--cache' 'Display Homebrew\'s download cache'
__fish_brew_complete_arg '--cache' -l build-from-source -d 'Show the cache file used when building from source'
__fish_brew_complete_arg '--cache' -l cask -d 'Only show cache files for casks'
__fish_brew_complete_arg '--cache' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--cache' -l force-bottle -d 'Show the cache file used when pouring a bottle'
__fish_brew_complete_arg '--cache' -l formula -d 'Only show cache files for formulae'
__fish_brew_complete_arg '--cache' -l help -d 'Show this message'
__fish_brew_complete_arg '--cache' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--cache' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--cache; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg '--cache; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd '--caskroom' 'Display Homebrew\'s Caskroom path'
__fish_brew_complete_arg '--caskroom' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--caskroom' -l help -d 'Show this message'
__fish_brew_complete_arg '--caskroom' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--caskroom' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--caskroom' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd '--cellar' 'Display Homebrew\'s Cellar path'
__fish_brew_complete_arg '--cellar' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--cellar' -l help -d 'Show this message'
__fish_brew_complete_arg '--cellar' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--cellar' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--cellar' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd '--config' 'Show Homebrew and system configuration info useful for debugging'
__fish_brew_complete_arg '--config' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--config' -l help -d 'Show this message'
__fish_brew_complete_arg '--config' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--config' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd '--env' 'Summarise Homebrew\'s build environment as a plain list'
__fish_brew_complete_arg '--env' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--env' -l help -d 'Show this message'
__fish_brew_complete_arg '--env' -l plain -d 'Generate plain output even when piped'
__fish_brew_complete_arg '--env' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--env' -l shell -d 'Generate a list of environment variables for the specified shell, or `--shell=auto` to detect the current shell'
__fish_brew_complete_arg '--env' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--env' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd '--prefix' 'Display Homebrew\'s install path'
__fish_brew_complete_arg '--prefix' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--prefix' -l help -d 'Show this message'
__fish_brew_complete_arg '--prefix' -l installed -d 'Outputs nothing and returns a failing status code if formula is not installed'
__fish_brew_complete_arg '--prefix' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--prefix' -l unbrewed -d 'List files in Homebrew\'s prefix not installed by Homebrew'
__fish_brew_complete_arg '--prefix' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--prefix' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd '--repo' 'Display where Homebrew\'s git repository is located'
__fish_brew_complete_arg '--repo' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--repo' -l help -d 'Show this message'
__fish_brew_complete_arg '--repo' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--repo' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--repo' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd '--repository' 'Display where Homebrew\'s git repository is located'
__fish_brew_complete_arg '--repository' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '--repository' -l help -d 'Show this message'
__fish_brew_complete_arg '--repository' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '--repository' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg '--repository' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd '-S' 'Perform a substring search of cask tokens and formula names for text'
__fish_brew_complete_arg '-S' -l cask -d 'Search online and locally for casks'
__fish_brew_complete_arg '-S' -l closed -d 'Search for only closed GitHub pull requests'
__fish_brew_complete_arg '-S' -l debian -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg '-S' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg '-S' -l desc -d 'Search for formulae with a description matching text and casks with a name matching text'
__fish_brew_complete_arg '-S' -l fedora -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg '-S' -l fink -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg '-S' -l formula -d 'Search online and locally for formulae'
__fish_brew_complete_arg '-S' -l help -d 'Show this message'
__fish_brew_complete_arg '-S' -l macports -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg '-S' -l open -d 'Search for only open GitHub pull requests'
__fish_brew_complete_arg '-S' -l opensuse -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg '-S' -l pull-request -d 'Search for GitHub pull requests containing text'
__fish_brew_complete_arg '-S' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg '-S' -l ubuntu -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg '-S' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'abv' 'Display brief statistics for your Homebrew installation'
__fish_brew_complete_arg 'abv' -l all -d 'Print JSON of all available formulae'
__fish_brew_complete_arg 'abv' -l analytics -d 'List global Homebrew analytics data or, if specified, installation and build error data for formula (provided neither `HOMEBREW_NO_ANALYTICS` nor `HOMEBREW_NO_GITHUB_API` are set)'
__fish_brew_complete_arg 'abv' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'abv' -l category -d 'Which type of analytics data to retrieve. The value for category must be `install`, `install-on-request` or `build-error`; `cask-install` or `os-version` may be specified if formula is not. The default is `install`'
__fish_brew_complete_arg 'abv' -l days -d 'How many days of analytics data to retrieve. The value for days must be `30`, `90` or `365`. The default is `30`'
__fish_brew_complete_arg 'abv' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'abv' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'abv' -l github -d 'Open the GitHub source page for formula in a browser. To view formula history locally: `brew log -p` formula'
__fish_brew_complete_arg 'abv' -l help -d 'Show this message'
__fish_brew_complete_arg 'abv' -l installed -d 'Print JSON of formulae that are currently installed'
__fish_brew_complete_arg 'abv' -l json -d 'Print a JSON representation. Currently the default value for version is `v1` for formula. For formula and cask use `v2`. See the docs for examples of using the JSON output: https://docs.brew.sh/Querying-Brew'
__fish_brew_complete_arg 'abv' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'abv' -l verbose -d 'Show more verbose analytics data for formula'
__fish_brew_complete_arg 'abv; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'abv; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'analytics' 'Control Homebrew\'s anonymous aggregate user behaviour analytics'
__fish_brew_complete_sub_cmd 'analytics' 'state'
__fish_brew_complete_sub_cmd 'analytics' 'on'
__fish_brew_complete_sub_cmd 'analytics' 'off'
__fish_brew_complete_sub_cmd 'analytics' 'regenerate-uuid'
__fish_brew_complete_arg 'analytics' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'analytics' -l help -d 'Show this message'
__fish_brew_complete_arg 'analytics' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'analytics' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'audit' 'Check formula for Homebrew coding style violations'
__fish_brew_complete_arg 'audit' -l appcast -d 'Audit the appcast'
__fish_brew_complete_arg 'audit' -l audit-debug -d 'Enable debugging and profiling of audit methods'
__fish_brew_complete_arg 'audit' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'audit' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'audit' -l display-cop-names -d 'Include the RuboCop cop name for each violation in the output'
__fish_brew_complete_arg 'audit' -l display-failures-only -d 'Only display casks that fail the audit. This is the default for formulae'
__fish_brew_complete_arg 'audit' -l display-filename -d 'Prefix every line of output with the file or formula name being audited, to make output easy to grep'
__fish_brew_complete_arg 'audit' -l except -d 'Specify a comma-separated method list to skip running the methods named `audit_`method'
__fish_brew_complete_arg 'audit' -l except-cops -d 'Specify a comma-separated cops list to skip checking for violations of the listed RuboCop cops'
__fish_brew_complete_arg 'audit' -l fix -d 'Fix style violations automatically using RuboCop\'s auto-correct feature'
__fish_brew_complete_arg 'audit' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'audit' -l git -d 'Run additional, slower style checks that navigate the Git repository'
__fish_brew_complete_arg 'audit' -l help -d 'Show this message'
__fish_brew_complete_arg 'audit' -l new -d 'Run various additional style checks to determine if a new formula or cask is eligible for Homebrew. This should be used when creating new formula and implies `--strict` and `--online`'
__fish_brew_complete_arg 'audit' -l no-appcast -d 'Audit the appcast'
__fish_brew_complete_arg 'audit' -l online -d 'Run additional, slower style checks that require a network connection'
__fish_brew_complete_arg 'audit' -l only -d 'Specify a comma-separated method list to only run the methods named `audit_`method'
__fish_brew_complete_arg 'audit' -l only-cops -d 'Specify a comma-separated cops list to check for violations of only the listed RuboCop cops'
__fish_brew_complete_arg 'audit' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'audit' -l skip-style -d 'Skip running non-RuboCop style checks. Useful if you plan on running `brew style` separately. Enabled by default unless a formula is specified by name'
__fish_brew_complete_arg 'audit' -l strict -d 'Run additional, stricter style checks'
__fish_brew_complete_arg 'audit' -l tap -d 'Check the formulae within the given tap, specified as user`/`repo'
__fish_brew_complete_arg 'audit' -l token-conflicts -d 'Audit for token conflicts'
__fish_brew_complete_arg 'audit' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'audit; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'audit; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'autoremove' 'Uninstall formulae that were only installed as a dependency of another formula and are now no longer needed'
__fish_brew_complete_arg 'autoremove' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'autoremove' -l dry-run -d 'List what would be uninstalled, but do not actually uninstall anything'
__fish_brew_complete_arg 'autoremove' -l help -d 'Show this message'
__fish_brew_complete_arg 'autoremove' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'autoremove' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'bottle' 'Generate a bottle (binary package) from a formula that was installed with `--build-bottle`'
__fish_brew_complete_arg 'bottle' -l committer -d 'Specify a committer name and email in `git`\'s standard author format'
__fish_brew_complete_arg 'bottle' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'bottle' -l force-core-tap -d 'Build a bottle even if formula is not in `homebrew/core` or any installed taps'
__fish_brew_complete_arg 'bottle' -l help -d 'Show this message'
__fish_brew_complete_arg 'bottle' -l json -d 'Write bottle information to a JSON file, which can be used as the value for `--merge`'
__fish_brew_complete_arg 'bottle' -l keep-old -d 'If the formula specifies a rebuild version, attempt to preserve its value in the generated DSL'
__fish_brew_complete_arg 'bottle' -l merge -d 'Generate an updated bottle block for a formula and optionally merge it into the formula file. Instead of a formula name, requires the path to a JSON file generated with `brew bottle --json` formula'
__fish_brew_complete_arg 'bottle' -l no-commit -d 'When passed with `--write`, a new commit will not generated after writing changes to the formula file'
__fish_brew_complete_arg 'bottle' -l no-rebuild -d 'If the formula specifies a rebuild version, remove it from the generated DSL'
__fish_brew_complete_arg 'bottle' -l only-json-tab -d 'When passed with `--json`, the tab will be written to the JSON file but not the bottle'
__fish_brew_complete_arg 'bottle' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'bottle' -l root-url -d 'Use the specified URL as the root of the bottle\'s URL instead of Homebrew\'s default'
__fish_brew_complete_arg 'bottle' -l root-url-using -d 'Use the specified download strategy class for downloading the bottle\'s URL instead of Homebrew\'s default'
__fish_brew_complete_arg 'bottle' -l skip-relocation -d 'Do not check if the bottle can be marked as relocatable'
__fish_brew_complete_arg 'bottle' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'bottle' -l write -d 'Write changes to the formula file. A new commit will be generated unless `--no-commit` is passed'
__fish_brew_complete_arg 'bottle' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'bump' 'Display out-of-date brew formulae and the latest version available'
__fish_brew_complete_arg 'bump' -l cask -d 'Check only casks'
__fish_brew_complete_arg 'bump' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'bump' -l formula -d 'Check only formulae'
__fish_brew_complete_arg 'bump' -l full-name -d 'Print formulae/casks with fully-qualified names'
__fish_brew_complete_arg 'bump' -l help -d 'Show this message'
__fish_brew_complete_arg 'bump' -l limit -d 'Limit number of package results returned'
__fish_brew_complete_arg 'bump' -l no-pull-requests -d 'Do not retrieve pull requests from GitHub'
__fish_brew_complete_arg 'bump' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'bump' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'bump; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'bump; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'bump-cask-pr' 'Create a pull request to update cask with a new version'
__fish_brew_complete_arg 'bump-cask-pr' -l commit -d 'When passed with `--write`, generate a new commit after writing changes to the cask file'
__fish_brew_complete_arg 'bump-cask-pr' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'bump-cask-pr' -l dry-run -d 'Print what would be done rather than doing it'
__fish_brew_complete_arg 'bump-cask-pr' -l force -d 'Ignore duplicate open PRs'
__fish_brew_complete_arg 'bump-cask-pr' -l fork-org -d 'Use the specified GitHub organization for forking'
__fish_brew_complete_arg 'bump-cask-pr' -l help -d 'Show this message'
__fish_brew_complete_arg 'bump-cask-pr' -l message -d 'Append message to the default pull request message'
__fish_brew_complete_arg 'bump-cask-pr' -l no-audit -d 'Don\'t run `brew audit` before opening the PR'
__fish_brew_complete_arg 'bump-cask-pr' -l no-browse -d 'Print the pull request URL instead of opening in a browser'
__fish_brew_complete_arg 'bump-cask-pr' -l no-fork -d 'Don\'t try to fork the repository'
__fish_brew_complete_arg 'bump-cask-pr' -l no-style -d 'Don\'t run `brew style --fix` before opening the PR'
__fish_brew_complete_arg 'bump-cask-pr' -l online -d 'Run `brew audit --online` before opening the PR'
__fish_brew_complete_arg 'bump-cask-pr' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'bump-cask-pr' -l sha256 -d 'Specify the SHA-256 checksum of the new download'
__fish_brew_complete_arg 'bump-cask-pr' -l url -d 'Specify the URL for the new download'
__fish_brew_complete_arg 'bump-cask-pr' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'bump-cask-pr' -l version -d 'Specify the new version for the cask'
__fish_brew_complete_arg 'bump-cask-pr' -l write -d 'Make the expected file modifications without taking any Git actions'
__fish_brew_complete_arg 'bump-cask-pr' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'bump-formula-pr' 'Create a pull request to update formula with a new URL or a new tag'
__fish_brew_complete_arg 'bump-formula-pr' -l commit -d 'When passed with `--write`, generate a new commit after writing changes to the formula file'
__fish_brew_complete_arg 'bump-formula-pr' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'bump-formula-pr' -l dry-run -d 'Print what would be done rather than doing it'
__fish_brew_complete_arg 'bump-formula-pr' -l force -d 'Ignore duplicate open PRs. Remove all mirrors if `--mirror` was not specified'
__fish_brew_complete_arg 'bump-formula-pr' -l fork-org -d 'Use the specified GitHub organization for forking'
__fish_brew_complete_arg 'bump-formula-pr' -l help -d 'Show this message'
__fish_brew_complete_arg 'bump-formula-pr' -l message -d 'Append message to the default pull request message'
__fish_brew_complete_arg 'bump-formula-pr' -l mirror -d 'Use the specified URL as a mirror URL. If URL is a comma-separated list of URLs, multiple mirrors will be added'
__fish_brew_complete_arg 'bump-formula-pr' -l no-audit -d 'Don\'t run `brew audit` before opening the PR'
__fish_brew_complete_arg 'bump-formula-pr' -l no-browse -d 'Print the pull request URL instead of opening in a browser'
__fish_brew_complete_arg 'bump-formula-pr' -l no-fork -d 'Don\'t try to fork the repository'
__fish_brew_complete_arg 'bump-formula-pr' -l online -d 'Run `brew audit --online` before opening the PR'
__fish_brew_complete_arg 'bump-formula-pr' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'bump-formula-pr' -l revision -d 'Specify the new commit revision corresponding to the specified git tag or specified version'
__fish_brew_complete_arg 'bump-formula-pr' -l sha256 -d 'Specify the SHA-256 checksum of the new download'
__fish_brew_complete_arg 'bump-formula-pr' -l strict -d 'Run `brew audit --strict` before opening the PR'
__fish_brew_complete_arg 'bump-formula-pr' -l tag -d 'Specify the new git commit tag for the formula'
__fish_brew_complete_arg 'bump-formula-pr' -l url -d 'Specify the URL for the new download. If a URL is specified, the SHA-256 checksum of the new download should also be specified'
__fish_brew_complete_arg 'bump-formula-pr' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'bump-formula-pr' -l version -d 'Use the specified version to override the value parsed from the URL or tag. Note that `--version=0` can be used to delete an existing version override from a formula if it has become redundant'
__fish_brew_complete_arg 'bump-formula-pr' -l write -d 'Make the expected file modifications without taking any Git actions'
__fish_brew_complete_arg 'bump-formula-pr' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'bump-revision' 'Create a commit to increment the revision of formula'
__fish_brew_complete_arg 'bump-revision' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'bump-revision' -l dry-run -d 'Print what would be done rather than doing it'
__fish_brew_complete_arg 'bump-revision' -l help -d 'Show this message'
__fish_brew_complete_arg 'bump-revision' -l message -d 'Append message to the default commit message'
__fish_brew_complete_arg 'bump-revision' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'bump-revision' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'bump-revision' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'bump-unversioned-casks' 'Check all casks with unversioned URLs in a given tap for updates'
__fish_brew_complete_arg 'bump-unversioned-casks' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'bump-unversioned-casks' -l dry-run -d 'Do everything except caching state and opening pull requests'
__fish_brew_complete_arg 'bump-unversioned-casks' -l help -d 'Show this message'
__fish_brew_complete_arg 'bump-unversioned-casks' -l limit -d 'Maximum runtime in minutes'
__fish_brew_complete_arg 'bump-unversioned-casks' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'bump-unversioned-casks' -l state-file -d 'File for caching state'
__fish_brew_complete_arg 'bump-unversioned-casks' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'bump-unversioned-casks' -a '(__fish_brew_suggest_casks_all)'
__fish_brew_complete_arg 'bump-unversioned-casks' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'cat' 'Display the source of a formula or cask'
__fish_brew_complete_arg 'cat' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'cat' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'cat' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'cat' -l help -d 'Show this message'
__fish_brew_complete_arg 'cat' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'cat' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'cat; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'cat; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'cleanup' 'Remove stale lock files and outdated downloads for all formulae and casks, and remove old versions of installed formulae'
__fish_brew_complete_arg 'cleanup' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'cleanup' -l dry-run -d 'Show what would be removed, but do not actually remove anything'
__fish_brew_complete_arg 'cleanup' -l help -d 'Show this message'
__fish_brew_complete_arg 'cleanup' -l prune -d 'Remove all cache files older than specified days. If you want to remove everything, use `--prune=all`'
__fish_brew_complete_arg 'cleanup' -l prune-prefix -d 'Only prune the symlinks and directories from the prefix and remove no other files'
__fish_brew_complete_arg 'cleanup' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'cleanup' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'cleanup' -l s -d 'Scrub the cache, including downloads for even the latest versions. Note downloads for any installed formulae or casks will still not be deleted. If you want to delete those too: `rm -rf "$(brew --cache)"`'
__fish_brew_complete_arg 'cleanup' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'cleanup' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'command' 'Display the path to the file being used when invoking `brew` cmd'
__fish_brew_complete_arg 'command' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'command' -l help -d 'Show this message'
__fish_brew_complete_arg 'command' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'command' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'command' -a '(__fish_brew_suggest_commands)'


__fish_brew_complete_cmd 'commands' 'Show lists of built-in and external commands'
__fish_brew_complete_arg 'commands' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'commands' -l help -d 'Show this message'
__fish_brew_complete_arg 'commands' -l include-aliases -d 'Include aliases of internal commands'
__fish_brew_complete_arg 'commands' -l quiet -d 'List only the names of commands without category headers'
__fish_brew_complete_arg 'commands' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'completions' 'Control whether Homebrew automatically links external tap shell completion files'
__fish_brew_complete_sub_cmd 'completions' 'state'
__fish_brew_complete_sub_cmd 'completions' 'link'
__fish_brew_complete_sub_cmd 'completions' 'unlink'
__fish_brew_complete_arg 'completions' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'completions' -l help -d 'Show this message'
__fish_brew_complete_arg 'completions' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'completions' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'config' 'Show Homebrew and system configuration info useful for debugging'
__fish_brew_complete_arg 'config' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'config' -l help -d 'Show this message'
__fish_brew_complete_arg 'config' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'config' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'create' 'Generate a formula or, with `--cask`, a cask for the downloadable file at URL and open it in the editor'
__fish_brew_complete_arg 'create' -l HEAD -d 'Indicate that URL points to the package\'s repository rather than a file'
__fish_brew_complete_arg 'create' -l autotools -d 'Create a basic template for an Autotools-style build'
__fish_brew_complete_arg 'create' -l cask -d 'Create a basic template for a cask'
__fish_brew_complete_arg 'create' -l cmake -d 'Create a basic template for a CMake-style build'
__fish_brew_complete_arg 'create' -l crystal -d 'Create a basic template for a Crystal build'
__fish_brew_complete_arg 'create' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'create' -l force -d 'Ignore errors for disallowed formula names and names that shadow aliases'
__fish_brew_complete_arg 'create' -l go -d 'Create a basic template for a Go build'
__fish_brew_complete_arg 'create' -l help -d 'Show this message'
__fish_brew_complete_arg 'create' -l meson -d 'Create a basic template for a Meson-style build'
__fish_brew_complete_arg 'create' -l no-fetch -d 'Homebrew will not download URL to the cache and will thus not add its SHA-256 to the formula for you, nor will it check the GitHub API for GitHub projects (to fill out its description and homepage)'
__fish_brew_complete_arg 'create' -l node -d 'Create a basic template for a Node build'
__fish_brew_complete_arg 'create' -l perl -d 'Create a basic template for a Perl build'
__fish_brew_complete_arg 'create' -l python -d 'Create a basic template for a Python build'
__fish_brew_complete_arg 'create' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'create' -l ruby -d 'Create a basic template for a Ruby build'
__fish_brew_complete_arg 'create' -l rust -d 'Create a basic template for a Rust build'
__fish_brew_complete_arg 'create' -l set-license -d 'Explicitly set the license of the new formula'
__fish_brew_complete_arg 'create' -l set-name -d 'Explicitly set the name of the new formula or cask'
__fish_brew_complete_arg 'create' -l set-version -d 'Explicitly set the version of the new formula or cask'
__fish_brew_complete_arg 'create' -l tap -d 'Generate the new formula within the given tap, specified as user`/`repo'
__fish_brew_complete_arg 'create' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'deps' 'Show dependencies for formula'
__fish_brew_complete_arg 'deps' -l 1 -d 'Only show dependencies one level down, instead of recursing'
__fish_brew_complete_arg 'deps' -l all -d 'List dependencies for all available formulae'
__fish_brew_complete_arg 'deps' -l annotate -d 'Mark any build, test, optional, or recommended dependencies as such in the output'
__fish_brew_complete_arg 'deps' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'deps' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'deps' -l for-each -d 'Switch into the mode used by the `--all` option, but only list dependencies for each provided formula, one formula per line. This is used for debugging the `--installed`/`--all` display mode'
__fish_brew_complete_arg 'deps' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'deps' -l full-name -d 'List dependencies by their full name'
__fish_brew_complete_arg 'deps' -l help -d 'Show this message'
__fish_brew_complete_arg 'deps' -l include-build -d 'Include `:build` dependencies for formula'
__fish_brew_complete_arg 'deps' -l include-optional -d 'Include `:optional` dependencies for formula'
__fish_brew_complete_arg 'deps' -l include-requirements -d 'Include requirements in addition to dependencies for formula'
__fish_brew_complete_arg 'deps' -l include-test -d 'Include `:test` dependencies for formula (non-recursive)'
__fish_brew_complete_arg 'deps' -l installed -d 'List dependencies for formulae that are currently installed. If formula is specified, list only its dependencies that are currently installed'
__fish_brew_complete_arg 'deps' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'deps' -l skip-recommended -d 'Skip `:recommended` dependencies for formula'
__fish_brew_complete_arg 'deps' -l tree -d 'Show dependencies as a tree. When given multiple formula arguments, show individual trees for each formula'
__fish_brew_complete_arg 'deps' -l union -d 'Show the union of dependencies for multiple formula, instead of the intersection'
__fish_brew_complete_arg 'deps' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'deps' -l n -d 'Sort dependencies in topological order'
__fish_brew_complete_arg 'deps; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'deps; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'desc' 'Display formula\'s name and one-line description'
__fish_brew_complete_arg 'desc' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'desc' -l description -d 'Search just descriptions for text. If text is flanked by slashes, it is interpreted as a regular expression'
__fish_brew_complete_arg 'desc' -l help -d 'Show this message'
__fish_brew_complete_arg 'desc' -l name -d 'Search just names for text. If text is flanked by slashes, it is interpreted as a regular expression'
__fish_brew_complete_arg 'desc' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'desc' -l search -d 'Search both names and descriptions for text. If text is flanked by slashes, it is interpreted as a regular expression'
__fish_brew_complete_arg 'desc' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'desc' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'dispatch-build-bottle' 'Build bottles for these formulae with GitHub Actions'
__fish_brew_complete_arg 'dispatch-build-bottle' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'dispatch-build-bottle' -l help -d 'Show this message'
__fish_brew_complete_arg 'dispatch-build-bottle' -l issue -d 'If specified, post a comment to this issue number if the job fails'
__fish_brew_complete_arg 'dispatch-build-bottle' -l linux -d 'Dispatch bottle for Linux (using GitHub runners)'
__fish_brew_complete_arg 'dispatch-build-bottle' -l macos -d 'Version of macOS the bottle should be built for'
__fish_brew_complete_arg 'dispatch-build-bottle' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'dispatch-build-bottle' -l tap -d 'Target tap repository (default: `homebrew/core`)'
__fish_brew_complete_arg 'dispatch-build-bottle' -l upload -d 'Upload built bottles'
__fish_brew_complete_arg 'dispatch-build-bottle' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'dispatch-build-bottle' -l workflow -d 'Dispatch specified workflow (default: `dispatch-build-bottle.yml`)'
__fish_brew_complete_arg 'dispatch-build-bottle' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'doctor' 'Check your system for potential problems'
__fish_brew_complete_arg 'doctor' -l audit-debug -d 'Enable debugging and profiling of audit methods'
__fish_brew_complete_arg 'doctor' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'doctor' -l help -d 'Show this message'
__fish_brew_complete_arg 'doctor' -l list-checks -d 'List all audit methods, which can be run individually if provided as arguments'
__fish_brew_complete_arg 'doctor' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'doctor' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'doctor' -a '(__fish_brew_suggest_diagnostic_checks)'


__fish_brew_complete_cmd 'dr' 'Check your system for potential problems'
__fish_brew_complete_arg 'dr' -l audit-debug -d 'Enable debugging and profiling of audit methods'
__fish_brew_complete_arg 'dr' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'dr' -l help -d 'Show this message'
__fish_brew_complete_arg 'dr' -l list-checks -d 'List all audit methods, which can be run individually if provided as arguments'
__fish_brew_complete_arg 'dr' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'dr' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'dr' -a '(__fish_brew_suggest_diagnostic_checks)'


__fish_brew_complete_cmd 'edit' 'Open a formula or cask in the editor set by `EDITOR` or `HOMEBREW_EDITOR`, or open the Homebrew repository for editing if no formula is provided'
__fish_brew_complete_arg 'edit' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'edit' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'edit' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'edit' -l help -d 'Show this message'
__fish_brew_complete_arg 'edit' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'edit' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'edit; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'edit; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'environment' 'Summarise Homebrew\'s build environment as a plain list'
__fish_brew_complete_arg 'environment' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'environment' -l help -d 'Show this message'
__fish_brew_complete_arg 'environment' -l plain -d 'Generate plain output even when piped'
__fish_brew_complete_arg 'environment' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'environment' -l shell -d 'Generate a list of environment variables for the specified shell, or `--shell=auto` to detect the current shell'
__fish_brew_complete_arg 'environment' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'environment' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'extract' 'Look through repository history to find the most recent version of formula and create a copy in tap'
__fish_brew_complete_arg 'extract' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'extract' -l force -d 'Overwrite the destination formula if it already exists'
__fish_brew_complete_arg 'extract' -l help -d 'Show this message'
__fish_brew_complete_arg 'extract' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'extract' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'extract' -l version -d 'Extract the specified version of formula instead of the most recent'
__fish_brew_complete_arg 'extract' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'extract' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'fetch' 'Download a bottle (if available) or source packages for formulae and binaries for casks'
__fish_brew_complete_arg 'fetch' -l HEAD -d 'Fetch HEAD version instead of stable version'
__fish_brew_complete_arg 'fetch' -l build-bottle -d 'Download source packages (for eventual bottling) rather than a bottle'
__fish_brew_complete_arg 'fetch' -l build-from-source -d 'Download source packages rather than a bottle'
__fish_brew_complete_arg 'fetch' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'fetch' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'fetch' -l deps -d 'Also download dependencies for any listed formula'
__fish_brew_complete_arg 'fetch' -l force -d 'Remove a previously cached version and re-fetch'
__fish_brew_complete_arg 'fetch' -l force-bottle -d 'Download a bottle if it exists for the current or newest version of macOS, even if it would not be used during installation'
__fish_brew_complete_arg 'fetch' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'fetch' -l help -d 'Show this message'
__fish_brew_complete_arg 'fetch' -l no-quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'fetch' -l quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'fetch' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'fetch' -l retry -d 'Retry if downloading fails or re-download if the checksum of a previously cached version no longer matches'
__fish_brew_complete_arg 'fetch' -l verbose -d 'Do a verbose VCS checkout, if the URL represents a VCS. This is useful for seeing if an existing VCS cache has been updated'
__fish_brew_complete_arg 'fetch; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'fetch; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'formula' 'Display the path where formula is located'
__fish_brew_complete_arg 'formula' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'formula' -l help -d 'Show this message'
__fish_brew_complete_arg 'formula' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'formula' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'formula' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'generate-man-completions' 'Generate Homebrew\'s manpages and shell completions'
__fish_brew_complete_arg 'generate-man-completions' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'generate-man-completions' -l fail-if-not-changed -d 'Return a failing status code if no changes are detected in the manpage outputs. This can be used to notify CI when the manpages are out of date. Additionally, the date used in new manpages will match those in the existing manpages (to allow comparison without factoring in the date)'
__fish_brew_complete_arg 'generate-man-completions' -l help -d 'Show this message'
__fish_brew_complete_arg 'generate-man-completions' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'generate-man-completions' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'gist-logs' 'Upload logs for a failed build of formula to a new Gist'
__fish_brew_complete_arg 'gist-logs' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'gist-logs' -l help -d 'Show this message'
__fish_brew_complete_arg 'gist-logs' -l new-issue -d 'Automatically create a new issue in the appropriate GitHub repository after creating the Gist'
__fish_brew_complete_arg 'gist-logs' -l private -d 'The Gist will be marked private and will not appear in listings but will be accessible with its link'
__fish_brew_complete_arg 'gist-logs' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'gist-logs' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'gist-logs' -l with-hostname -d 'Include the hostname in the Gist'
__fish_brew_complete_arg 'gist-logs' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'home' 'Open a formula or cask\'s homepage in a browser, or open Homebrew\'s own homepage if no argument is provided'
__fish_brew_complete_arg 'home' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'home' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'home' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'home' -l help -d 'Show this message'
__fish_brew_complete_arg 'home' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'home' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'home; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'home; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'homepage' 'Open a formula or cask\'s homepage in a browser, or open Homebrew\'s own homepage if no argument is provided'
__fish_brew_complete_arg 'homepage' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'homepage' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'homepage' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'homepage' -l help -d 'Show this message'
__fish_brew_complete_arg 'homepage' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'homepage' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'homepage; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'homepage; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'info' 'Display brief statistics for your Homebrew installation'
__fish_brew_complete_arg 'info' -l all -d 'Print JSON of all available formulae'
__fish_brew_complete_arg 'info' -l analytics -d 'List global Homebrew analytics data or, if specified, installation and build error data for formula (provided neither `HOMEBREW_NO_ANALYTICS` nor `HOMEBREW_NO_GITHUB_API` are set)'
__fish_brew_complete_arg 'info' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'info' -l category -d 'Which type of analytics data to retrieve. The value for category must be `install`, `install-on-request` or `build-error`; `cask-install` or `os-version` may be specified if formula is not. The default is `install`'
__fish_brew_complete_arg 'info' -l days -d 'How many days of analytics data to retrieve. The value for days must be `30`, `90` or `365`. The default is `30`'
__fish_brew_complete_arg 'info' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'info' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'info' -l github -d 'Open the GitHub source page for formula in a browser. To view formula history locally: `brew log -p` formula'
__fish_brew_complete_arg 'info' -l help -d 'Show this message'
__fish_brew_complete_arg 'info' -l installed -d 'Print JSON of formulae that are currently installed'
__fish_brew_complete_arg 'info' -l json -d 'Print a JSON representation. Currently the default value for version is `v1` for formula. For formula and cask use `v2`. See the docs for examples of using the JSON output: https://docs.brew.sh/Querying-Brew'
__fish_brew_complete_arg 'info' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'info' -l verbose -d 'Show more verbose analytics data for formula'
__fish_brew_complete_arg 'info; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'info; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'instal' 'Install a formula or cask'
__fish_brew_complete_arg 'instal' -l HEAD -d 'If formula defines it, install the HEAD version, aka. master, trunk, unstable'
__fish_brew_complete_arg 'instal' -l appdir -d 'Target location for Applications (default: `/Applications`)'
__fish_brew_complete_arg 'instal' -l audio-unit-plugindir -d 'Target location for Audio Unit Plugins (default: `~/Library/Audio/Plug-Ins/Components`)'
__fish_brew_complete_arg 'instal' -l binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'instal' -l bottle-arch -d 'Optimise bottles for the specified architecture rather than the oldest architecture supported by the version of macOS the bottles are built on'
__fish_brew_complete_arg 'instal' -l build-bottle -d 'Prepare the formula for eventual bottling during installation, skipping any post-install steps'
__fish_brew_complete_arg 'instal' -l build-from-source -d 'Compile formula from source even if a bottle is provided. Dependencies will still be installed from bottles if they are available'
__fish_brew_complete_arg 'instal' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'instal' -l cc -d 'Attempt to compile using the specified compiler, which should be the name of the compiler\'s executable, e.g. `gcc-7` for GCC 7. In order to use LLVM\'s clang, specify `llvm_clang`. To use the Apple-provided clang, specify `clang`. This option will only accept compilers that are provided by Homebrew or bundled with macOS. Please do not file issues if you encounter errors while using this option'
__fish_brew_complete_arg 'instal' -l colorpickerdir -d 'Target location for Color Pickers (default: `~/Library/ColorPickers`)'
__fish_brew_complete_arg 'instal' -l debug -d 'If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory'
__fish_brew_complete_arg 'instal' -l dictionarydir -d 'Target location for Dictionaries (default: `~/Library/Dictionaries`)'
__fish_brew_complete_arg 'instal' -l display-times -d 'Print install times for each formula at the end of the run'
__fish_brew_complete_arg 'instal' -l env -d 'Disabled other than for internal Homebrew use'
__fish_brew_complete_arg 'instal' -l fetch-HEAD -d 'Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository\'s HEAD will only be checked for updates when a new stable or development version has been released'
__fish_brew_complete_arg 'instal' -l fontdir -d 'Target location for Fonts (default: `~/Library/Fonts`)'
__fish_brew_complete_arg 'instal' -l force -d 'Install formulae without checking for previously installed keg-only or non-migrated versions. When installing casks, overwrite existing files (binaries and symlinks are excluded, unless originally from the same cask)'
__fish_brew_complete_arg 'instal' -l force-bottle -d 'Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation'
__fish_brew_complete_arg 'instal' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'instal' -l git -d 'Create a Git repository, useful for creating patches to the software'
__fish_brew_complete_arg 'instal' -l help -d 'Show this message'
__fish_brew_complete_arg 'instal' -l ignore-dependencies -d 'An unsupported Homebrew development flag to skip installing any dependencies of any kind. If the dependencies are not already present, the formula will have issues. If you\'re not developing Homebrew, consider adjusting your PATH rather than using this flag'
__fish_brew_complete_arg 'instal' -l include-test -d 'Install testing dependencies required to run `brew test` formula'
__fish_brew_complete_arg 'instal' -l input-methoddir -d 'Target location for Input Methods (default: `~/Library/Input Methods`)'
__fish_brew_complete_arg 'instal' -l interactive -d 'Download and patch formula, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package'
__fish_brew_complete_arg 'instal' -l internet-plugindir -d 'Target location for Internet Plugins (default: `~/Library/Internet Plug-Ins`)'
__fish_brew_complete_arg 'instal' -l keep-tmp -d 'Retain the temporary files created during installation'
__fish_brew_complete_arg 'instal' -l language -d 'Comma-separated list of language codes to prefer for cask installation. The first matching language is used, otherwise it reverts to the cask\'s default language. The default value is the language of your system'
__fish_brew_complete_arg 'instal' -l mdimporterdir -d 'Target location for Spotlight Plugins (default: `~/Library/Spotlight`)'
__fish_brew_complete_arg 'instal' -l no-binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'instal' -l no-quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'instal' -l only-dependencies -d 'Install the dependencies with specified options but do not install the formula itself'
__fish_brew_complete_arg 'instal' -l prefpanedir -d 'Target location for Preference Panes (default: `~/Library/PreferencePanes`)'
__fish_brew_complete_arg 'instal' -l qlplugindir -d 'Target location for QuickLook Plugins (default: `~/Library/QuickLook`)'
__fish_brew_complete_arg 'instal' -l quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'instal' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'instal' -l require-sha -d 'Require all casks to have a checksum'
__fish_brew_complete_arg 'instal' -l screen-saverdir -d 'Target location for Screen Savers (default: `~/Library/Screen Savers`)'
__fish_brew_complete_arg 'instal' -l servicedir -d 'Target location for Services (default: `~/Library/Services`)'
__fish_brew_complete_arg 'instal' -l skip-cask-deps -d 'Skip installing cask dependencies'
__fish_brew_complete_arg 'instal' -l verbose -d 'Print the verification and postinstall steps'
__fish_brew_complete_arg 'instal' -l vst-plugindir -d 'Target location for VST Plugins (default: `~/Library/Audio/Plug-Ins/VST`)'
__fish_brew_complete_arg 'instal' -l vst3-plugindir -d 'Target location for VST3 Plugins (default: `~/Library/Audio/Plug-Ins/VST3`)'
__fish_brew_complete_arg 'instal; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'instal; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'install' 'Install a formula or cask'
__fish_brew_complete_arg 'install' -l HEAD -d 'If formula defines it, install the HEAD version, aka. master, trunk, unstable'
__fish_brew_complete_arg 'install' -l appdir -d 'Target location for Applications (default: `/Applications`)'
__fish_brew_complete_arg 'install' -l audio-unit-plugindir -d 'Target location for Audio Unit Plugins (default: `~/Library/Audio/Plug-Ins/Components`)'
__fish_brew_complete_arg 'install' -l binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'install' -l bottle-arch -d 'Optimise bottles for the specified architecture rather than the oldest architecture supported by the version of macOS the bottles are built on'
__fish_brew_complete_arg 'install' -l build-bottle -d 'Prepare the formula for eventual bottling during installation, skipping any post-install steps'
__fish_brew_complete_arg 'install' -l build-from-source -d 'Compile formula from source even if a bottle is provided. Dependencies will still be installed from bottles if they are available'
__fish_brew_complete_arg 'install' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'install' -l cc -d 'Attempt to compile using the specified compiler, which should be the name of the compiler\'s executable, e.g. `gcc-7` for GCC 7. In order to use LLVM\'s clang, specify `llvm_clang`. To use the Apple-provided clang, specify `clang`. This option will only accept compilers that are provided by Homebrew or bundled with macOS. Please do not file issues if you encounter errors while using this option'
__fish_brew_complete_arg 'install' -l colorpickerdir -d 'Target location for Color Pickers (default: `~/Library/ColorPickers`)'
__fish_brew_complete_arg 'install' -l debug -d 'If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory'
__fish_brew_complete_arg 'install' -l dictionarydir -d 'Target location for Dictionaries (default: `~/Library/Dictionaries`)'
__fish_brew_complete_arg 'install' -l display-times -d 'Print install times for each formula at the end of the run'
__fish_brew_complete_arg 'install' -l env -d 'Disabled other than for internal Homebrew use'
__fish_brew_complete_arg 'install' -l fetch-HEAD -d 'Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository\'s HEAD will only be checked for updates when a new stable or development version has been released'
__fish_brew_complete_arg 'install' -l fontdir -d 'Target location for Fonts (default: `~/Library/Fonts`)'
__fish_brew_complete_arg 'install' -l force -d 'Install formulae without checking for previously installed keg-only or non-migrated versions. When installing casks, overwrite existing files (binaries and symlinks are excluded, unless originally from the same cask)'
__fish_brew_complete_arg 'install' -l force-bottle -d 'Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation'
__fish_brew_complete_arg 'install' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'install' -l git -d 'Create a Git repository, useful for creating patches to the software'
__fish_brew_complete_arg 'install' -l help -d 'Show this message'
__fish_brew_complete_arg 'install' -l ignore-dependencies -d 'An unsupported Homebrew development flag to skip installing any dependencies of any kind. If the dependencies are not already present, the formula will have issues. If you\'re not developing Homebrew, consider adjusting your PATH rather than using this flag'
__fish_brew_complete_arg 'install' -l include-test -d 'Install testing dependencies required to run `brew test` formula'
__fish_brew_complete_arg 'install' -l input-methoddir -d 'Target location for Input Methods (default: `~/Library/Input Methods`)'
__fish_brew_complete_arg 'install' -l interactive -d 'Download and patch formula, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package'
__fish_brew_complete_arg 'install' -l internet-plugindir -d 'Target location for Internet Plugins (default: `~/Library/Internet Plug-Ins`)'
__fish_brew_complete_arg 'install' -l keep-tmp -d 'Retain the temporary files created during installation'
__fish_brew_complete_arg 'install' -l language -d 'Comma-separated list of language codes to prefer for cask installation. The first matching language is used, otherwise it reverts to the cask\'s default language. The default value is the language of your system'
__fish_brew_complete_arg 'install' -l mdimporterdir -d 'Target location for Spotlight Plugins (default: `~/Library/Spotlight`)'
__fish_brew_complete_arg 'install' -l no-binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'install' -l no-quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'install' -l only-dependencies -d 'Install the dependencies with specified options but do not install the formula itself'
__fish_brew_complete_arg 'install' -l prefpanedir -d 'Target location for Preference Panes (default: `~/Library/PreferencePanes`)'
__fish_brew_complete_arg 'install' -l qlplugindir -d 'Target location for QuickLook Plugins (default: `~/Library/QuickLook`)'
__fish_brew_complete_arg 'install' -l quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'install' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'install' -l require-sha -d 'Require all casks to have a checksum'
__fish_brew_complete_arg 'install' -l screen-saverdir -d 'Target location for Screen Savers (default: `~/Library/Screen Savers`)'
__fish_brew_complete_arg 'install' -l servicedir -d 'Target location for Services (default: `~/Library/Services`)'
__fish_brew_complete_arg 'install' -l skip-cask-deps -d 'Skip installing cask dependencies'
__fish_brew_complete_arg 'install' -l verbose -d 'Print the verification and postinstall steps'
__fish_brew_complete_arg 'install' -l vst-plugindir -d 'Target location for VST Plugins (default: `~/Library/Audio/Plug-Ins/VST`)'
__fish_brew_complete_arg 'install' -l vst3-plugindir -d 'Target location for VST3 Plugins (default: `~/Library/Audio/Plug-Ins/VST3`)'
__fish_brew_complete_arg 'install; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'install; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'install-bundler-gems' 'Install Homebrew\'s Bundler gems'
__fish_brew_complete_arg 'install-bundler-gems' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'install-bundler-gems' -l help -d 'Show this message'
__fish_brew_complete_arg 'install-bundler-gems' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'install-bundler-gems' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'irb' 'Enter the interactive Homebrew Ruby shell'
__fish_brew_complete_arg 'irb' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'irb' -l examples -d 'Show several examples'
__fish_brew_complete_arg 'irb' -l help -d 'Show this message'
__fish_brew_complete_arg 'irb' -l pry -d 'Use Pry instead of IRB. Implied if `HOMEBREW_PRY` is set'
__fish_brew_complete_arg 'irb' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'irb' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'leaves' 'List installed formulae that are not dependencies of another installed formula'
__fish_brew_complete_arg 'leaves' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'leaves' -l help -d 'Show this message'
__fish_brew_complete_arg 'leaves' -l installed-as-dependency -d 'Only list leaves that were installed as dependencies'
__fish_brew_complete_arg 'leaves' -l installed-on-request -d 'Only list leaves that were manually installed'
__fish_brew_complete_arg 'leaves' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'leaves' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'link' 'Symlink all of formula\'s installed files into Homebrew\'s prefix'
__fish_brew_complete_arg 'link' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'link' -l dry-run -d 'List files which would be linked or deleted by `brew link --overwrite` without actually linking or deleting any files'
__fish_brew_complete_arg 'link' -l force -d 'Allow keg-only formulae to be linked'
__fish_brew_complete_arg 'link' -l help -d 'Show this message'
__fish_brew_complete_arg 'link' -l overwrite -d 'Delete files that already exist in the prefix while linking'
__fish_brew_complete_arg 'link' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'link' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'link' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'linkage' 'Check the library links from the given formula kegs'
__fish_brew_complete_arg 'linkage' -l cached -d 'Print the cached linkage values stored in `HOMEBREW_CACHE`, set by a previous `brew linkage` run'
__fish_brew_complete_arg 'linkage' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'linkage' -l help -d 'Show this message'
__fish_brew_complete_arg 'linkage' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'linkage' -l reverse -d 'For every library that a keg references, print its dylib path followed by the binaries that link to it'
__fish_brew_complete_arg 'linkage' -l test -d 'Show only missing libraries and exit with a non-zero status if any missing libraries are found'
__fish_brew_complete_arg 'linkage' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'linkage' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'list' 'List all installed formulae and casks'
__fish_brew_complete_arg 'list' -l cask -d 'List only casks, or treat all named arguments as casks'
__fish_brew_complete_arg 'list' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'list' -l formula -d 'List only formulae, or treat all named arguments as formulae'
__fish_brew_complete_arg 'list' -l full-name -d 'Print formulae with fully-qualified names. Unless `--full-name`, `--versions` or `--pinned` are passed, other options (i.e. `-1`, `-l`, `-r` and `-t`) are passed to `ls`(1) which produces the actual output'
__fish_brew_complete_arg 'list' -l help -d 'Show this message'
__fish_brew_complete_arg 'list' -l multiple -d 'Only show formulae with multiple versions installed'
__fish_brew_complete_arg 'list' -l pinned -d 'List only pinned formulae, or only the specified (pinned) formulae if formula are provided. See also `pin`, `unpin`'
__fish_brew_complete_arg 'list' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'list' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'list' -l versions -d 'Show the version number for installed formulae, or only the specified formulae if formula are provided'
__fish_brew_complete_arg 'list' -l 1 -d 'Force output to be one entry per line. This is the default when output is not to a terminal'
__fish_brew_complete_arg 'list' -l l -d 'List formulae and/or casks in long format. Has no effect when a formula or cask name is passed as an argument'
__fish_brew_complete_arg 'list' -l r -d 'Reverse the order of the formulae and/or casks sort to list the oldest entries first. Has no effect when a formula or cask name is passed as an argument'
__fish_brew_complete_arg 'list' -l t -d 'Sort formulae and/or casks by time modified, listing most recently modified first. Has no effect when a formula or cask name is passed as an argument'
__fish_brew_complete_arg 'list; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_installed)'
__fish_brew_complete_arg 'list; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_installed)'


__fish_brew_complete_cmd 'livecheck' 'Check for newer versions of formulae and/or casks from upstream'
__fish_brew_complete_arg 'livecheck' -l all -d 'Check all available formulae/casks'
__fish_brew_complete_arg 'livecheck' -l cask -d 'Only check casks'
__fish_brew_complete_arg 'livecheck' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'livecheck' -l formula -d 'Only check formulae'
__fish_brew_complete_arg 'livecheck' -l full-name -d 'Print formulae/casks with fully-qualified names'
__fish_brew_complete_arg 'livecheck' -l help -d 'Show this message'
__fish_brew_complete_arg 'livecheck' -l installed -d 'Check formulae/casks that are currently installed'
__fish_brew_complete_arg 'livecheck' -l json -d 'Output information in JSON format'
__fish_brew_complete_arg 'livecheck' -l newer-only -d 'Show the latest version only if it\'s newer than the formula/cask'
__fish_brew_complete_arg 'livecheck' -l quiet -d 'Suppress warnings, don\'t print a progress bar for JSON output'
__fish_brew_complete_arg 'livecheck' -l tap -d 'Check formulae/casks within the given tap, specified as user`/`repo'
__fish_brew_complete_arg 'livecheck' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'livecheck; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'livecheck; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'ln' 'Symlink all of formula\'s installed files into Homebrew\'s prefix'
__fish_brew_complete_arg 'ln' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'ln' -l dry-run -d 'List files which would be linked or deleted by `brew link --overwrite` without actually linking or deleting any files'
__fish_brew_complete_arg 'ln' -l force -d 'Allow keg-only formulae to be linked'
__fish_brew_complete_arg 'ln' -l help -d 'Show this message'
__fish_brew_complete_arg 'ln' -l overwrite -d 'Delete files that already exist in the prefix while linking'
__fish_brew_complete_arg 'ln' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'ln' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'ln' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'log' 'Show the `git log` for formula, or show the log for the Homebrew repository if no formula is provided'
__fish_brew_complete_arg 'log' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'log' -l help -d 'Show this message'
__fish_brew_complete_arg 'log' -l max-count -d 'Print only a specified number of commits'
__fish_brew_complete_arg 'log' -l oneline -d 'Print only one line per commit'
__fish_brew_complete_arg 'log' -l patch -d 'Also print patch from commit'
__fish_brew_complete_arg 'log' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'log' -l stat -d 'Also print diffstat from commit'
__fish_brew_complete_arg 'log' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'log' -l 1 -d 'Print only one commit'
__fish_brew_complete_arg 'log' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'ls' 'List all installed formulae and casks'
__fish_brew_complete_arg 'ls' -l cask -d 'List only casks, or treat all named arguments as casks'
__fish_brew_complete_arg 'ls' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'ls' -l formula -d 'List only formulae, or treat all named arguments as formulae'
__fish_brew_complete_arg 'ls' -l full-name -d 'Print formulae with fully-qualified names. Unless `--full-name`, `--versions` or `--pinned` are passed, other options (i.e. `-1`, `-l`, `-r` and `-t`) are passed to `ls`(1) which produces the actual output'
__fish_brew_complete_arg 'ls' -l help -d 'Show this message'
__fish_brew_complete_arg 'ls' -l multiple -d 'Only show formulae with multiple versions installed'
__fish_brew_complete_arg 'ls' -l pinned -d 'List only pinned formulae, or only the specified (pinned) formulae if formula are provided. See also `pin`, `unpin`'
__fish_brew_complete_arg 'ls' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'ls' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'ls' -l versions -d 'Show the version number for installed formulae, or only the specified formulae if formula are provided'
__fish_brew_complete_arg 'ls' -l 1 -d 'Force output to be one entry per line. This is the default when output is not to a terminal'
__fish_brew_complete_arg 'ls' -l l -d 'List formulae and/or casks in long format. Has no effect when a formula or cask name is passed as an argument'
__fish_brew_complete_arg 'ls' -l r -d 'Reverse the order of the formulae and/or casks sort to list the oldest entries first. Has no effect when a formula or cask name is passed as an argument'
__fish_brew_complete_arg 'ls' -l t -d 'Sort formulae and/or casks by time modified, listing most recently modified first. Has no effect when a formula or cask name is passed as an argument'
__fish_brew_complete_arg 'ls; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_installed)'
__fish_brew_complete_arg 'ls; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_installed)'


__fish_brew_complete_cmd 'man' 'Generate Homebrew\'s manpages'
__fish_brew_complete_arg 'man' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'man' -l fail-if-not-changed -d 'Return a failing status code if no changes are detected in the manpage outputs. This can be used to notify CI when the manpages are out of date. Additionally, the date used in new manpages will match those in the existing manpages (to allow comparison without factoring in the date)'
__fish_brew_complete_arg 'man' -l help -d 'Show this message'
__fish_brew_complete_arg 'man' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'man' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'migrate' 'Migrate renamed packages to new names, where formula are old names of packages'
__fish_brew_complete_arg 'migrate' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'migrate' -l force -d 'Treat installed formula and provided formula as if they are from the same taps and migrate them anyway'
__fish_brew_complete_arg 'migrate' -l help -d 'Show this message'
__fish_brew_complete_arg 'migrate' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'migrate' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'migrate' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'mirror' 'Reupload the stable URL of a formula for use as a mirror'
__fish_brew_complete_arg 'mirror' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'mirror' -l help -d 'Show this message'
__fish_brew_complete_arg 'mirror' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'mirror' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'missing' 'Check the given formula kegs for missing dependencies'
__fish_brew_complete_arg 'missing' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'missing' -l help -d 'Show this message'
__fish_brew_complete_arg 'missing' -l hide -d 'Act as if none of the specified hidden are installed. hidden should be a comma-separated list of formulae'
__fish_brew_complete_arg 'missing' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'missing' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'missing' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'options' 'Show install options specific to formula'
__fish_brew_complete_arg 'options' -l all -d 'Show options for all available formulae'
__fish_brew_complete_arg 'options' -l command -d 'Show options for the specified command'
__fish_brew_complete_arg 'options' -l compact -d 'Show all options on a single line separated by spaces'
__fish_brew_complete_arg 'options' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'options' -l help -d 'Show this message'
__fish_brew_complete_arg 'options' -l installed -d 'Show options for formulae that are currently installed'
__fish_brew_complete_arg 'options' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'options' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'options' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'outdated' 'List installed casks and formulae that have an updated version available'
__fish_brew_complete_arg 'outdated' -l cask -d 'List only outdated casks'
__fish_brew_complete_arg 'outdated' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'outdated' -l fetch-HEAD -d 'Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository\'s HEAD will only be checked for updates when a new stable or development version has been released'
__fish_brew_complete_arg 'outdated' -l formula -d 'List only outdated formulae'
__fish_brew_complete_arg 'outdated' -l greedy -d 'Print outdated casks with `auto_updates` or `version :latest`'
__fish_brew_complete_arg 'outdated' -l help -d 'Show this message'
__fish_brew_complete_arg 'outdated' -l json -d 'Print output in JSON format. There are two versions: `v1` and `v2`. `v1` is deprecated and is currently the default if no version is specified. `v2` prints outdated formulae and casks. '
__fish_brew_complete_arg 'outdated' -l quiet -d 'List only the names of outdated kegs (takes precedence over `--verbose`)'
__fish_brew_complete_arg 'outdated' -l verbose -d 'Include detailed version information'
__fish_brew_complete_arg 'outdated; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'outdated; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'pin' 'Pin the specified formula, preventing them from being upgraded when issuing the `brew upgrade` formula command'
__fish_brew_complete_arg 'pin' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'pin' -l help -d 'Show this message'
__fish_brew_complete_arg 'pin' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'pin' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'pin' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'postinstall' 'Rerun the post-install steps for formula'
__fish_brew_complete_arg 'postinstall' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'postinstall' -l help -d 'Show this message'
__fish_brew_complete_arg 'postinstall' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'postinstall' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'postinstall' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'pr-automerge' 'Find pull requests that can be automatically merged using `brew pr-publish`'
__fish_brew_complete_arg 'pr-automerge' -l autosquash -d 'Instruct `brew pr-publish` to automatically reformat and reword commits in the pull request to our preferred format'
__fish_brew_complete_arg 'pr-automerge' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'pr-automerge' -l help -d 'Show this message'
__fish_brew_complete_arg 'pr-automerge' -l ignore-failures -d 'Include pull requests that have failing status checks'
__fish_brew_complete_arg 'pr-automerge' -l publish -d 'Run `brew pr-publish` on matching pull requests'
__fish_brew_complete_arg 'pr-automerge' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'pr-automerge' -l tap -d 'Target tap repository (default: `homebrew/core`)'
__fish_brew_complete_arg 'pr-automerge' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'pr-automerge' -l with-label -d 'Pull requests must have this label'
__fish_brew_complete_arg 'pr-automerge' -l without-approval -d 'Pull requests do not require approval to be merged'
__fish_brew_complete_arg 'pr-automerge' -l without-labels -d 'Pull requests must not have these labels (default: `do not merge`, `new formula`, `automerge-skip`, `linux-only`, `linux to homebrew-core`)'


__fish_brew_complete_cmd 'pr-publish' 'Publish bottles for a pull request with GitHub Actions'
__fish_brew_complete_arg 'pr-publish' -l autosquash -d 'If supported on the target tap, automatically reformat and reword commits in the pull request to our preferred format'
__fish_brew_complete_arg 'pr-publish' -l branch -d 'Branch to publish to (default: `master`)'
__fish_brew_complete_arg 'pr-publish' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'pr-publish' -l help -d 'Show this message'
__fish_brew_complete_arg 'pr-publish' -l message -d 'Message to include when autosquashing revision bumps, deletions, and rebuilds'
__fish_brew_complete_arg 'pr-publish' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'pr-publish' -l tap -d 'Target tap repository (default: `homebrew/core`)'
__fish_brew_complete_arg 'pr-publish' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'pr-publish' -l workflow -d 'Target workflow filename (default: `publish-commit-bottles.yml`)'


__fish_brew_complete_cmd 'pr-pull' 'Download and publish bottles, and apply the bottle commit from a pull request with artifacts generated by GitHub Actions'
__fish_brew_complete_arg 'pr-pull' -l archive-item -d 'Upload to the specified Internet Archive item (default: `homebrew`)'
__fish_brew_complete_arg 'pr-pull' -l artifact -d 'Download artifacts with the specified name (default: `bottles`)'
__fish_brew_complete_arg 'pr-pull' -l autosquash -d 'Automatically reformat and reword commits in the pull request to our preferred format'
__fish_brew_complete_arg 'pr-pull' -l branch-okay -d 'Do not warn if pulling to a branch besides the repository default (useful for testing)'
__fish_brew_complete_arg 'pr-pull' -l clean -d 'Do not amend the commits from pull requests'
__fish_brew_complete_arg 'pr-pull' -l committer -d 'Specify a committer name and email in `git`\'s standard author format'
__fish_brew_complete_arg 'pr-pull' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'pr-pull' -l dry-run -d 'Print what would be done rather than doing it'
__fish_brew_complete_arg 'pr-pull' -l help -d 'Show this message'
__fish_brew_complete_arg 'pr-pull' -l ignore-missing-artifacts -d 'Comma-separated list of workflows which can be ignored if they have not been run'
__fish_brew_complete_arg 'pr-pull' -l keep-old -d 'If the formula specifies a rebuild version, attempt to preserve its value in the generated DSL'
__fish_brew_complete_arg 'pr-pull' -l message -d 'Message to include when autosquashing revision bumps, deletions, and rebuilds'
__fish_brew_complete_arg 'pr-pull' -l no-commit -d 'Do not generate a new commit before uploading'
__fish_brew_complete_arg 'pr-pull' -l no-publish -d 'Download the bottles, apply the bottle commit and upload the bottles, but don\'t publish them'
__fish_brew_complete_arg 'pr-pull' -l no-upload -d 'Download the bottles and apply the bottle commit, but don\'t upload'
__fish_brew_complete_arg 'pr-pull' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'pr-pull' -l resolve -d 'When a patch fails to apply, leave in progress and allow user to resolve, instead of aborting'
__fish_brew_complete_arg 'pr-pull' -l root-url -d 'Use the specified URL as the root of the bottle\'s URL instead of Homebrew\'s default'
__fish_brew_complete_arg 'pr-pull' -l root-url-using -d 'Use the specified download strategy class for downloading the bottle\'s URL instead of Homebrew\'s default'
__fish_brew_complete_arg 'pr-pull' -l tap -d 'Target tap repository (default: `homebrew/core`)'
__fish_brew_complete_arg 'pr-pull' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'pr-pull' -l warn-on-upload-failure -d 'Warn instead of raising an error if the bottle upload fails. Useful for repairing bottle uploads that previously failed'
__fish_brew_complete_arg 'pr-pull' -l workflows -d 'Retrieve artifacts from the specified workflow (default: `tests.yml`). Can be a comma-separated list to include multiple workflows'


__fish_brew_complete_cmd 'pr-upload' 'Apply the bottle commit and publish bottles to a host'
__fish_brew_complete_arg 'pr-upload' -l archive-item -d 'Upload to the specified Internet Archive item (default: `homebrew`)'
__fish_brew_complete_arg 'pr-upload' -l committer -d 'Specify a committer name and email in `git`\'s standard author format'
__fish_brew_complete_arg 'pr-upload' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'pr-upload' -l dry-run -d 'Print what would be done rather than doing it'
__fish_brew_complete_arg 'pr-upload' -l github-org -d 'Upload to the specified GitHub organisation\'s GitHub Packages (default: `homebrew`)'
__fish_brew_complete_arg 'pr-upload' -l help -d 'Show this message'
__fish_brew_complete_arg 'pr-upload' -l keep-old -d 'If the formula specifies a rebuild version, attempt to preserve its value in the generated DSL'
__fish_brew_complete_arg 'pr-upload' -l no-commit -d 'Do not generate a new commit before uploading'
__fish_brew_complete_arg 'pr-upload' -l no-publish -d 'Apply the bottle commit and upload the bottles, but don\'t publish them'
__fish_brew_complete_arg 'pr-upload' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'pr-upload' -l root-url -d 'Use the specified URL as the root of the bottle\'s URL instead of Homebrew\'s default'
__fish_brew_complete_arg 'pr-upload' -l root-url-using -d 'Use the specified download strategy class for downloading the bottle\'s URL instead of Homebrew\'s default'
__fish_brew_complete_arg 'pr-upload' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'pr-upload' -l warn-on-upload-failure -d 'Warn instead of raising an error if the bottle upload fails. Useful for repairing bottle uploads that previously failed'


__fish_brew_complete_cmd 'prof' 'Run Homebrew with a Ruby profiler'
__fish_brew_complete_arg 'prof' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'prof' -l help -d 'Show this message'
__fish_brew_complete_arg 'prof' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'prof' -l stackprof -d 'Use `stackprof` instead of `ruby-prof` (the default)'
__fish_brew_complete_arg 'prof' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'prof' -a '(__fish_brew_suggest_commands)'


__fish_brew_complete_cmd 'readall' 'Import all items from the specified tap, or from all installed taps if none is provided'
__fish_brew_complete_arg 'readall' -l aliases -d 'Verify any alias symlinks in each tap'
__fish_brew_complete_arg 'readall' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'readall' -l help -d 'Show this message'
__fish_brew_complete_arg 'readall' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'readall' -l syntax -d 'Syntax-check all of Homebrew\'s Ruby files (if no `tap` is passed)'
__fish_brew_complete_arg 'readall' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'readall' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'reinstall' 'Uninstall and then reinstall a formula or cask using the same options it was originally installed with, plus any appended options specific to a formula'
__fish_brew_complete_arg 'reinstall' -l appdir -d 'Target location for Applications (default: `/Applications`)'
__fish_brew_complete_arg 'reinstall' -l audio-unit-plugindir -d 'Target location for Audio Unit Plugins (default: `~/Library/Audio/Plug-Ins/Components`)'
__fish_brew_complete_arg 'reinstall' -l binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'reinstall' -l build-from-source -d 'Compile formula from source even if a bottle is available'
__fish_brew_complete_arg 'reinstall' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'reinstall' -l colorpickerdir -d 'Target location for Color Pickers (default: `~/Library/ColorPickers`)'
__fish_brew_complete_arg 'reinstall' -l debug -d 'If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory'
__fish_brew_complete_arg 'reinstall' -l dictionarydir -d 'Target location for Dictionaries (default: `~/Library/Dictionaries`)'
__fish_brew_complete_arg 'reinstall' -l display-times -d 'Print install times for each formula at the end of the run'
__fish_brew_complete_arg 'reinstall' -l fontdir -d 'Target location for Fonts (default: `~/Library/Fonts`)'
__fish_brew_complete_arg 'reinstall' -l force -d 'Install without checking for previously installed keg-only or non-migrated versions'
__fish_brew_complete_arg 'reinstall' -l force-bottle -d 'Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation'
__fish_brew_complete_arg 'reinstall' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'reinstall' -l help -d 'Show this message'
__fish_brew_complete_arg 'reinstall' -l input-methoddir -d 'Target location for Input Methods (default: `~/Library/Input Methods`)'
__fish_brew_complete_arg 'reinstall' -l interactive -d 'Download and patch formula, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package'
__fish_brew_complete_arg 'reinstall' -l internet-plugindir -d 'Target location for Internet Plugins (default: `~/Library/Internet Plug-Ins`)'
__fish_brew_complete_arg 'reinstall' -l keep-tmp -d 'Retain the temporary files created during installation'
__fish_brew_complete_arg 'reinstall' -l language -d 'Comma-separated list of language codes to prefer for cask installation. The first matching language is used, otherwise it reverts to the cask\'s default language. The default value is the language of your system'
__fish_brew_complete_arg 'reinstall' -l mdimporterdir -d 'Target location for Spotlight Plugins (default: `~/Library/Spotlight`)'
__fish_brew_complete_arg 'reinstall' -l no-binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'reinstall' -l no-quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'reinstall' -l prefpanedir -d 'Target location for Preference Panes (default: `~/Library/PreferencePanes`)'
__fish_brew_complete_arg 'reinstall' -l qlplugindir -d 'Target location for QuickLook Plugins (default: `~/Library/QuickLook`)'
__fish_brew_complete_arg 'reinstall' -l quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'reinstall' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'reinstall' -l require-sha -d 'Require all casks to have a checksum'
__fish_brew_complete_arg 'reinstall' -l screen-saverdir -d 'Target location for Screen Savers (default: `~/Library/Screen Savers`)'
__fish_brew_complete_arg 'reinstall' -l servicedir -d 'Target location for Services (default: `~/Library/Services`)'
__fish_brew_complete_arg 'reinstall' -l skip-cask-deps -d 'Skip installing cask dependencies'
__fish_brew_complete_arg 'reinstall' -l verbose -d 'Print the verification and postinstall steps'
__fish_brew_complete_arg 'reinstall' -l vst-plugindir -d 'Target location for VST Plugins (default: `~/Library/Audio/Plug-Ins/VST`)'
__fish_brew_complete_arg 'reinstall' -l vst3-plugindir -d 'Target location for VST3 Plugins (default: `~/Library/Audio/Plug-Ins/VST3`)'
__fish_brew_complete_arg 'reinstall; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'reinstall; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'release' 'Create a new draft Homebrew/brew release with the appropriate version number and release notes'
__fish_brew_complete_arg 'release' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'release' -l help -d 'Show this message'
__fish_brew_complete_arg 'release' -l major -d 'Create a major release'
__fish_brew_complete_arg 'release' -l minor -d 'Create a minor release'
__fish_brew_complete_arg 'release' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'release' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'release-notes' 'Print the merged pull requests on Homebrew/brew between two Git refs'
__fish_brew_complete_arg 'release-notes' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'release-notes' -l help -d 'Show this message'
__fish_brew_complete_arg 'release-notes' -l markdown -d 'Print as a Markdown list'
__fish_brew_complete_arg 'release-notes' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'release-notes' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'remove' 'Uninstall a formula or cask'
__fish_brew_complete_arg 'remove' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'remove' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'remove' -l force -d 'Delete all installed versions of formula. Uninstall even if cask is not installed, overwrite existing files and ignore errors when removing files'
__fish_brew_complete_arg 'remove' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'remove' -l help -d 'Show this message'
__fish_brew_complete_arg 'remove' -l ignore-dependencies -d 'Don\'t fail uninstall, even if formula is a dependency of any installed formulae'
__fish_brew_complete_arg 'remove' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'remove' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'remove' -l zap -d 'Remove all files associated with a cask. *May remove files which are shared between applications.*'
__fish_brew_complete_arg 'remove; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_installed)'
__fish_brew_complete_arg 'remove; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_installed)'


__fish_brew_complete_cmd 'rm' 'Uninstall a formula or cask'
__fish_brew_complete_arg 'rm' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'rm' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'rm' -l force -d 'Delete all installed versions of formula. Uninstall even if cask is not installed, overwrite existing files and ignore errors when removing files'
__fish_brew_complete_arg 'rm' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'rm' -l help -d 'Show this message'
__fish_brew_complete_arg 'rm' -l ignore-dependencies -d 'Don\'t fail uninstall, even if formula is a dependency of any installed formulae'
__fish_brew_complete_arg 'rm' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'rm' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'rm' -l zap -d 'Remove all files associated with a cask. *May remove files which are shared between applications.*'
__fish_brew_complete_arg 'rm; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_installed)'
__fish_brew_complete_arg 'rm; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_installed)'


__fish_brew_complete_cmd 'ruby' 'Run a Ruby instance with Homebrew\'s libraries loaded'
__fish_brew_complete_arg 'ruby' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'ruby' -l help -d 'Show this message'
__fish_brew_complete_arg 'ruby' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'ruby' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'ruby' -l e -d 'Execute the given text string as a script'
__fish_brew_complete_arg 'ruby' -l r -d 'Load a library using `require`'


__fish_brew_complete_cmd 'search' 'Perform a substring search of cask tokens and formula names for text'
__fish_brew_complete_arg 'search' -l cask -d 'Search online and locally for casks'
__fish_brew_complete_arg 'search' -l closed -d 'Search for only closed GitHub pull requests'
__fish_brew_complete_arg 'search' -l debian -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg 'search' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'search' -l desc -d 'Search for formulae with a description matching text and casks with a name matching text'
__fish_brew_complete_arg 'search' -l fedora -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg 'search' -l fink -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg 'search' -l formula -d 'Search online and locally for formulae'
__fish_brew_complete_arg 'search' -l help -d 'Show this message'
__fish_brew_complete_arg 'search' -l macports -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg 'search' -l open -d 'Search for only open GitHub pull requests'
__fish_brew_complete_arg 'search' -l opensuse -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg 'search' -l pull-request -d 'Search for GitHub pull requests containing text'
__fish_brew_complete_arg 'search' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'search' -l ubuntu -d 'Search for text in the given package manager\'s list'
__fish_brew_complete_arg 'search' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'sh' 'Enter an interactive shell for Homebrew\'s build environment'
__fish_brew_complete_arg 'sh' -l cmd -d 'Execute commands in a non-interactive shell'
__fish_brew_complete_arg 'sh' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'sh' -l env -d 'Use the standard `PATH` instead of superenv\'s when `std` is passed'
__fish_brew_complete_arg 'sh' -l help -d 'Show this message'
__fish_brew_complete_arg 'sh' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'sh' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'sponsors' 'Update the list of GitHub Sponsors in the `Homebrew/brew` README'
__fish_brew_complete_arg 'sponsors' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'sponsors' -l help -d 'Show this message'
__fish_brew_complete_arg 'sponsors' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'sponsors' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'style' 'Check formulae or files for conformance to Homebrew style guidelines'
__fish_brew_complete_arg 'style' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'style' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'style' -l display-cop-names -d 'Include the RuboCop cop name for each violation in the output'
__fish_brew_complete_arg 'style' -l except-cops -d 'Specify a comma-separated cops list to skip checking for violations of the listed RuboCop cops'
__fish_brew_complete_arg 'style' -l fix -d 'Fix style violations automatically using RuboCop\'s auto-correct feature'
__fish_brew_complete_arg 'style' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'style' -l help -d 'Show this message'
__fish_brew_complete_arg 'style' -l only-cops -d 'Specify a comma-separated cops list to check for violations of only the listed RuboCop cops'
__fish_brew_complete_arg 'style' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'style' -l reset-cache -d 'Reset the RuboCop cache'
__fish_brew_complete_arg 'style' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'style' -a '(__fish_brew_suggest_taps_installed)'
__fish_brew_complete_arg 'style; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'style; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'


__fish_brew_complete_cmd 'tap' 'Tap a formula repository'
__fish_brew_complete_arg 'tap' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'tap' -l force-auto-update -d 'Auto-update tap even if it is not hosted on GitHub. By default, only taps hosted on GitHub are auto-updated (for performance reasons)'
__fish_brew_complete_arg 'tap' -l full -d 'Convert a shallow clone to a full clone without untapping. Taps are only cloned as shallow clones if `--shallow` was originally passed'
__fish_brew_complete_arg 'tap' -l help -d 'Show this message'
__fish_brew_complete_arg 'tap' -l list-pinned -d 'List all pinned taps'
__fish_brew_complete_arg 'tap' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'tap' -l repair -d 'Migrate tapped formulae from symlink-based to directory-based structure'
__fish_brew_complete_arg 'tap' -l shallow -d 'Fetch tap as a shallow clone rather than a full clone. Useful for continuous integration'
__fish_brew_complete_arg 'tap' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'tap' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'tap-info' 'Show detailed information about one or more taps'
__fish_brew_complete_arg 'tap-info' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'tap-info' -l help -d 'Show this message'
__fish_brew_complete_arg 'tap-info' -l installed -d 'Show information on each installed tap'
__fish_brew_complete_arg 'tap-info' -l json -d 'Print a JSON representation of tap. Currently the default and only accepted value for version is `v1`. See the docs for examples of using the JSON output: https://docs.brew.sh/Querying-Brew'
__fish_brew_complete_arg 'tap-info' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'tap-info' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'tap-info' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'tap-new' 'Generate the template files for a new tap'
__fish_brew_complete_arg 'tap-new' -l branch -d 'Initialize Git repository and setup GitHub Actions workflows with the specified branch name (default: `main`)'
__fish_brew_complete_arg 'tap-new' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'tap-new' -l help -d 'Show this message'
__fish_brew_complete_arg 'tap-new' -l no-git -d 'Don\'t initialize a Git repository for the tap'
__fish_brew_complete_arg 'tap-new' -l pull-label -d 'Label name for pull requests ready to be pulled (default: `pr-pull`)'
__fish_brew_complete_arg 'tap-new' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'tap-new' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'tap-new' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'tc' 'Check for typechecking errors using Sorbet'
__fish_brew_complete_arg 'tc' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'tc' -l dir -d 'Typecheck all files in a specific directory'
__fish_brew_complete_arg 'tc' -l fail-if-not-changed -d 'Return a failing status code if all gems are up to date and gem definitions do not need a tapioca update'
__fish_brew_complete_arg 'tc' -l file -d 'Typecheck a single file'
__fish_brew_complete_arg 'tc' -l fix -d 'Automatically fix type errors'
__fish_brew_complete_arg 'tc' -l help -d 'Show this message'
__fish_brew_complete_arg 'tc' -l ignore -d 'Ignores input files that contain the given string in their paths (relative to the input path passed to Sorbet)'
__fish_brew_complete_arg 'tc' -l quiet -d 'Silence all non-critical errors'
__fish_brew_complete_arg 'tc' -l suggest-typed -d 'Try upgrading `typed` sigils'
__fish_brew_complete_arg 'tc' -l update -d 'Update RBI files'
__fish_brew_complete_arg 'tc' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'test' 'Run the test method provided by an installed formula'
__fish_brew_complete_arg 'test' -l HEAD -d 'Test the head version of a formula'
__fish_brew_complete_arg 'test' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'test' -l force -d 'Test formulae even if they are unlinked'
__fish_brew_complete_arg 'test' -l help -d 'Show this message'
__fish_brew_complete_arg 'test' -l keep-tmp -d 'Retain the temporary files created for the test'
__fish_brew_complete_arg 'test' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'test' -l retry -d 'Retry if a testing fails'
__fish_brew_complete_arg 'test' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'test' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'tests' 'Run Homebrew\'s unit and integration tests'
__fish_brew_complete_arg 'tests' -l byebug -d 'Enable debugging using byebug'
__fish_brew_complete_arg 'tests' -l coverage -d 'Generate code coverage reports'
__fish_brew_complete_arg 'tests' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'tests' -l generic -d 'Run only OS-agnostic tests'
__fish_brew_complete_arg 'tests' -l help -d 'Show this message'
__fish_brew_complete_arg 'tests' -l no-compat -d 'Do not load the compatibility layer when running tests'
__fish_brew_complete_arg 'tests' -l online -d 'Include tests that use the GitHub API and tests that use any of the taps for official external commands'
__fish_brew_complete_arg 'tests' -l only -d 'Run only test_script`_spec.rb`. Appending `:`line_number will start at a specific line'
__fish_brew_complete_arg 'tests' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'tests' -l seed -d 'Randomise tests with the specified value instead of a random seed'
__fish_brew_complete_arg 'tests' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'typecheck' 'Check for typechecking errors using Sorbet'
__fish_brew_complete_arg 'typecheck' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'typecheck' -l dir -d 'Typecheck all files in a specific directory'
__fish_brew_complete_arg 'typecheck' -l fail-if-not-changed -d 'Return a failing status code if all gems are up to date and gem definitions do not need a tapioca update'
__fish_brew_complete_arg 'typecheck' -l file -d 'Typecheck a single file'
__fish_brew_complete_arg 'typecheck' -l fix -d 'Automatically fix type errors'
__fish_brew_complete_arg 'typecheck' -l help -d 'Show this message'
__fish_brew_complete_arg 'typecheck' -l ignore -d 'Ignores input files that contain the given string in their paths (relative to the input path passed to Sorbet)'
__fish_brew_complete_arg 'typecheck' -l quiet -d 'Silence all non-critical errors'
__fish_brew_complete_arg 'typecheck' -l suggest-typed -d 'Try upgrading `typed` sigils'
__fish_brew_complete_arg 'typecheck' -l update -d 'Update RBI files'
__fish_brew_complete_arg 'typecheck' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'unbottled' 'Show the unbottled dependents of formulae'
__fish_brew_complete_arg 'unbottled' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'unbottled' -l dependents -d 'Skip getting analytics data and sort by number of dependents instead'
__fish_brew_complete_arg 'unbottled' -l help -d 'Show this message'
__fish_brew_complete_arg 'unbottled' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'unbottled' -l tag -d 'Use the specified bottle tag (e.g. `big_sur`) instead of the current OS'
__fish_brew_complete_arg 'unbottled' -l total -d 'Print the number of unbottled and total formulae'
__fish_brew_complete_arg 'unbottled' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'unbottled' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'uninstal' 'Uninstall a formula or cask'
__fish_brew_complete_arg 'uninstal' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'uninstal' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'uninstal' -l force -d 'Delete all installed versions of formula. Uninstall even if cask is not installed, overwrite existing files and ignore errors when removing files'
__fish_brew_complete_arg 'uninstal' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'uninstal' -l help -d 'Show this message'
__fish_brew_complete_arg 'uninstal' -l ignore-dependencies -d 'Don\'t fail uninstall, even if formula is a dependency of any installed formulae'
__fish_brew_complete_arg 'uninstal' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'uninstal' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'uninstal' -l zap -d 'Remove all files associated with a cask. *May remove files which are shared between applications.*'
__fish_brew_complete_arg 'uninstal; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_installed)'
__fish_brew_complete_arg 'uninstal; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_installed)'


__fish_brew_complete_cmd 'uninstall' 'Uninstall a formula or cask'
__fish_brew_complete_arg 'uninstall' -l cask -d 'Treat all named arguments as casks'
__fish_brew_complete_arg 'uninstall' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'uninstall' -l force -d 'Delete all installed versions of formula. Uninstall even if cask is not installed, overwrite existing files and ignore errors when removing files'
__fish_brew_complete_arg 'uninstall' -l formula -d 'Treat all named arguments as formulae'
__fish_brew_complete_arg 'uninstall' -l help -d 'Show this message'
__fish_brew_complete_arg 'uninstall' -l ignore-dependencies -d 'Don\'t fail uninstall, even if formula is a dependency of any installed formulae'
__fish_brew_complete_arg 'uninstall' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'uninstall' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'uninstall' -l zap -d 'Remove all files associated with a cask. *May remove files which are shared between applications.*'
__fish_brew_complete_arg 'uninstall; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_installed)'
__fish_brew_complete_arg 'uninstall; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_installed)'


__fish_brew_complete_cmd 'unlink' 'Remove symlinks for formula from Homebrew\'s prefix'
__fish_brew_complete_arg 'unlink' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'unlink' -l dry-run -d 'List files which would be unlinked without actually unlinking or deleting any files'
__fish_brew_complete_arg 'unlink' -l help -d 'Show this message'
__fish_brew_complete_arg 'unlink' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'unlink' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'unlink' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'unpack' 'Unpack the source files for formula into subdirectories of the current working directory'
__fish_brew_complete_arg 'unpack' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'unpack' -l destdir -d 'Create subdirectories in the directory named by path instead'
__fish_brew_complete_arg 'unpack' -l force -d 'Overwrite the destination directory if it already exists'
__fish_brew_complete_arg 'unpack' -l git -d 'Initialise a Git repository in the unpacked source. This is useful for creating patches for the software'
__fish_brew_complete_arg 'unpack' -l help -d 'Show this message'
__fish_brew_complete_arg 'unpack' -l patch -d 'Patches for formula will be applied to the unpacked source'
__fish_brew_complete_arg 'unpack' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'unpack' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'unpack' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'unpin' 'Unpin formula, allowing them to be upgraded by `brew upgrade` formula'
__fish_brew_complete_arg 'unpin' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'unpin' -l help -d 'Show this message'
__fish_brew_complete_arg 'unpin' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'unpin' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'unpin' -a '(__fish_brew_suggest_formulae_installed)'


__fish_brew_complete_cmd 'untap' 'Remove a tapped formula repository'
__fish_brew_complete_arg 'untap' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'untap' -l force -d 'Untap even if formulae or casks from this tap are currently installed'
__fish_brew_complete_arg 'untap' -l help -d 'Show this message'
__fish_brew_complete_arg 'untap' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'untap' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'untap' -a '(__fish_brew_suggest_taps_installed)'


__fish_brew_complete_cmd 'up' 'Fetch the newest version of Homebrew and all formulae from GitHub using `git`(1) and perform any necessary migrations'
__fish_brew_complete_arg 'up' -l debug -d 'Display a trace of all shell commands as they are executed'
__fish_brew_complete_arg 'up' -l force -d 'Always do a slower, full update check (even if unnecessary)'
__fish_brew_complete_arg 'up' -l help -d 'Show this message'
__fish_brew_complete_arg 'up' -l merge -d 'Use `git merge` to apply updates (rather than `git rebase`)'
__fish_brew_complete_arg 'up' -l preinstall -d 'Run on auto-updates (e.g. before `brew install`). Skips some slower steps'
__fish_brew_complete_arg 'up' -l verbose -d 'Print the directories checked and `git` operations performed'


__fish_brew_complete_cmd 'update' 'Fetch the newest version of Homebrew and all formulae from GitHub using `git`(1) and perform any necessary migrations'
__fish_brew_complete_arg 'update' -l debug -d 'Display a trace of all shell commands as they are executed'
__fish_brew_complete_arg 'update' -l force -d 'Always do a slower, full update check (even if unnecessary)'
__fish_brew_complete_arg 'update' -l help -d 'Show this message'
__fish_brew_complete_arg 'update' -l merge -d 'Use `git merge` to apply updates (rather than `git rebase`)'
__fish_brew_complete_arg 'update' -l preinstall -d 'Run on auto-updates (e.g. before `brew install`). Skips some slower steps'
__fish_brew_complete_arg 'update' -l verbose -d 'Print the directories checked and `git` operations performed'


__fish_brew_complete_cmd 'update-license-data' 'Update SPDX license data in the Homebrew repository'
__fish_brew_complete_arg 'update-license-data' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'update-license-data' -l fail-if-not-changed -d 'Return a failing status code if current license data\'s version is the same as the upstream. This can be used to notify CI when the SPDX license data is out of date'
__fish_brew_complete_arg 'update-license-data' -l help -d 'Show this message'
__fish_brew_complete_arg 'update-license-data' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'update-license-data' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'update-maintainers' 'Update the list of maintainers in the `Homebrew/brew` README'
__fish_brew_complete_arg 'update-maintainers' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'update-maintainers' -l help -d 'Show this message'
__fish_brew_complete_arg 'update-maintainers' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'update-maintainers' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'update-python-resources' 'Update versions for PyPI resource blocks in formula'
__fish_brew_complete_arg 'update-python-resources' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'update-python-resources' -l exclude-packages -d 'Exclude these packages when finding resources'
__fish_brew_complete_arg 'update-python-resources' -l extra-packages -d 'Include these additional packages when finding resources'
__fish_brew_complete_arg 'update-python-resources' -l help -d 'Show this message'
__fish_brew_complete_arg 'update-python-resources' -l ignore-non-pypi-packages -d 'Don\'t fail if formula is not a PyPI package'
__fish_brew_complete_arg 'update-python-resources' -l package-name -d 'Use the specified package-name when finding resources for formula. If no package name is specified, it will be inferred from the formula\'s stable URL'
__fish_brew_complete_arg 'update-python-resources' -l print-only -d 'Print the updated resource blocks instead of changing formula'
__fish_brew_complete_arg 'update-python-resources' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'update-python-resources' -l silent -d 'Suppress any output'
__fish_brew_complete_arg 'update-python-resources' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'update-python-resources' -l version -d 'Use the specified version when finding resources for formula. If no version is specified, the current version for formula will be used'
__fish_brew_complete_arg 'update-python-resources' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'update-report' 'The Ruby implementation of `brew update`'
__fish_brew_complete_arg 'update-report' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'update-report' -l force -d 'Treat installed and updated formulae as if they are from the same taps and migrate them anyway'
__fish_brew_complete_arg 'update-report' -l help -d 'Show this message'
__fish_brew_complete_arg 'update-report' -l preinstall -d 'Run in \'auto-update\' mode (faster, less output)'
__fish_brew_complete_arg 'update-report' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'update-report' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'update-test' 'Run a test of `brew update` with a new repository clone'
__fish_brew_complete_arg 'update-test' -l before -d 'Use the commit at the specified date as the start commit'
__fish_brew_complete_arg 'update-test' -l commit -d 'Use the specified commit as the start commit'
__fish_brew_complete_arg 'update-test' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'update-test' -l help -d 'Show this message'
__fish_brew_complete_arg 'update-test' -l keep-tmp -d 'Retain the temporary directory containing the new repository clone'
__fish_brew_complete_arg 'update-test' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'update-test' -l to-tag -d 'Set `HOMEBREW_UPDATE_TO_TAG` to test updating between tags'
__fish_brew_complete_arg 'update-test' -l verbose -d 'Make some output more verbose'


__fish_brew_complete_cmd 'upgrade' 'Upgrade outdated casks and outdated, unpinned formulae using the same options they were originally installed with, plus any appended brew formula options'
__fish_brew_complete_arg 'upgrade' -l appdir -d 'Target location for Applications (default: `/Applications`)'
__fish_brew_complete_arg 'upgrade' -l audio-unit-plugindir -d 'Target location for Audio Unit Plugins (default: `~/Library/Audio/Plug-Ins/Components`)'
__fish_brew_complete_arg 'upgrade' -l binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'upgrade' -l build-from-source -d 'Compile formula from source even if a bottle is available'
__fish_brew_complete_arg 'upgrade' -l cask -d 'Treat all named arguments as casks. If no named arguments are specified, upgrade only outdated casks'
__fish_brew_complete_arg 'upgrade' -l colorpickerdir -d 'Target location for Color Pickers (default: `~/Library/ColorPickers`)'
__fish_brew_complete_arg 'upgrade' -l debug -d 'If brewing fails, open an interactive debugging session with access to IRB or a shell inside the temporary build directory'
__fish_brew_complete_arg 'upgrade' -l dictionarydir -d 'Target location for Dictionaries (default: `~/Library/Dictionaries`)'
__fish_brew_complete_arg 'upgrade' -l display-times -d 'Print install times for each formula at the end of the run'
__fish_brew_complete_arg 'upgrade' -l dry-run -d 'Show what would be upgraded, but do not actually upgrade anything'
__fish_brew_complete_arg 'upgrade' -l fetch-HEAD -d 'Fetch the upstream repository to detect if the HEAD installation of the formula is outdated. Otherwise, the repository\'s HEAD will only be checked for updates when a new stable or development version has been released'
__fish_brew_complete_arg 'upgrade' -l fontdir -d 'Target location for Fonts (default: `~/Library/Fonts`)'
__fish_brew_complete_arg 'upgrade' -l force -d 'Install formulae without checking for previously installed keg-only or non-migrated versions. When installing casks, overwrite existing files (binaries and symlinks are excluded, unless originally from the same cask)'
__fish_brew_complete_arg 'upgrade' -l force-bottle -d 'Install from a bottle if it exists for the current or newest version of macOS, even if it would not normally be used for installation'
__fish_brew_complete_arg 'upgrade' -l formula -d 'Treat all named arguments as formulae. If no named arguments are specified, upgrade only outdated formulae'
__fish_brew_complete_arg 'upgrade' -l greedy -d 'Also include casks with `auto_updates true` or `version :latest`'
__fish_brew_complete_arg 'upgrade' -l help -d 'Show this message'
__fish_brew_complete_arg 'upgrade' -l ignore-pinned -d 'Set a successful exit status even if pinned formulae are not upgraded'
__fish_brew_complete_arg 'upgrade' -l input-methoddir -d 'Target location for Input Methods (default: `~/Library/Input Methods`)'
__fish_brew_complete_arg 'upgrade' -l interactive -d 'Download and patch formula, then open a shell. This allows the user to run `./configure --help` and otherwise determine how to turn the software package into a Homebrew package'
__fish_brew_complete_arg 'upgrade' -l internet-plugindir -d 'Target location for Internet Plugins (default: `~/Library/Internet Plug-Ins`)'
__fish_brew_complete_arg 'upgrade' -l keep-tmp -d 'Retain the temporary files created during installation'
__fish_brew_complete_arg 'upgrade' -l language -d 'Comma-separated list of language codes to prefer for cask installation. The first matching language is used, otherwise it reverts to the cask\'s default language. The default value is the language of your system'
__fish_brew_complete_arg 'upgrade' -l mdimporterdir -d 'Target location for Spotlight Plugins (default: `~/Library/Spotlight`)'
__fish_brew_complete_arg 'upgrade' -l no-binaries -d 'Disable/enable linking of helper executables (default: enabled)'
__fish_brew_complete_arg 'upgrade' -l no-quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'upgrade' -l prefpanedir -d 'Target location for Preference Panes (default: `~/Library/PreferencePanes`)'
__fish_brew_complete_arg 'upgrade' -l qlplugindir -d 'Target location for QuickLook Plugins (default: `~/Library/QuickLook`)'
__fish_brew_complete_arg 'upgrade' -l quarantine -d 'Disable/enable quarantining of downloads (default: enabled)'
__fish_brew_complete_arg 'upgrade' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'upgrade' -l require-sha -d 'Require all casks to have a checksum'
__fish_brew_complete_arg 'upgrade' -l screen-saverdir -d 'Target location for Screen Savers (default: `~/Library/Screen Savers`)'
__fish_brew_complete_arg 'upgrade' -l servicedir -d 'Target location for Services (default: `~/Library/Services`)'
__fish_brew_complete_arg 'upgrade' -l skip-cask-deps -d 'Skip installing cask dependencies'
__fish_brew_complete_arg 'upgrade' -l verbose -d 'Print the verification and postinstall steps'
__fish_brew_complete_arg 'upgrade' -l vst-plugindir -d 'Target location for VST Plugins (default: `~/Library/Audio/Plug-Ins/VST`)'
__fish_brew_complete_arg 'upgrade' -l vst3-plugindir -d 'Target location for VST3 Plugins (default: `~/Library/Audio/Plug-Ins/VST3`)'
__fish_brew_complete_arg 'upgrade; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_outdated)'
__fish_brew_complete_arg 'upgrade; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_outdated)'


__fish_brew_complete_cmd 'uses' 'Show formulae and casks that specify formula as a dependency; that is, show dependents of formula'
__fish_brew_complete_arg 'uses' -l cask -d 'Include only casks'
__fish_brew_complete_arg 'uses' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'uses' -l formula -d 'Include only formulae'
__fish_brew_complete_arg 'uses' -l help -d 'Show this message'
__fish_brew_complete_arg 'uses' -l include-build -d 'Include all formulae that specify formula as `:build` type dependency'
__fish_brew_complete_arg 'uses' -l include-optional -d 'Include all formulae that specify formula as `:optional` type dependency'
__fish_brew_complete_arg 'uses' -l include-test -d 'Include all formulae that specify formula as `:test` type dependency'
__fish_brew_complete_arg 'uses' -l installed -d 'Only list formulae and casks that are currently installed'
__fish_brew_complete_arg 'uses' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'uses' -l recursive -d 'Resolve more than one level of dependencies'
__fish_brew_complete_arg 'uses' -l skip-recommended -d 'Skip all formulae that specify formula as `:recommended` type dependency'
__fish_brew_complete_arg 'uses' -l verbose -d 'Make some output more verbose'
__fish_brew_complete_arg 'uses; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'


__fish_brew_complete_cmd 'vendor-gems' 'Install and commit Homebrew\'s vendored gems'
__fish_brew_complete_arg 'vendor-gems' -l debug -d 'Display any debugging information'
__fish_brew_complete_arg 'vendor-gems' -l help -d 'Show this message'
__fish_brew_complete_arg 'vendor-gems' -l quiet -d 'Make some output more quiet'
__fish_brew_complete_arg 'vendor-gems' -l update -d 'Update all vendored Gems to the latest version'
__fish_brew_complete_arg 'vendor-gems' -l verbose -d 'Make some output more verbose'



################################
## OFFICIAL EXTERNAL COMMANDS ##
################################
# TODO: These commands are installed/tapped separately, so they should be completed only when present

##############
### BUNDLE ###

__fish_brew_complete_cmd 'bundle' "Install or upgrade all dependencies in a Brewfile"
__fish_brew_complete_arg 'bundle; and [ (count (__fish_brew_args)) = 1 ]' -s v -l verbose -d "Print more details"

# --file/--global option is available for bundle command and all its subcommands except exec
__fish_brew_complete_arg 'bundle;
        and not __fish_brew_subcommand bundle exec;
        and not __fish_brew_opt --file --global
    ' -l file -r -d "Specify Brewfile"
__fish_brew_complete_arg 'bundle;
        and not __fish_brew_subcommand bundle exec;
        and not __fish_brew_opt --file --global
    ' -l global  -d "Use \$HOME/.Brewfile"

__fish_brew_complete_sub_cmd 'bundle' 'dump'    "Write all installed casks/formulae/taps into a Brewfile"
__fish_brew_complete_sub_cmd 'bundle' 'cleanup' "Uninstall all dependencies not listed in a Brewfile"
__fish_brew_complete_sub_cmd 'bundle' 'check'   "Check if all dependencies are installed in a Brewfile"
__fish_brew_complete_sub_cmd 'bundle' 'exec'    "Run an external command in an isolated build environment"

# --force is available only for the dump/cleanup subcommands
__fish_brew_complete_sub_arg 'bundle' 'dump cleanup' -l force -d "Uninstall dependencies or overwrite an existing Brewfile"

# --no-upgrade is available for bundle command and its check subcommand
__fish_brew_complete_arg 'bundle; and [ (count (__fish_brew_args)) = 1 ];
        or __fish_brew_subcommand bundle check
    ' -l no-upgrade -d "Don't run brew upgrade for outdated dependencies"


################
### SERVICES ###

__fish_brew_complete_cmd 'services' "Integrates Homebrew formulae with macOS's launchctl manager"
__fish_brew_complete_arg 'services; and [ (count (__fish_brew_args)) = 1 ]' -s v -l verbose -d "Print more details"

__fish_brew_complete_sub_cmd 'services' 'list'    "List all running services for the current user"
__fish_brew_complete_sub_cmd 'services' 'run'     "Run service without starting at login/boot"
__fish_brew_complete_sub_cmd 'services' 'start'   "Start service immediately and register it to launch at login/boot"
__fish_brew_complete_sub_cmd 'services' 'stop'    "Stop service immediately and unregister it from launching at login/boot"
__fish_brew_complete_sub_cmd 'services' 'restart' "Stop and start service immediately and register it to launch at login/boot"
__fish_brew_complete_sub_cmd 'services' 'cleanup' "Remove all unused services"

__fish_brew_complete_sub_arg 'services' 'run start stop restart' -l all -d "Run all available services"
__fish_brew_complete_sub_arg 'services' 'run start stop restart' -a '(__fish_brew_suggest_services)'

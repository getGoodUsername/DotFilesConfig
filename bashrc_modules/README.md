# Why Modules?
>
> I get the ability to pick and choose what I want to have in your personal startup script! Not every computer I have is going to have `zoxide` installed, or any other fancy tool!

## General Organization

- **NOTE, look at [module naming conventions](#module-naming-conventions)**
  - Almost all rules there also apply to any directory name.
- Top Level Directories
  - `00_Mandatory_First`
    - the modules here MUST always be run first
  - `01_Core`
    - this is what I expect to be the most useful for most installations
  - `02_Optional_Fancy`
    - this includes all the special stuff to include if you have any of the mentioned special tools or setups.
    - this will also typically include anything that is more resource intensive and therefore is *not recommended to be ran with potato* computers
  - `03_Mandatory_Last`
    - the files here MUST always be run last
- Within each top level directory there can exist more directories to further organize
  - still must follow [naming conventions](#module-naming-conventions)

## Important Info

### `$PROMPT_COMMAND` rules

- when modifying `PROMPT_COMMAND`, always append to it like so

```bash
PROMPT_COMMAND+=";<you command>;"
PROMPT_COMMAND="${PROMPT_COMMAND};function_to_run;"
PROMPT_COMMAND=";function_to_run;something_else_also;${PROMPT_COMMAND}"
```

- basically, make sure to **start and end with a semi colon** with your additions to `PROMPT_COMMAND`!!!
- there is a *whole lot more* limitations with PROMPT_COMMAND (that I impose)
  - ***PLEASE READ MORE ABOUT `DA RULES` FOR `PROMPT_COMMAND`: [HERE](./03_Mandatory_Last/01_prompt_command_final_clean.sh)***

### Module loading implications (due to sourcing step)

- any variables that is global in a module will be global in interactive bash session
  - **consider:**
    - declaring variables within functions using the `local` keyword
    - unset variables after done using them with `unset -v` if declared globally in module
    - **if and only if** the module you are making is within `Mandatory_First`, you can make a cleanup module in `Mandatory_Last` to unset your global variables
- ***DON'T USE `exit`***
  - the sourced module acts on the current shell and therefore will never allow shell to fully 'open'!

### Module naming conventions

- **ALWAYS** end module with `.sh` extension.
  - **IF MAKING DIRECTORY DON'T ADD ANY EXTENSION**
- **ALWAYS** number the modules to designate ordering
  - must be two digits always, 5 -> 05, 42 -> 42
- module names must follow the following naming pattern:
  - **`[0-9]{2}_<your module name>.sh`**
- `<your module name>` must solely be made of **chars within `[a-zA-Z0-9_-]`**
  - *can only have sequences of '_' of size 1 in module name*
    - any longer makes module function naming confusing
  - *can NOT start your module name with '_'*
    - again, having to due with function naming
- Examples:
  - Allowed: `00_run_1st.sh`
    - module name here is `run_1st`
  - Allowed: `05_run_6th.sh`
    - module name here is `run_6th`
  - **NOT ALLOWED**: `5__hello___world-this-is_wrong!.module`
    - Allowed: `05_hello_world_this_is_right_exclamation_mark.sh`
      - module name here is `hello_world_this_is_right_exclamation_mark`
- **ON DIR NAMES & SEQUENCE NUMBERS**
  - dir numbering sequences can't be shared with a module in the same parent dir.
  - Example:
  - `01_Dir` and `01_mod.sh` are siblings under dir `11_TLD`
    - THIS IS ***NOT ALLOWED***
    - You have to choose what is to be ran first
      - Either we descend down into `01_Dir` first OR
      - we import `01_mod.sh` first.

### Function rules

- Naming rules imposed to avoid collisions and to be able to quickly tell what module is loading what function.
- Function names must follow the following naming pattern:
  - **`function __<dir core name>::<module core name>::<func name>`**
  - if function in module is nested under more than one dir level, separate subsequent dirnames with '::' (demonstrated in an example below)
  - **dir core name**: `dir name - number ordering`
  - **module core name**: `module name - number ordering - .sh`
  - **func name**: what you would otherwise name the function outside of my enforced naming standards.
  - Examples of converting `name -> core name`:
    - `<dir name> = 05_hello_world`
    - `<dir core name> = hello_world`
    - `<module name> = 07_do_something.sh`
    - `<module core name> = do_something`
  - Examples for making function names in modules:
    - naming of a function in dir `03_Mandatory_Last` in module `03_hello_world.sh` whose function name would normally be `life_is_full_of_wonder`
      - `function __Mandatory_Last::hello_world::life_is_full_of_wonder`
    - naming of a function in top level dir `05_Cool`, under dir `02_Custom` in module `09_my_mod.sh` whose function name would normally be `breathe_baby`
      - `function __Cool::Custom::my_mod::breathe_baby`
- If function is only used within your single module use:
  - `unset -f <name of your function>`
- If function is long living, and is expected to run outside of your module, consider using (unless you would like to explicitly redefine the function later on):
  - `readonly -f <name of your function>`

### Tips & Tricks

- bash globs are (look under the *Pathname Expansion* section in the bash manpage) sorted in ascii ascending order (unless shell option **nocaseglob** is enabled)
  - take advantage of this when loading scripts into your bashrc
  - `01_Core/*.sh` will list all modules in `01_Core`, not under another dir, in order!

## Example scripts

- replace `"${HOME}/bashrc_modules"` with your `bashrc_modules` location.
  - I would recommend to create a symbolic link in `~` to `bashrc_modules`
- Note: Use of `find` instead of something like `**/*.sh` because `**/*.sh` implicitly requires:
  - `shopt -s globstar`
- Also, if `shopt -s dotglob` is enabled, can result in unexpected execution
- more dependable to use `find` in order to avoid having to think about what has or has not been enabled in the current bash shell... and then returning to that state, etc, etc, etc.
- also use `-H` option with `find` to allow for `"${HOME}/bashrc_modules"` to be a symbolic link

### Load All Modules

```bash
source <(
    find -H "${HOME}/bashrc_modules" -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\';/'
)
```

### Load All With Notification If Error

```bash
source <(
    find -H "${HOME}/bashrc_modules" -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\'; if [ $? -ne 0 ]; then echo \'ERROR: \\1\'; fi/'
)
```

### Load All Except Blacklist (With Error Notification)

- process all path names through `realpath` to ensure every path string is the same
  - `./<path>` and `<path>` are equivalent but uniq won't see it as so!

```bash
source <(
    find -H "${HOME}/bashrc_modules" -type f -name '[^.]*.sh' \
        | sort \
        | xargs realpath \
        | sort --merge - <(xargs --no-run-if-empty --arg-file="${HOME}/.bashrc_blacklist_modules.txt" realpath | sort) \
        | uniq -u \
        | sed -E $'s/(^.+$)/source \'\\1\'; if [ $? -ne 0 ]; then echo \'ERROR: \\1\'; fi/'
)
```

### Make Blacklist File (Interactive)

- send EOF (usually ctrl + d) to stop!

```bash
select blacklist_fname in $(find -H "${HOME}/bashrc_modules" -name '[^.]*.sh' | xargs realpath -s | sort); do
    printf '%s\n' "$blacklist_fname" >> "${HOME}/.bashrc_blacklist_modules.txt";
    echo "${blacklist_fname} added to blacklist!";
done
```

### Load Some

```bash
source <(
    find -H \
    "${HOME}/bashrc_modules"/[0-9][0-9]_Mandatory* \
    "${HOME}/bashrc_modules"/Some_Selection \
    -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\';/'
)
```

### Profile `.bashrc` Time

- `-i` ensures that shell is treated as interactive
  - sometimes, .bashrc will include a section to avoid running all the extra setup if not interactive, therefore in order to make sure our whole rc file gets tested add `-i`

```bash
hyperfine --shell=none "bash --rcfile ${HOME}/.bashrc -ci ''"
```

### Profile Module Time (macro)

```bash
function profile_macro
{
    local modules_joined_file;

    modules_joined_file="$(mktemp)"; readonly modules_joined_file;
    # shellcheck disable=SC2312,SC2016
    find -H "${HOME}/bashrc_modules" -type f -name '[^.]*.sh'\
        | sort \
        | xargs realpath \
        | sort --merge - <(xargs --no-run-if-empty --arg-file="${HOME}/.bashrc_blacklist_modules.txt" realpath | sort) \
        | uniq -u \
        | xargs sh -c 'for module in "$@"; do  cat "${module}"; printf "\n\n\n"; done' join_modules >| "${modules_joined_file}"

    hyperfine --shell=none "bash --norc ${modules_joined_file}"
    rm "${modules_joined_file}"
}

profile_macro
```

### Profile Module Time (micro)

```bash
function profile_micro
{
    local -ri RUNS_PER_MODULE=25;
    local json_output_file_hyperfine;

    json_output_file_hyperfine="$(mktemp)"; readonly json_output_file_hyperfine;
    # shellcheck disable=SC2312,SC2016
    find -H "${HOME}/bashrc_modules" -type f -name '[^.]*.sh'\
        | sort \
        | xargs realpath \
        | sort --merge - <(xargs --no-run-if-empty --arg-file="${HOME}/.bashrc_blacklist_modules.txt" realpath | sort) \
        | uniq -u \
        | xargs sh -c 'for module in "$@"; do printf "bash %s\0" "${module}"; done' make_cmd \
        | xargs -0 hyperfine --shell=none --runs "${RUNS_PER_MODULE}" --export-json "${json_output_file_hyperfine}"

    # shellcheck disable=SC2312
    jq --raw-output '.results[] | "\(.mean * 1000) ms \(.command)"' "${json_output_file_hyperfine}" \
        | sed -E \
            -e 's/^([0-9]+)\.([0-9]{2})[^m]*ms/\1.\2 ms/' \
            -e 's/^([0-9]{1})\./0\1./' \
            -e 's/(^[^b]+)bash /\1/' \
            -e 's:ms .+/bashrc_modules:ms ...:' \
        | sort -rn \
        | ${PAGER:-less}

    rm "${json_output_file_hyperfine}"
}

profile_micro
```

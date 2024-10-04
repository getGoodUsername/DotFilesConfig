# Why Modules?
> I get the ability to pick and choose what you want to have in your personal startup script! Not every computer I have is going to have `zoxide` installed, or any other fancy tool!


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


## Important Info!

### `$PROMPT_COMMAND` rules
- when modifying `PROMPT_COMMAND`, always append to it like so
```bash
PROMPT_COMMAND+=";<you command>;"
PROMPT_COMMAND="${PROMPT_COMMAND};function_to_run;"
PROMPT_COMMAND=";function_to_run;something_else_also;${PROMPT_COMMAND}"
```
- basically, make sure to **start and end with a semi colon** with your additions to `PROMPT_COMMAND`!!!
- there is a *whole lot more* limitations with PROMPT_COMMAND (that I impose)
    - ***PLEASE READ MORE ABOUT `DA RULES` FOR `PROMPT_COMMAND`: [HERE](./03_Mandatory_Last/prompt_command_final_clean.sh)***

### Module loading implications (due to sourcing step)
- any variables that is global in a module will be global in interactive bash session
    - **instead:**
        - declare variables within functions using the `local` keyword
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
- `<your module name>` must solely be made of **chars within `[a-zA-Z0-9_]`**
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
    - **`__<dir core name>__<module core name>__<func name>`**
    - if function in module is nested under more than one dir level, separate subsequent dirnames with '__' (demonstrated in an example below)
    - **dir core name**: `dir name - number ordering`
    - **module core name**: `module name - number ordering - .sh`
    - **func name**: what you would otherwise name the function outside of my enforced naming standards.
    - Examples name -> core name:
        - `<dir name> = 05_hello_world`
        - `<dir core name> = hello_world`
        - `<module name> = 07_do_something.sh`
        - `<module core name> = do_something`
    - Examples for making function names in your modules:
        - naming of a function in dir `03_Mandatory_Last` in module `03_hello_world.sh` whose function name would normally be `life_is_full_of_wonder`
            - `__Mandatory_Last__hello_world__life_is_full_of_wonder`
        - naming of a function in top level dir `05_Cool`, under dir `02_Custom` in module `09_my_mod.sh` whose function name would normally be `breathe_baby`
            - `__Cool__Custom__my_mod__breathe_baby`
- If function is only used within your single module use:
    - `unset -f <name of your function>`
- If function is long living, and is expected to run outside of your module, consider using (unless you would like to explicitly redefine the function later on):
    - `readonly -f <name of your function>`

### Tips & Tricks
- bash globs are (look under the *Pathname Expansion* section in the bash manpage) sorted in ascii ascending order (unless shell option **nocaseglob** is enabled)
    - take advantage of this when loading scripts into your bashrc
    - `01_Core/*.sh` will list all modules in `01_Core`, not under another dir, in order!

## Example scripts
- replace `<bashrc modules location>` with the `bashrc_modules` location.
    - I would recommend to create a symbolic link in `~` to `bashrc_modules`
- Note: Use of `find` instead of something like `**/*.sh` because `**/*.sh` would implicitly requires:
    - shopt -s globstar
- shopt -s dotglob can result in unexpected execution
- more dependable to use find in order to avoid having to think about what has or has not been enabled in the current bash shell... and then returning to that state, etc, etc, etc.
- also use -H option with find to allow for bashrc modules location to be a symbolic link

### Load All Modules
```bash
source <(
    find -H <bashrc modules location> -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\';/'
)
```

### Load All With Error Notification
```bash
source <(
    find -H <bashrc modules location> -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\'; if [ $? -ne 0 ]; then echo \'ERROR: \\1\'; fi/'
)
```

### Load All Except Blacklist
- process all path names through `realpath` cmd line util to ensure every path string is the same, `./<path>` and `<path>` are equivalent but uniq won't see it as so!
```bash
declare -a module_blacklist;
module_blacklist=\
(
    '<path_to_module_0>'
    '<path_to_module_1>'
    '...'
    '<path_to_module_n>'
)
source <(
    find -H <bashrc modules location> -type f -name '[^.]*.sh' \
        | sort \
        | xargs realpath \
        | sort --merge - <(realpath < | sort) \
        | uniq -u
)
```

### Load Some
```bash
source <(
    find -H \
    <bashrc modules location>/[0-9][0-9]_Mandatory* \
    <bashrc modules location>/Some_Selection \
    -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\';/'
)
```

### Load All & Log Time (macro)
```bash
module_start_time="${EPOCHREALTIME}";
source <(
    find -H <bashrc modules location> -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/source \'\\1\';/'
)
module_end_time="${EPOCHREALTIME}";
module_elapsed_time="$(bc <<< "(${module_end_time} - ${module_start_time}) * 1000")"
echo "time taken to load modules: ${module_elapsed_time}ms"
unset -v module_start_time  module_end_time  module_elapsed_time
```

### Load All & Log Time (micro)
```bash
function check_module_time
{
    local start;
    local end;
    local elapsed_ms;
    local -r module="$1";

    start="$EPOCHREALTIME"
    source "${module}"
    end="$EPOCHREALTIME";

    elapsed_ms="$(bc <<< "(${end} - ${start}) * 1000")";
    echo "${elapsed_ms}: ${module}" >> load_module_time_log.log
}

echo "************************ start of log: ${EPOCHREALTIME} ************************" >> load_module_time_log.log
source <(
    find -H <bashrc modules location> -type f -name '[^.]*.sh' \
        | sort \
        | sed -E $'s/(^.+$)/check_module_time \'\\1\';/'
)
echo "************************ end of log: ${EPOCHREALTIME} ************************" >> load_module_time_log.log
printf '\n\n\n\n' >> load_module_time_log.log
unset -f check_module_time
```
- since bash globs are AFAIK always sorted in ascending order, take advantage of this when loading scripts into your bashrc
    - Example: `01_Core/*.sh`
- When making functions in a module, start the function name with two '_', then the core name of the module (if module dir name is 02_Optional_Fancy/00_hello_world, the core name is Optional_Fancy__hello_world), and then the actual name of the function to avoid collisions. If the function is not meant be to long lived please consider using `unset -f <name of function>` and if it is meant to be long lived, please use `readonly -f` to avoid any other module accidentally redefining your function.
    - Example of function naming in module name 05_Cool under the 01_Core dir where the function name would otherwise be `say_hello`:
        - `function __Core_dir__Cool__say_hello`
    - General pattern: `__<dir name>__<module name>__<func name>`

## Example script to load in all modules

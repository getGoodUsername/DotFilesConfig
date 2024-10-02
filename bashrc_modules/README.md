# Why Modules?
> I get the ability to pick and choose what you want to have in your personal startup script! Not every computer I have is going to have `zoxide` installed, or any other fancy tool!


## General Dir Organization
- `00_Mandatory_First`
    - the modules here MUST always be run first
- `01_Core`
    - this is what I expect to be the most useful for most installations
- `02_Optional_Fancy`
    - this includes all the special stuff to include if you have any of the mentioned special tools or setups.
    - this will also typically include anything that is more resource intensive and therefore is *not recommended to be ran with potato* computers
- `03_Mandatory_Last`
    - the files here MUST always be run last


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
- number the modules within a dir to designate an ordering
- module names must follow the following naming pattern:
    - **`[0-9]{2}_<your module name>.sh`**
- Examples:
    - `01_Core/00_run_1st`
        - module name here is `run_1st`
    - `01_Core/05_run_6th`
        - module name here is `run_6th`
- **ALWAYS** end module with `.sh` extension.

### Function rules
- Naming rules imposed to avoid collisions and to be able to quickly tell what module is loading what function.
- Function names must follow the following naming pattern:
    - **`__<dir core name>__<module core name>__<func name>`**
    - **dir core name**: `dir name - number ordering`
    - **module core name**: `module name - number ordering - .sh`
    - **func name**: what you would otherwise name the function outside of my enforced naming standards.
    - Examples:
        - `dir name = 05_hello_world`
        - `dir core name = hello_world`
        - `module name = 07_do_something.sh`
        - `module core name = do_something`
        - naming of a function in dir `03_Mandatory_Last` in module `03_hello_world.sh` whose function name would normally be `life_is_full_of_wonder`
            - `__Mandatory_Last__hello_world__life_is_full_of_wonder`
- If function is only used within your single module use:
    - `unset -f <name of your function>`
- If function is long living, and is expected to run outside of your module, consider using (unless you would like to explicitly redefine the function later on):
    - `readonly -f <name of your function>`

### Tips & Tricks
- bash globs are (look under the *Pathname Expansion* section in the bash manpage) sorted in ascending order (unless shell option **nocaseglob* is enabled)
    - take advantage of this when loading scripts into your bashrc
    - `01_Core/*.sh` will list all the modules in order!

## Example script to load in all modules
```bash

```
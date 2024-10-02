# Why Modules?
- the the main reason is the ability to be able to pick and choose what you want to have in your personal startup script. Not every computer I have is going to have zoxide installed, or any other fancy tool!


## General Dir Organization
- 00_Mandatory_First
    - the modules here MUST always be run first
- 01_Core
    - this is what I expect to be the most useful for most installations
- 02_Optional_Fancy
    - this includes all the special stuff to include if you have any of the mentioned special tools or setups.
- 03_Mandatory_Last
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
- there is a *whole lot more* of limitations with PROMPT_COMMAND (that I impose)
    - ***PLEASE READ MORE ABOUT `DA RULES` FOR `PROMPT_COMMAND`: [HERE](./03_Mandatory_Last/prompt_command_final_clean.sh)***

### Modules implications (due to sourcing step)
- any variables that is global in a module will be global in interactive bash session
    - **instead:**
        - declare variables within functions using the local key word
        - unset variables after done using them with `unset -v`
        - **if and only if** the module you are making is within `Mandatory_First`, you can make a cleanup module in `Mandatory_Last`
- ***DON'T USE `exit`***
    - the sourced module enacts on the current shell, exit will be on the interactive shell and therefore will never allow bash to 'open'!

### Module naming conventions
- number the modules within a dir to designate an ordering
    - `01_Core/00_run_1st`
    - `01_Core/05_run_6th`
- **ALWAYS** end module with `.sh` extension.

### Tips & Tricks
- since bash globs are AFAIK always sorted in ascending order, take advantage of this when loading scripts into your bashrc, eg, 01_Core/*.sh will list all the modules in order!
- When making functions in a module, start the function name with two '_', then the core name of the module (if module dir name is 02_Optional_Fancy/00_hello_world, the core name is Optional_Fancy__hello_world), and then the actual name of the function to avoid collisions. If the function is not meant be to long lived please consider using `unset -f <name of function>` and if it is meant to be long lived, please use `readonly -f` to avoid any other module accidentally redefining your function.
    - Example of function naming in module name 05_Cool under the 01_Core dir where the function name would otherwise be `say_hello`:
        - `function __Core_dir__Cool__say_hello`
    - General pattern: `__<dir name>__<module name>__<func name>`

## Example script to load in all modules

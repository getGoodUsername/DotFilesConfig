# Why Modules?
- the the main reason is the ability to be able to pick and choose what you want to have in your personal startup script. Not every computer I have is going to have zoxide installed, or any other fancy tool

## General Dir Organization
- 00_Mandatory_First
    - the modules here MUST always be run first
- 01_Core
    - this is what I expect to be the most useful for most installations
- 02_Optional_Fancy
    - this includes all the special stuff to include if you have any of the mentioned special tools or setups.
- 03_Mandatory_Last
    - the files here MUST always be run last

## WARNINGS/NOTES when making more modules
- when modifying `PROMPT_COMMAND`, always append to it like so
```bash
PROMPT_COMMAND+=";<you command>;"
PROMPT_COMMAND="${PROMPT_COMMAND};function_to_run;"
PROMPT_COMMAND=";function_to_run;something_else_also;${PROMPT_COMMAND}"
```
- basically, make sure to **start and end with a semi colon** with your additions to `PROMPT_COMMAND`!!!
- NOTE, all these modules will be SOURCED, meaning that any variables that are declared globally in a module will also continue to be declared in the bash shell. Also, when sourcing, it is more or less equivalent to copy and pasting the code into the current shell's environment, ***DON'T USE `exit`*** as the shell will never open...
    - you can get around this by making variables within functions with the local keyword, or `unset -v` at the end of your module, or **if and only if** the module you are making is within `Mandatory_First` make a cleanup module in `Mandatory_Last`
- number the modules within a dir to designate an ordering
    - `01_Core/00_run_1st`
    - `01_Core/05_run_6th`
- ALWAYS end module with `.sh` extension.
- since bash globs are AFAIK always sorted in ascending order, take advantage of this when loading scripts into your bashrc, eg, 01_Core/*.sh will list all the modules in order!
- When making functions in a module, start the function name with two '_', then the core name of the module (if module dir name is 02_Optional_Fancy/00_hello_world, the core name is Optional_Fancy__hello_world), and then the actual name of the function to avoid collisions. If the function is not meant be to long lived please consider using `unset -f <name of function>` and if it is meant to be long lived, please use `readonly -f` to avoid any other module accidentally redefining your function.
    - Example of function naming in module name 05_Cool under the 01_Core dir where the function name would otherwise be `say_hello`:
        - `function __Core_dir__Cool__say_hello`
    - General pattern: `__<dir name>__<module name>__<func name>`

## Example script to load in all modules

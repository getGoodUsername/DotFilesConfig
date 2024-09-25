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
PROMPT_COMMAND+=";function_to_run;"
PROMPT_COMMAND+=";function_to_run;something_else_also;"
```
- basically, make sure to start and end with a semi colon with prompt_command additions!!!
- NOTE, all these modules will be SOURCED, meaning that any variables that are declared globally in a module will also continue to be declared in the bash shell
    - you can get around this by making variables within functions with the local keyword or if you need a global variable, make a module in the `Mandatory_Last` dir
- number the modules within a dir to designate an ordering
    - 01_Core/00_run_1st
    - 01_Core/05_run_6th
- ALWAYS end module with `.sh` extension.
- since bash globs are AFAIK always sorted in ascending order, take advantage of this when loading scripts into your bashrc, eg, 01_Core/*.sh will list all the modules in order!

### SYNOPSIS
```
ligo print cst SOURCE_FILE
```

### DESCRIPTION
This sub-command prints the source file in the CST stage, obtained after preprocessing and parsing.

### FLAGS
**--deprecated**
enable deprecated language PascaLIGO

**--display-format FORMAT**
the format that will be used by the CLI. Available formats are 'dev', 'json', and 'human-readable' (default). When human-readable lacks details (we are still tweaking it), please contact us and use another format in the meanwhile. (alias: --format)

**--no-color**
disable coloring in CLI output

**--project-root PATH**
The path to root of the project.

**--syntax SYNTAX**
the syntax that will be used. Currently supported syntaxes are "cameligo" and "jsligo". By default, the syntax is guessed from the extension (.mligo and .jsligo respectively). (alias: -s)

**-help**
print this help text and exit (alias: -?)



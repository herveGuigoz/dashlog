# DASHLOG

Command line tool for generating a changelog from git tags and semantic commit history.

## Install

```
$ dart pub global activate dashlog
```

## Usage

```
Usage: dashlog create [arguments]
-h, --help                                   Print this usage information.
-o, --output=<path>                          The output path
                                             (defaults to "CHANGELOG.md")
-t, --types=<patterns separated by comma>    Commits types (other types will be ignored)
                                             (defaults to "feat", "fix", "test", "docs", "build")
```

## Semantic Commit Messages

> Format: `<type>(<scope>): <subject>` 

```
feat: add hat wobble
^--^  ^------------^
|     |
|     +-> Summary in present tense.
|
+-------> Type: chore, docs, feat, fix, refactor, style, or test.

NB: scope is optional
```

References:

- https://www.conventionalcommits.org/

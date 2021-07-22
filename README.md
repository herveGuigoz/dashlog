# DASHLOG

Command line tool for generating a changelog from git tags and commit history. 

### Semantic Commit Messages

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

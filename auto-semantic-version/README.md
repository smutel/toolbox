# Conventional Commits

* [https://www.conventionalcommits.org](https://www.conventionalcommits.org)

# Standard version

* [https://github.com/conventional-changelog/standard-version](https://github.com/conventional-changelog/standard-version)

# Hooks

* [https://dev.to/craicoverflow/enforcing-conventional-commits-using-git-hooks-1o5p](https://dev.to/craicoverflow/enforcing-conventional-commits-using-git-hooks-1o5p)
* [https://github.com/craicoverflow/sailr](https://github.com/craicoverflow/sailr)
* [https://prahladyeri.com/blog/2019/06/how-to-enforce-conventional-commit-messages-using-git-hooks.html](https://prahladyeri.com/blog/2019/06/how-to-enforce-conventional-commit-messages-using-git-hooks.html)

# Test during CI

```bash
git log --no-decorate --oneline --pretty=tformat:%s origin/master.. | while read line; do echo $line; echo $line | ~/IAC-CIO/sailr/sailr.sh; if [[ $? -ne 0 ]]; then exit 1; fi; done
```

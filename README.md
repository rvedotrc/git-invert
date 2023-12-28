# git-invert

Do you want your `git log` output to run older-to-newer, and you haven't heard of `--reverse`?

Do you want to find out what happened _since_ a given commit, rather than what happened _before_ it,
and you haven't found the `git log` options to do that either?

Then `git-invert` is the tool for you!

`git-invert` inverts the parent-child relationship between commits, so that `git log` starts
by showing a commit representing the time when the repository was empty, before the first commit;
then continues to newer and newer commits, ending with all of your code.

## Usage

Requires a new-ish Ruby.

Clone `git-invert`, then add its `bin` directory to your `PATH`.

Then, from inside the repository you want to invert:

```shell
# Repository has annoying parent-older-than-child ordering
git invert
# Repository now has much better inverted ordering!

# Take a look at your nice clean codebase
ls

# Enjoy the new, much more readable, history:
git log --graph --stat
```

## Features (not bugs)

* All commit hashes change
* Does not preserve commit signatures
* Once inverted, most git commands won't work the way you probably expect them to
* Impossible to continue development in any meaningful manner

## Summary

`git-invert` truly is the tool that you never knew you wanted.

In fact, not only that, but `git-invert` is also the tool that you knew you never wanted!

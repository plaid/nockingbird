# Contributing

1.  Update local master branch:

        $ git checkout master
        $ git pull origin master

2.  Create initial-prefixed feature branch:

        $ git checkout -b dc-feature-x

3.  Make one or more atomic commits, and ensure that each commit has a
    descriptive commit message. Commit messages should be line wrapped
    at 72 characters.

4.  Run `make test`, and address any errors. Preferably, fix commits in
    place using `git rebase` or `git commit --amend` to make the changes
    easier to review.

5.  Open a pull request from the feature branch to the master branch.

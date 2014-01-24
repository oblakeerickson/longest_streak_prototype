Longest Streak
==============

**NOTE:** This project has been moved to: https://github.com/oblakeerickson/longest_streak

Longest Streak uses the GitHub API to figure out who has the longest streak on GitHub.

### Implementation

Currently this is just a simple command line app, but I plan on turning it into a Rake task as part of a Rails App so that I can provide an API and an interface for displaying the data I'm collecting.

### How to use

* fork this project
* clone it to your code folder
* create .password and .username files
* run with `ruby longest_streak.rb`


### TODO

* get netrc to work (this might have been fixed in a recent pull request)
* use oauth
* calculate streaks longer that 366 days


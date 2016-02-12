Timerepo
=========

A Historical recall of your git checkin history, one year at a time.

## Background

There is a concept of a 6 month rule in programming that states:

> "Every programer should look at what they were doing 6 months ago and be disgusted about the way they were doing things" [source](http://blog.marcomonteiro.net/post/the-six-months-rule)

That isn't to say that everything you've done in the past is terrible, but reflecting on where you were is an excellent way 
to measure your growth over time. If you aren't making mistakes, you aren't pushing the boundaries enough and potentially not growing.

## Usage
```
ruby timerepo.rb [options]
```

## Options
    -v, --[no-]verbose               Run verbosely
    -d, --date_override %Y-%m-%d     Override the current date, defaults to current system date.


## Adding Repositories

To add or remove a repository, edit the repositories.yaml file and add the name of the repo you wish to add.


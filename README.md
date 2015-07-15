# depl

depl evolved out of Movable Ink's deployments, which typically involved capistrano. Over time, the capistrano scripts got heavier and multiple datacenters were added, each with dozens of machines. We used Chef for provisioning, and found that it was impossible to keep capistrano up-to-date with the comings and goings of new machines. A separation was needed.

## The depl workflow

The goal of depl is to separate deployment into two parts: specifying that a new version of code should be deployed, and actually deploying that code to the machines that need it.

A typical deployment would look like this:

    » depl production
    Attempting to deploy d836d33

    Difference of 6 new commit(s) between de0aed0 and d836d33:

        d836d33 Michael Nutt         8 minutes ago	   ignore our own .deploy
        9046842 Michael Nutt         8 minutes ago	   make bin executable
        b2b4038 Michael Nutt         8 minutes ago	   clean up gemspec
        e57b428 Michael Nutt         18 minutes ago	   refactoring
        4fba6fa Michael Nutt         26 minutes ago	   add commit comparisons
        349c4ce Michael Nutt         76 minutes ago	   first pass at sending to s3

    Deploy? ([y]es / [n]o / [g]ithub) : y
    Deployed d836d33

Movable Ink uses Chef to push out new code, and Chef is set up to use environment-based branches for its deployment. This allows newly provisioned machines to get the latest deployed version while not requiring changes to the provisioning system every time the project is updated.

## History

* _0.0.1_ - Forked from deploy_s3; initial release.

## License

The MIT License. See LICENSE.md.

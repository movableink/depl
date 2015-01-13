# deploy_s3

deploy_s3 evolved out of Movable Ink's deployments, which typically involved capistrano. Over time, the capistrano scripts got heavier and multiple datacenters were added, each with dozens of machines. We used Chef for provisioning, and found that it was impossible to keep capistrano up-to-date with the comings and goings of new machines. A separation was needed.

## The deploy_s3 workflow

The goal of deploy_s3 is to separate deployment into two parts: specifying that a new version of code should be deployed, and actually deploying that code to the machines that need it.

A typical deployment would look like this:

    » ds3 production
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

deploy_s3 relies on a `.deploy` file to tell it where to write the git hash.  Right now it is tied to Amazon S3, but using fog it could send to any cloud provider.

Movable Ink uses Chef to push out new code, and Chef can simply read s3 for the revision to know exactly which version to deploy. This allows newly provisioned machines to get the latest deployed version while not requiring changes to the provisioning system every time the project is updated.

## History

* _0.0.3_ - Fix command-line option parsing to work as advertised.
* _0.0.2_ - Always save the full git sha to s3. Many CI and deployment tools always upload using the full sha in the path.
* _0.0.1_ - Initial release.

## License

The MIT License. See LICENSE.md.

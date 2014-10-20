# Rationale

This document describes the reasoning and the trade-offs involved in
creating the project structure.

## Philosophy

> If you're not using docker, you're doing it wrong.

I fully agree with that statement. Docker is the best tool we have
right now to empower software developers & operations engineers to
create the best systems. It's also paramount to create enforce
automation and repeatability from time zero. Docker also provides the
best shot and providing parity between the development, test, and
production environments. With all these things in mind, I set out to
create a structure that met the following requirements:

* Automated environment setup and teardown across team members and
  machines
* Completely decoupled development from the host operating system
* Used docker to build all project deliverables
* User docker to orchestrate all dependent services
* Enforced the same workflow for development & continuous integration
* Automated process of pushing test images to an upstream registry

## Trade-offs

Most the trade-offs are present in the CI integration. I think this
area could be improved as CI services improve. My initial idea was
that CI would start the virtual machine (since it contains everything
to build & test the images) then run something like: `vagrant ssh -c
'cd /vagrant && make test-ci`. I think this is a good idea on
principle because it enforces separation between the host & development
environment and enforces the VM completely encapsulates the project's
workflow and dependencies. Unfortunately this just would not have
worked in practice.

The biggest problem is simply speed & availability. Vagrant runs on
virtualbox. Introducing virtual box as a CI dependency is simply not a
good choice. Introducing virtual box eliminates every hosted solution
(and I much prefer those) I came across. The hosted services use some
form of virtualization that is incompatible with virtual box or run
inside docker so there is no way to get a full blown virtual machine
up and running. Given these two facts, only one solution is left if
you want to do CI that way: run jenkins on bear metal. I don't think
introducing jenkins is worth it because, frankly, managing and
integrating jenkins sucks. Even if Jenkins and the processes around it
improved, test runs would already be slow. In order to ensure clean
slate for each test, a new VM would need to be created, provisioned,
dependent images pulled, project images built, then tests run. That
was just too slow and cumbersome. Also running docker inside vagrant
on jenkins resulted in test logs being lost (who needs to see failed
tests right?) because some weird IO capture things we could not debug.
In the end it just wasn't worth it. In the end Circle CI made sense
because it's very fast and offers docker integration out of the box.
It allowed to mimic the setup (pull, bootstrap fig, build images, run
test containers) and not have jenkins.

There are some trade-offs though. At the time of this writing, Circle
CI does not cache docker layers. This means large base images need to
be pulled on every test run. The company says they will eventually
solve this problem. Until then, the `make import` task can be used to
load images from tar files. `make import` depends on `make export`
which depends on `make pull`. `make export` will put tar files into
`tmp/images` and `make import` used them to import. This can be
combined with circle's `cache_directories` configuration. I found this
be of little use on large projects for a few reasons. First, projects
usually have 2-3 large base images. Say two services (redis/RDMS) and
a language base image (ruby/go/node). The total size of these images
may come in at around a few gigabytes (yes docker images are not
small). This creates a large amount of IO since circle must first
write tar files to the FS and restore them to test runner's container,
then they must be read to import them. For some projects this may
result in over 10GB of total IO (between writing to cache, restoring
cache, then reading images from cache). That doesn't account for the
CPU time required verify the tar files. In the end it made more sense
to simply run `make pull` as part of the `dependencies` section. `make
pull` works well with `-j` given there's resources to support it.
Small projects may get use of `make import` but that's on a per
project level. At this point it makes more sense to endorse `make
pull` because it's more straight forward and in the end faster than
`make import`. Hopefully this changes in the future when dependent
layers are cached on the CI side.

## Going Forward

I believe this structure is applicable to all languages and many
different teams and business. I'd like to continue to improve it since
it's the base for everything. This structure should be used to iterate
on building and shipping docker images and the workflows around it.

See [dockerbuild.info] for information & best practices around
building use case specific docker images.

## Using this Template

You are welcome to reuse and modify the template and its files. My
requirement is you keep this file in place, and links to the original
work in the appropriate files.

Adam Hawkins, October 2014

# Docker & Vagrant Based Project Template

[Docker]: http://docker.io
[Fig]: http://fig.sh
[Vagrant]: http://vagrantup.com
[CircleCI]: http://circleci.com
[Make]: http://www.gnu.org/software/make
[Makefile]: makefile

This project used [Docker][], [Vagrant][], [Fig][], and [Make][]
for building, testing, and developing docker images. [CircleCI][] is
used to build, test, and push production ready images.

The structure favors easily creating images(s) and standardizing on
ways to do common development tasks. [Fig][]
orchestrates the development environment when multiple containers are
required. [Vagrant][] encapsulates the entire environment
for repeatable development environments across computers & machines.

## New to the Project?

Here's how to get started:

```
$ vagrant up --provision
$ vagrant ssh
$ make environment && make test
```

This will spin up the virtual machine, ssh inside it, build and start
all containers, then execute tests. That should be enough to get
going. Continue reading to learn more things.

## Files & Directories

* `/doc` - Accompany code documentation
* `/dockerfiles` - Dockerfiles to build all the project's images
* `/test` - the test suite
* `/script` - provisioning, helping with deployment, misc things
* `/vagrant` - Scripts used to provision the environment
* `/tmp` - temporary artifcats and other things.
* `Makefile` - defines the minimum tasks required to build the project
* `Vagrantfile` - Vagrant configuration
* `fig.yml` - defines all the docker containers in the environment
* `circle.yml` - how to build, test, & deploy the project through
  Circle CI.
* `.dockerignore` - Things not to send to docker when building.

Add more directories at the root level as you see fit.

## Vagrant

**All work is intended to be done in the virtual machine!** If things
happen to work on the host system that is by accident rather than by
design! You've been warned!

[Vagrant][] manages the development environment. The
virtual machine encapsulates everything needed to build and run docker
containers. `docker` and `fig` are installed with the shell
provisioner. If the workflow defined in the `Makefile` requires more
CLI utils install them in the virtual machine. The
[VagrantFile](Vagrantfile) should be used to expose ports to the host
system. See the section on [coordinating development
environments](#development-environments) for more information.

## Make

`make` coordinates most day to day activities. The common targets:

* `make pull` - Pull required larger base images or service images.
* `make build` - Build all the images in the project
* `make environment` - Build, start, and link all dependent services
* `make test` - Build and run the tests image
* `make test-ci` - Runs CI level tests
* `make clean` - kill all things docker

`make pull` and `make build` can be combined with `-j` for parallel
execution. See the [makefile][] for more information.

### Building Single & Multiple Docker Images

Docker makes projects with multiple images a real pain. The `docker
build` command assumes there is only one `Dockerfile`. It can read
content from stdin, but then you cannot add/copy filers and other
things. The `makefile` uses a replacement workaround to solve this
problem. There is no `Dockerfile` at the root. Instead each file
inside `dockerfiles/` is linked to `/Dockerfile` then `docker build`
is run. This solution allows N images to be built with or without
order dependence. It also decomposes acceptably when the project only
requires one image. See the [makefile][] for more information.

### .dockerignore

Docker sends _everything_ on the filesystem as build context. This may
slow down builds if a large number of unused artifacts end up in the
filesystem. [.dockerignore](.dockerignore) lists things that should
never be used when building containers. Update this file as the
project goes on.

## Testing & Continous Integration

The [makefile][] defines `test` and `test-ci` targets. They start
docker containers that execute tests. [CircleCI][] is used for CI
because it has the best docker support. [circle.yml](circle.yml)
configures the build. It follows the same process as described at the
beginning of the readme. The build process looks like this:

1. start docker
2. pull base images
3. `make environment`
4. `make test-ci`
5. `make deploy` (when on master)

`overrrides` is used to ensure cricle CI does not do infer & act on
project semantics. This will slow down the built and may cause it
fail. See the docs on [build
configuration](https://circleci.com/docs/configuration) for more
information. Also see the [rationale](doc/RATIONALE.md) for the
reasoning behind these decisions.

## Development Environments

[fig][] and [vagrant][] manage the complete
development environment. Fig manages which containers should be
running, links, and how to expose ports. Example, fig will start
things like mongo, elasticsearch, redis etc. Use these containers
with docker links to provide services to the projects containers.
Project specific containers may be configured as well. See the [fig
configuration reference](http://www.fig.sh/yml.html) for more
information. Once the containers are running, the `Vagrant` file can
be used export guest ports to the host system. See the vagrant docs on
[port
forwarding](https://docs.vagrantup.com/v2/networking/forwarded_ports.html)
for more information.

## Workflow

1. Define dependent images in `fig.yml` and the `Makefile`.
2. Run `make environment`
3. Create/edit code and files in `dockerfiles`
4. Run `make test`
5. Repeat steps until build passing.

### Docker Boilerplate

This project is a template containing everything needed to bootstrap
docker based projects. It uses [Make][], [Fig][], & [Vagrant][] to a completed
automated development environment out of the box. You can started by
simply downloading the files and unzip. This process is documented
below:

```
$ mkdir my-new-project
$ cd my-new-project
$ curl -L https://github.com/ahawkins/docker-project-template/tarball/master > template.tar.gz
$ tar zxf template.tar.gz --strip-components=1 && rm template.tar.gz
```

Now you can bootstrap the development environment:

```
$ vagrant up --provision
$ vagrant ssh
$ cd /vagrant
$ make environment test
```

Please see the [README][] on github for more information.

### Usage

This repo contains template files. Once you've downloaded the files
update the to suit your project. The `Makefile` is a well documented
base to grow on. The template is provided without license, my only
request is that you keep comments at the top of the `Makefile` and the
`doc/RATIONAL.md` file in your repository.

### Next Steps

This template gives you everything you need to start doing docker
based development. Unfortunately it cannot help you with more than
that. Checkout http://dockerbuild.info more information on building
and shipping docker images.

### Authors and Contributors

This project is maintained by @ahawkins. Pull requests encouraged!

[Make]: http://www.gnu.org/software/make/
[Fig]: http://fig.sh
[Vagrant]: https://www.vagrantup.com
[README]: https://github.com/ahawkins/docker-project-template

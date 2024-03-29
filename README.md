# Packer templates for various BSD flavors written in legacy JSON

### Overview

This repository contains [Packer](https://packer.io/) templates in legacy JSON for creating
BSD Vagrant boxes.

## Current Boxes

We no longer provide pre-built binaries for these templates.

## Building the Vagrant boxes with Packer

To build all the boxes, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads),
[VMware Fusion](https://www.vmware.com/products/fusion)/[VMware Workstation](https://www.vmware.com/products/workstation) and
[Parallels](http://www.parallels.com/products/desktop/whats-new/) installed.

Parallels requires that the
[Parallels Virtualization SDK for Mac](http://www.parallels.com/downloads/desktop)
be installed as an additional preqrequisite.

There are currently base Packer templates for the supported BSD flavors:

- freebsd.json
- openbsd.json
- netbsd.json
- dragonflybsd.json

NOTE: The NetBSD box times out on `vagrant up` waiting on SSH, but `vagrant ssh` works fine. This seems to be a vagrant issue, see [mitchellh/vagrant#6640](https://github.com/mitchellh/vagrant/issues/6640).

We make use of JSON files containing user variables to build specific versions
of BSD. You tell packer to use a specific user variable file via the
-var-file= command line option and which base template to use. This will
override the default options in the base template for your BSD flavor.

For example, if you want to build FreeBSD 10.02, use the following:

    $ packer build -var-file=freebsd102.json freebsd.json

If you want to make boxes for a specific desktop virtualization platform, use
the `-only` parameter.  For example, to build FreeBSD 10.2 for VirtualBox:

    $ packer build -only=virtualbox-iso -var-file=freebsd102.json freebsd.json

The boxcutter templates currently support the following desktop virtualization
strings:

* `parallels-iso` - [Parallels](http://www.parallels.com/products/desktop/whats-new/) desktop virtualization (Requires the Pro Edition - Standard edition won't work)
* `virtualbox-iso` - [VirtualBox](https://www.virtualbox.org/wiki/Downloads) desktop virtualization
* `vmware-iso` - [VMware Fusion](https://www.vmware.com/products/fusion) or [VMware Workstation](https://www.vmware.com/products/workstation) desktop virtualization

## Building the Vagrant boxes with the box script

We've also provided a wrapper script `bin/box` for ease of use, so
alternatively, you can use the following to build FreeBSD 10.2
for all providers:

    $ bin/box build freebsd102 freebsd

Or if you just want to build FreeBSD 10.2 for VirtualBox:

    $ bin/box build freebsd102 freebsd virtualbox

## Building the Vagrant boxes with the Makefile

A GNU Make `Makefile` drives a complete basebox creation pipeline with the
following stages:

* `build` - Create basebox `*.box` files
* `assure` - Verify that the basebox `*.box` files produced function correctly
* `deliver` - Upload `*.box` files to [Artifactory](https://www.jfrog.com/confluence/display/RTF/Vagrant+Repositories), [Atlas](https://atlas.hashicorp.com/) or an [S3 bucket](https://aws.amazon.com/s3/)

The pipeline is driven via the following targets, making it easy for you to
include them in your favourite CI tool:

    make build   # Build all available box types
    make assure  # Run tests against all the boxes
    make deliver # Upload box artifacts to a repository
    make clean   # Clean up build detritus

### Proxy Settings

The templates respect the following network proxy environment variables
and forward them on to the virtual machine environment during the box creation
process, should you be using a proxy:

* http_proxy
* https_proxy
* ftp_proxy
* rsync_proxy
* no_proxy

### Tests

Automated tests are written in [Serverspec](http://serverspec.org) and require
the `vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec

The bin/box script has subcommands for running both the automated tests and for
performing exploratory testing.

Use the bin/box test subcommand to run the automated Serverspec tests. For
example to execute the tests for the Ubuntu 14.04 box on VirtualBox, use the
following:

    bin/box test ubuntu1404 virtualbox

Similarly, to perform exploratory testing on the VirtualBox image via ssh, run
the following command:

    bin/box ssh ubuntu1404 virtualbox

## Contributing


1. Fork and clone the repo.
2. Create a new branch, please don't work in your `master` branch directly.
3. Add new [Serverspec](http://serverspec.org/) or [Bats](https://blog.engineyard.com/2014/bats-test-command-line-tools) tests in the `test/` subtree for the change you want to make.  Run `make test` on a relevant template to see the tests fail (like `make test-virtualbox/freebsd102`).
4. Fix stuff.  Use `make ssh` to interactively test your box (like `make ssh-virtualbox/freebsd102`).
5. Run `make test` on a relevant template (like `make test-virtualbox/freebsd102`) to see if the tests pass.  Repeat steps 3-5 until done.
6. Update `README.md` and `AUTHORS` to reflect any changes.
7. If you have a large change in mind, it is still preferred that you split them into small commits.  Good commit messages are important.  The git documentatproject has some nice guidelines on [writing descriptive commit messages](http://git-scm.com/book/ch5-2.html#Commit-Guidelines).
8. Push to your fork and submit a pull request.
9. Once submitted, a full `make test` run will be performed against your change in the build farm.  You will be notified if the test suite fails.

### Would you like to help out more?

Contact moujan@annawake.com

### Acknowledgments

[Parallels](http://www.parallels.com/) provided a Business Edition license of
their software to run on the basebox build farm.

<img src="http://www.parallels.com/fileadmin/images/corporate/brand-assets/images/logo-knockout-on-red.jpg" width="80">

[SmartyStreets](http://www.smartystreets.com) provided basebox hosting for the box-cutter project since 2015 - thank you for your support!.

<img src="https://d79i1fxsrar4t.cloudfront.net/images/brand/smartystreets.65887aa3.png" width="320">

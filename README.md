# Alpine Package Builder

This is a Docker image for building Alpine Linux packages.

## Keys

You can use this image to generate keys if you don't already have them. Generate them in a container using the following command (replacing `Glider Labs <team@gliderlabs.com>` with your own name and email):

```
docker run \
	--name alpine-keys \
	-e PACKAGER="Glider Labs <team@gliderlabs.com>" \
	alpine-abuild \
	keygen
```

You'll see some output like the following:

```
Generating RSA private key, 2048 bit long modulus
.............................................+++
.................................+++
e is 65537 (0x10001)
writing RSA key
>>>
>>> You'll need to install /home/builder/.abuild/team@gliderlabs.com-5592f9b1.rsa.pub into
>>> /etc/apk/keys to be able to install packages and repositories signed with
>>> /home/builder/.abuild/team@gliderlabs.com-5592f9b1.rsa
>>>
>>> You might want add following line to /home/builder/.abuild/abuild.conf:
>>>
>>> PACKAGER_PRIVKEY="/home/builder/.abuild/team@gliderlabs.com-5592f9b1.rsa"
>>>
>>>
>>> Please remember to make a safe backup of your private key:
>>> /home/builder/.abuild/team@gliderlabs.com-5592f9b1.rsa
>>>
```

This output contains the path to your public and private keys. THe keys are stored in a volume for later use with --volumes-from as above. If you would like to copy the keys out of the container:

```
mkdir ~/.abuild
docker cp alpine-keys:/home/builder/.abuild/team@gliderlabs.com-5592f9b1.rsa ~/.abuild/
docker cp alpine-keys:/home/builder/.abuild/team@gliderlabs.com-5592f9b1.rsa.pub ~/.abuild/
```

## Usage

The builder can be run from your Alpine Linux package source directory or fetch from a remote git repository:

```
# Local package source
docker run --rm \
	-v "$PWD:/package" \
	-v "$HOME/.abuild/packages:/repo" \
	--volumes-from alpine-keys \
	alpine-abuild
# Official Alpine Linux repository
docker run --rm \
	-v "$HOME/.abuild/packages:/repo" \
	--volumes-from alpine-keys \
	alpine-abuild \
	build testing somepkg
# Remote repository (branchname is optional, defaults to `master`)
docker run --rm \
	-v "$HOME/.abuild/packages:/repo" \
	--volumes-from alpine-keys \
	alpine-abuild \
	build main somepkg git://example.com/yourrepo.git branchname
```

This would build the package, and place the resulting packages in `~/.abuild/packages/builder/x86_64`. Subsequent builds of packages will update the `~/.abuild/packages/builder/x86_64/APKINDEX.tar.gz` file.

You can also run the builder anywhere. You just need to mount your package source and build directories to `/package` and `/repo`, respectively.

## Entry point syntax

```
  syntax: command [parameters]

  Available commands:
    keygen
    checksum
    build [repo package] [git_url [branch]]
    help
```

## Environment

There are a number of environment variables you can change at package build time:

* `RSA_PRIVATE_KEY`: This is the contents of your RSA private key. This is optional. You should use `PACKAGER_PRIVKEY` and mount your private key if not using `RSA_PRIVATE_KEY`.
* `RSA_PRIVATE_KEY_NAME`: Defaults to `ssh.rsa`. This is the name we will set the private key file as when using `RSA_PRIVATE_KEY`. The file will be written out to `/home/builder/.abuild/$RSA_PRIVATE_KEY_NAME`.
* `PACKAGER_PRIVKEY`: Defaults to `/home/builder/.abuild/$RSA_PRIVATE_KEY_NAME`. This is generally used if you are bind mounting your private key instead of passing it in with `RSA_PRIVATE_KEY`.
* `REPODEST`: Defaults to `/repo`. If you want to override the destination of the build packages. You must also be sure the `builder` user has access to write to the destination. The entry point will attempt to `mkdir -p` this location.
* `PKGSRC`: Defaults to `/package`. If you want to override the source of the build package.
* `PACKAGER`: This is the name of the packager used in package metadata. If you use the script to generate your keys, this only needs to be set during the `keygen` command.

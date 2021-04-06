# Gopass for personal and team usage

## Description

Gopass is a password manager to manage personal passwords, company passwords and share secrets among teams.

This repo contains a dockerfile to run gopass. Also, this repo summarizes the most used gopass commands.

### What's inside?

To use gopass the dockerfile contains:

* **gpg** : used to create, import, export public and private keys
* **gopass**: tool to manage secrets

## Setting up the environment for personal use

1. Create the image
```shell
$ docker build -t gopass .
```

2. Get into the container overriding the default entrypoint
````shell
$ docker run -it --entrypoint sh gopass
````
2.1. List the available public and private keys

```shell
$ gpg -K
gpg: directory '/root/.gnupg' created
gpg: keybox '/root/.gnupg/pubring.kbx' created
gpg: /root/.gnupg/trustdb.gpg: trustdb created
```

2.2. Create the gpg public and private keys

````shell
$ gpg --full-generate-key
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
  (14) Existing key from card
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072)
Requested keysize is 3072 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 5y
Key expires at Sun Apr  5 02:31:03 2026 UTC
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: carlos valarezo
Email address: myemail@mydomain.com
Comment:
You selected this USER-ID:
    "carlos valarezo <myemail@mydomain.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key 6AA41CB001E0518E marked as ultimately trusted
gpg: directory '/root/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/root/.gnupg/openpgp-revocs.d/6A25ACE84F43A97CF422E9596AA41CB001E0518E.rev'
public and secret key created and signed.

pub   rsa3072 2021-04-06 [SC] [expires: 2026-04-05]
      6A25ACE84F43A97CF422E9596AA41CB001E0518E
uid                      carlos valarezo <myemail@mydomain.com>
sub   rsa3072 2021-04-06 [E] [expires: 2026-04-05]
````

2.3. Check the public and private keys jest created

```shell
# gpg -K
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: next trustdb check due at 2026-04-05
/root/.gnupg/pubring.kbx
------------------------
sec   rsa3072 2021-04-06 [SC] [expires: 2026-04-05]
      6A25ACE84F43A97CF422E9596AA41CB001E0518E
uid           [ultimate] carlos valarezo <myemail@mydomain.com>
ssb   rsa3072 2021-04-06 [E] [expires: 2026-04-05]
```

2.4 Create a github/gitlab/bitbucket/yourfavorite vcs to store the secrets
[Image of repo-creation](images/my-secrets-repo.png)
2.5 


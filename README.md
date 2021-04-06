# Gopass for personal and team usage

## Description

Gopass is a password manager to manage personal passwords, company passwords and share secrets among teams.

This repo contains a dockerfile to run gopass. It also summarizes the most used gopass commands.

### What's inside?

To use gopass the dockerfile contains:

* **gpg** : used to create, import, export public and private keys
* **openssh-client**: to import ssh keys  
* **gopass**: tool to manage secrets

## Setting up the environment 

1. Create a private github/gitlab/bitbucket/yourfavorite VCS to store the secrets. Setup ssh keys in your account. To do so follow this [link](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

2. Create the image
````shell
$ docker build -t gopass .
````

3. Get into the container overriding the default entrypoint and mounting the ssh keys into the container
````shell
$ docker run -it -v ~/.ssh:/ssh --entrypoint sh gopass
````

4. Add the ssh keys in order to clone the private repos inside your container
````shell
$ eval $(ssh-agent -s)
$ bash -c 'ssh-add /ssh/the-ssh-key'
$ Identity added: /ssh/the-ssh-key (myemail@mydomain.com)
````

5. List the available public and private keys

```shell
$ gpg -K
gpg: directory '/root/.gnupg' created
gpg: keybox '/root/.gnupg/pubring.kbx' created
gpg: /root/.gnupg/trustdb.gpg: trustdb created
````

6. Create the gpg public and private keys. Bear in mind that over this process a master password will be prompted, then picture one really hard to guess but really easy to remember for you. Include at least one number

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

7. Check the public and private keys just created

```shell
$ gpg -K
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
````

8. Setup the gopass root local store. This store will have the other stores. Therefore, it does not need to setup a remote repo.

````shell
$ gopass setup
[init] Initializing a new password store ...
Please select a private key for encrypting secrets:
[0] gpg - 0x27303A8D475DEE27 - carlos valarezo <myemail@mydomain.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
Use carlos valarezo (cmyemail@mydomain.com) for password store git config? [Y/n/q]: y
[init] [local]  -> OK
[init] [local] Configuring your local store ...
[init] [local] Do you want to add a git remote? [y/N/q]: n
[init] [local] Do you want to always confirm recipients when encrypting? [y/N/q]: y
[init] [local]  -> OK
````

9. Setup two different stores, one for personal secrets and another for work secrets

````shell
$ gopass init --store my-company
[init] Initializing a new password store ...
[init] WARNING: Store is already initialized
Please select a private key for encrypting secrets:
[0] gpg - 0x72D911CE63A371F9 - carlos valarezo <myemail@mydomain.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
[init] Initializing git repository (gitcli) ...
Use carlos valarezo (myemail@mydomain.com) for password store git config? [Y/n/q]: y
[init] git initialized at /root/.local/share/gopass/stores/my-company
[init] git configured at /root/.local/share/gopass/stores/my-company
[init] Git initialized
[init] Password store /root/.local/share/gopass/stores/my-company initialized for:
[init]   0x72D911CE63A371F9 - carlos valarezo <myemail@mydomain.com>
````

11. Add the remote repo to ``my-company`` store

````shell
$ gopass git remote add --store my-company origin git@github.com:carlosvalarezo/my-company-secrets.git
````
12. Setup the ```personal``` store

````shell
$ gopass init --store personal
[init] Initializing a new password store ...
[init] WARNING: Store is already initialized
Please select a private key for encrypting secrets:
[0] gpg - 0x72D911CE63A371F9 - carlos valarezo <myemail@mydomain.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
[init] Initializing git repository (gitcli) ...
Use carlos valarezo (myemail@mydomain.com for password store git config? [Y/n/q]: y
[init] git initialized at /root/.local/share/gopass/stores/personal
[init] git configured at /root/.local/share/gopass/stores/personal
[init] Git initialized
[init] Password store /root/.local/share/gopass/stores/personal initialized for:
[init]   0x72D911CE63A371F9 - carlos valarezo <myemail@mydomain.com>
````
13. Add the remote repo to ``personal`` store

````shell
$ gopass git remote add --store personal origin git@github.com:carlosvalarezo/personal-secrets.git
````
**Note:** It is worth mentioning that different GPG keys may be used for both stores

14. Check gopass is correctly setup so far
````shell
$ gopass
gopass
├── my-company (/root/.local/share/gopass/stores/my-company)
└── personal (/root/.local/share/gopass/stores/personal)
````

15. Add secrets to ```my-company``` store:

````shell
$ gopass generate -x my-company/abc/password
````

16. Add secrets to ```personal``` store:

````shell
$ gopass generate -x personal/abc/password
````

17. Sync up both (or more) stores:

````shell
$ gopass sync
````

**Possible issues:**

This warning/error might show up:

````shell
Failed to pull before git push: hint: Pulling without specifying how to reconcile divergent branches is
hint: discouraged. You can squelch this message by running one of the following
hint: commands sometime before your next pull:
hint:
hint:   git config pull.rebase false  # merge (the default strategy)
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint:
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
fatal: couldn't find remote ref master
````

Ignore it and the next timeit will not appear
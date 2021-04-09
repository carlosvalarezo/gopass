# Gopass for personal and team usage

## Description

Gopass is a password manager to manage personal passwords, company passwords and share secrets among teams.

This repository contains a dockerfile to run gopass. It summarizes gopass setup and the most used commands.

### What's inside?

To use gopass the dockerfile contains:

* **gpg** : used to create, import, export public and private keys
* **openssh-client**: to import ssh keys  
* **gopass**: tool to manage secrets

## Setting up the environment from scratch

1. Create three private Github (or any other VCS) repositories to store the secrets. Setup SSH keys in your GitHub account. To do so follow this [link](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).


2. Create the image
````shell
$ docker build -t gopass .
````

3. Get into the container overriding the default entrypoint and mounting the SSH keys into the container. Also, mount a volume to save the GPG keys
````shell
$ docker run --rm -it -v ~/.ssh:/ssh  -v $PWD/gpg:/gpg --entrypoint sh gopass
````

4. Add the SSH keys in order to clone the private repos inside your container
````shell
$ eval $(ssh-agent -s)
$ bash -c 'ssh-add /ssh/the-ssh-key'
$ Identity added: /ssh/the-ssh-key (myemail@mydomain.com)
````

5. List the available GPG keys

```shell
$ gpg -K

gpg: directory '/root/.gnupg' created
gpg: keybox '/root/.gnupg/pubring.kbx' created
gpg: /root/.gnupg/trustdb.gpg: trustdb created
````

6. Create the GPG public and private keys. Bear in mind that over this process a master password will be prompted. Picture one really hard to guess but really easy to remember for you. Include at least one number.
   
   **Note**: It is worth mentioning that it is possible to create as many GPG keys as needed. It is advisable and more secure to use one per repo

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

7. Check the public and private keys just created.

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

8.  Export the GPG keys (public & private) to a secure location
````shell
$ gpg --output /gpg/public.pgp --armor --export myemail@mydomain.com
$ gpg --output /gpg/private.pgp --armor --export-secret-key myemail@mydomain.com
````

9. Setup the gopass root local store. This store will wrap the other stores. Despite the fact the root store might be empty, this demo sets gopass up with one of the three repos already created. This action is conducted in order to leverage all the gopass features (autosync, validation of recipients) and incidentally in case a secret is created in the root it will not be orphan.

````shell
$ gopass setup

[init] Initializing a new password store ...
Please select a private key for encrypting secrets:
[0] gpg - 0x272228D475DEE27 - carlos valarezo <myemail@mydomain.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
Use carlos valarezo (myemail@mydomain.com) for password store git config? [Y/n/q]: y
[init] [local]  -> OK
[init] [local] Configuring your local store ...
[init] [local] Do you want to add a git remote? [y/N/q]: y
Please enter the git remote for your shared store []: git@github.com:carlosvalarezo/root-secrets.git
[init] [local] Do you want to automatically push any changes to the git remote (if any)? [Y/n/q]: y
[init] [local] Do you want to always confirm recipients when encrypting? [y/N/q]: y
[init] [local]  -> OK
````

10. Setup two different stores, one for personal secrets and another for work secrets.

**Note**: It is possible to create as many stores as needed.

````shell
$ gopass init --store my-company

[init] Initializing a new password store ...
[init] WARNING: Store is already initialized
Please select a private key for encrypting secrets:
[0] gpg - 0x72D911CE22A371F9 - carlos valarezo <myemail@mydomain.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
[init] Initializing git repository (gitcli) ...
Use carlos valarezo (myemail@mydomain.com) for password store git config? [Y/n/q]: y
[init] git initialized at /root/.local/share/gopass/stores/my-company
[init] git configured at /root/.local/share/gopass/stores/my-company
[init] Git initialized
[init] Password store /root/.local/share/gopass/stores/my-company initialized for:
[init]   0x72D911CE63A371F9 - carlos valarezo <myemail@mydomain.com>
````

11. Add the remote repository to ``my-company`` store

````shell
$ gopass git remote add --store my-company origin git@github.com:carlosvalarezo/my-company-secrets.git
````
12. Setup the ```personal``` store

````shell
$ gopass init --store personal

[init] Initializing a new password store ...
[init] WARNING: Store is already initialized
Please select a private key for encrypting secrets:
[0] gpg - 0x72D911CE63A2221F9 - carlos valarezo <myemail@mydomain.com>
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
14. Check gopass is correctly setup so far
````shell
$ gopass

gopass
├── my-company (/root/.local/share/gopass/stores/my-company)
└── personal (/root/.local/share/gopass/stores/personal)
````

15. Github repositories need to setup the strategy to reconcile divergent branches.
    To do so, please go to the directory of every single store:
```shell
$ cd /root/.local/share/gopass/stores/my-company
```

```shell
$ cd /root/.local/share/gopass/stores/personal
```
and execute ``git config pull.rebase false`` in both directories. Otherwise a warning might show up.

16. Add secrets to ```my-company``` store:

````shell
$ gopass generate -x my-company/abc/password
````

17. Add secrets to ```personal``` store:

````shell
$ gopass generate -x personal/abc/password
````

18. Sync up both (or more) stores. Remember to sync up periodically or after adding new secrets.

````shell
$ gopass sync
````

## Setting up the environment when the repository already exists

This scenario fits on changing the machine or on creating the same stores in a different machine.

### Steps

1. Run the docker container with two volumes mounted, one for the SSH keys and the other for the GPG keys.

```shell
$ docker run -it -v ~/.ssh:/ssh -v $PWD/gpg:/gpg --entrypoint sh gopass
```

4. Add the SSH keys in order to clone the private repos inside your container
````shell
$ eval $(ssh-agent -s)
$ bash -c 'ssh-add /ssh/the-ssh-key'
$ Identity added: /ssh/the-ssh-key (myemail@mydomain.com)
````

2.  Import the GPG keys (public & private)
````shell
$ gpg --import /gpg/public.pgp
$ gpg --import /gpg/private.pgp
````

3. Check if the GPG are already in the machine
```shell
$ gpg -K

/root/.gnupg/pubring.kbx
------------------------
sec   rsa4096 2020-01-08 [SC] [expires: 2022-01-07]
      A34A34F45A42621612575797AD14DBB154534AFD72
uid           [ unknown] carlos valarezo <myemail@mydomain.com>
ssb   rsa4096 2020-01-08 [E] [expires: 2021-05-07]

```

4. Trust the just imported GPG private key running the following command with uid of the previous command
````shell
$ gpg --edit-key A34A34F45A42621612575797AD14DBB154534AFD72

gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/A34A34F45A426216125
     created: 2020-01-25  expires: 2021-05-07  usage: SC  
     trust: unknown       validity: unknown
ssb  rsa4096/75797AD14DBB154534AFD72
     created: 2020-01-25  expires: 2021-05-07  usage: E   
[ unknown] (1). carlos valarezo <myemail@mydomain.com>

gpg> trust
sec  rsa4096/A34A34F45A426216125
     created: 2020-01-25  expires: 2022-01-07  usage: SC  
     trust: unknown       validity: unknown
ssb  rsa4096/75797AD14DBB154534AFD72
     created: 2020-01-25  expires: 2022-05-07  usage: E   
[ unknown] (1). carlos valarezo <myemail@mydomain.com>

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
                                                             
sec  rsa4096/A34A34F45A426216125
     created: 2020-01-25  expires: 2022-01-07  usage: SC  
     trust: unknown       validity: unknown
ssb  rsa4096/75797AD14DBB154534AFD72
     created: 2020-01-25  expires: 2022-05-07  usage: E     
[ unknown] (1). carlos valarezo <myemail@mydomain.com>
Please note that the shown key validity is not necessarily correct 
unless you restart the program.

gpg> quit

````

3. Check if the GPG are already in the machine with ultimate trust level
```shell
$ gpg -K

/root/.gnupg/pubring.kbx
------------------------
sec   rsa4096 2020-01-08 [SC] [expires: 2022-01-07]
      A34A34F45A42621612575797AD14DBB154534AFD72
uid           [ ultimate] carlos valarezo <myemail@mydomain.com>
ssb   rsa4096 2020-01-08 [E] [expires: 2021-05-07]

````

4. Setup the gopass root local store. 
````shell
$ gopass setup

[init] Initializing a new password store ...
Please select a private key for encrypting secrets:
[0] gpg - 0x2730354545553537 - carlos valarezo <myemail@mydomain.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
Use carlos valarezo (myemail@mydomain.com) for password store git config? [Y/n/q]: y
[init] [local]  -> OK
[init] [local] Configuring your local store ...
[init] [local] Do you want to add a git remote? [y/N/q]: y
Please enter the git remote for your shared store []: git@github.com:carlosvalarezo/root-secrets.git
[init] [local] Do you want to automatically push any changes to the git remote (if any)? [Y/n/q]: y
[init] [local] Do you want to always confirm recipients when encrypting? [y/N/q]: y
[init] [local]  -> OK
````

5. Clone the repository and setup a store

````shell
$ gopass clone https://github.com/carlosvalarezo/my-company-secrets.git my-company --sync gitcli
````

6. Check the secrets were pulled correctly

````shell
$ gopass list my-company
````

**NOTES:**

1. If at some point a backup is required, run the following command:
````shell
$ gpg --output backupkeys.pgp --armor --export-secret-keys --export-options export-backup myemail@mydomain.com
````

2. If there is an error on mounting the store the easiest solution is to delete the physical storage of the store:
````shell
$ rm -rf /root/.local/share/gopass/stores/my-company
````

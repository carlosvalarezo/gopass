# Gopass for personal and team usage

## Description

Gopass is a password manager to manage personal passwords, company passwords and share secrets among teams members.

This repository contains a dockerfile to run gopass. It summarizes gopass setup and the most used commands.

### What's inside?

To use gopass the dockerfile contains:

* **gpg** : used to create, import, export public and private keys
* **openssh-client**: to import ssh keys  
* **gopass**: tool to manage secrets

## Setting up the environment from scratch

* Create three private Github (or any other VCS) repositories to store the secrets. Setup SSH keys in your GitHub account. To do so follow this [link](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

* Create the image
````shell
$ docker build -t gopass .
````

* Get into the container overriding the default entrypoint and mounting the SSH keys into the container. Also, mount a volume to save the GPG keys
````shell
$ docker run --rm -it -v ~/.ssh:/ssh  -v $PWD/gpg:/gpg --entrypoint sh gopass
````

* Add the SSH keys in order to clone the private repos inside your container
````shell
$ eval $(ssh-agent -s)
$ bash -c 'ssh-add /ssh/the-ssh-key'
$ Identity added: /ssh/the-ssh-key (myemail@mydomain.com)
````

* List the available GPG keys

```shell
$ gpg -K

gpg: directory '/root/.gnupg' created
gpg: keybox '/root/.gnupg/pubring.kbx' created
gpg: /root/.gnupg/trustdb.gpg: trustdb created
````

* Create the GPG public and private keys. Bear in mind that over this process a master password will be prompted. Picture one really hard to guess but really easy to remember for you. Include at least one number. 
  **Note**: It is worth mentioning that it is possible to create as many GPG keys as needed. It is advisable and more secure to use one per repository

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
      6A25ACE84F43A97CF422E9596AA88882220518E
uid           [ultimate] carlos valarezo <myemail@mydomain.com>
ssb   rsa3072 2021-04-06 [E] [expires: 2026-04-05]
````

8.  Export the GPG keys (public & private) to a secure location
````shell
$ gpg --output /gpg/public.pgp --armor --export myemail@mydomain.com
$ gpg --output /gpg/private.pgp --armor --export-secret-key myemail@mydomain.com
````

9. Set up the gopass root local store. Choose ``Local store``. Despite the fact the root store might be empty, this demo sets gopass up with one of the three repos already created. This action is conducted in order to leverage all the gopass features (autosync, validation of recipients) and incidentally in case a secret is created in the root it will not be orphan.

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

4. Set up the gopass root local store. 

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

5. Clone the repository and set up a store

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


## Set up gopass for teams

### Set up the seed

1. Create an email account for the team, a GitHub account with the email just created, set up the GitHub account with an SSH key and two repositories (one for local store & one for shared store)

2. Set up a store in gopass. Choose ````Create a team````

````shell
$ gopass setup
[init] Creating a new team ...
[init] [local] Initializing your local store ...
Please select a private key for encrypting secrets:
[0] gpg - 0xD5B3FD499B241F69 - team member one <memberone@team.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
Use team member one (memberone@team.com) for password store git config? [Y/n/q]: n
Please enter a user name for password store git config []: github-seed-username
Please enter an email address for password store git config []: github-seed-username@domain.com
[init] [local]  -> OK
[init] [local] Configuring your local store ...
[init] [local] Do you want to add a git remote? [y/N/q]: y
[init] [local] Configuring the git remote ...
Please enter the git remote for your shared store []: git@github.com:team/root-secrets.git
[init] [local] Do you want to automatically push any changes to the git remote (if any)? [Y/n/q]: y
[init] [local] Do you want to always confirm recipients when encrypting? [y/N/q]: y
[init] [local]  -> OK
[init] Please enter the name of your team (may contain slashes) []: my-super-team
[init] [my-super-team] Initializing your shared store ...
Please select a private key for encrypting secrets:
[0] gpg - 0xD5B3FD499B241F69 - team member one <memberone@team.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
Use team member one (memberone@team.com) for password store git config? [Y/n/q]: n
Please enter a user name for password store git config []: github-seed-username
Please enter an email address for password store git config []: github-seed-username@domain.com
[init] [my-super-team]  -> OK
[init] [my-super-team] Configuring the git remote ...
Please enter the git remote for your shared store []: git@github.com:team/shared-secrets.git
[init] [my-super-team]  -> OK
[init] [my-super-team] Created Team 'my-super-team'

````

5. Check the setup is correct

````shell
$ gopass
gopass
└── shared-secrets (/root/.local/share/gopass/stores/shared-secrets)

````

## Team members

### Set up the GPG keys

Every member of the team should follow the following steps:

1. Create their own GPG keys:
````shell
$ gpg --full-generate-key
````

2.  Export the public GPG key and share it somehow to the other members of the team.
````shell
$ gpg --output /gpg/public.pgp --armor --export memberone@team.com
````

A sharing option is to publish the public key in the GPG directory https://pgp.mit.edu
In order to so, get the key ID and push the key.

````shell
$ gpg -K #to get the keyID

$ gpg --keyserver https://pgp.mit.edu --send-key 5EFEA92154C04E61C30312A55BCA65AA285CE293
````

Wait for about 5 or 10 minutes until the GPG gets published. Then go to https://pgp.mit.edu/ and in the textbox ``Search String`` enter the email address used to create the GPG key and if it appears the public GPG key is ready to be pulled. 

3. Import the public GPG of ALL the other team members.

````shell
$ gpg --import /gpg/public-member-one.pgp

$ gpg --import /gpg/public-member-two.pgp

$ gpg --import /gpg/public-member-n.pgp
````   

If the GPG is already published in the GPG public directory use the following command. Share the keyID with the team members.

````shell
$ gpg -K
/root/.gnupg/pubring.kbx
------------------------
sec   rsa3072 2021-04-13 [SC] [expires: 2026-04-12]
      5EFEA92154C04E61C30312A55BCA65AA285CE293 #share this number if the GPG is published in the GPG public directory
uid           [ultimate] team member two <membertwo@team.com>
ssb   rsa3072 2021-04-13 [E] [expires: 2026-04-12]

````

```shell
$ gpg --keyserver pgp.mit.edu --recv-key 5EFEA92154C04E61C30312A55BCA65AA285CE293

gpg: key 5BCA65AA285CE293: public key "team member one <memberone@team.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```


6. Trust the just imported GPG keys from the team members

````shell
$ gpg --edit-key 5EFEA92154C04E61C30312A55BCA65AA285CE293
gpg> trust
gpg> 5
gpg> quit
````

7. Add the other team members

````shell
$ gopass recipients add memberone@team.com
Do you want to add '0x5BCA65AA285CE293 - team member one <memberone@team.com>' as a recipient to the store 'my-super-team'? [y/N/q]: y
Reencrypting existing secrets. This may take some time ...
Starting reencrypt

Added 1 recipients
You need to run 'gopass sync' to push these changes

````

8. Sync up the repository

```shell
$ gopass sync
```

9. Check the recipients

````shell
$ gopass recipients
Hint: run 'gopass sync' to import any missing public keys
gopass
├── my-super-team (/root/.local/share/gopass/stores/my-super-team)
│   ├── 0x5BCA65AA285CE293 - team member one <memberone@team.com>
│   └── 0xD5B3FD499B241F69 - team member two <membertwo@team.com>
└── 0xD5B3FD499B241F69 - team member two <membertwo@team.com>

````

10. Create a secret

````shell
$ gopass generate my-super-team/my-secret-two/my-password
How long should the password be? [24]: 
gopass: Encrypting /my-secret-two/my-password for these recipients:
- 5EFEA92154C04E61C30312A55BCA65AA285CE293 - 0x5BCA65AA285CE293 - team member one <memberone@team.com>
- 8C3BA44EF055B810D33EDDD6D5B3FD499B241F69 - 0xD5B3FD499B241F69 - team member two <membertwo@team.com>

Do you want to continue? [Y/n/q]: y
Pushed changes to git remote

````

### Gopass setup (the team members)

1. Set up a store in gopass. Choose ````Join an existing team````

**Note** Despite the fact the current step is joining the team, two repositories will be requested on setting up the store. Therefore, have a personal GitHub repository, and the shared GitHub repository urls.
**Note 2** In case gopass is already setup in the machine, the procedure is to delete the current setup and start again with the local and the shared repositories

````shell

$ gopass setup

[init] Joining existing team ...
[init] [local] Initializing your local store ...
Please select a private key for encrypting secrets:
[0] gpg - 0x5BCA65AA285CE293 - team member one <memberone@team.com>
Please enter the number of a key (0-0, [q]uit) [0]: 0
Use team member one (memberone@team.com) for password store git config? [Y/n/q]: n
Please enter a user name for password store git config []: your-hithub-username 
Please enter an email address for password store git config []: your-hithub-username@domain.com
[init] [local]  -> OK
[init] [local] Configuring your local store ...
[init] [local] Do you want to add a git remote? [y/N/q]: y
[init] [local] Configuring the git remote ...
Please enter the git remote for your shared store []: git@github.com:any-personal-github/secrets-repo.git
[init] [local] Do you want to always confirm recipients when encrypting? [y/N/q]: y
[init] [local]  -> OK
[init] Please enter the name of your team (may contain slashes) []: my-super-team
[init] [my-super-team]Configuring git remote ...
[init] [my-super-team]Please enter the git remote for your shared store []: git@github.com:team/shared-secrets.git
[init] [my-super-team]Cloning from the git remote ...
Use team member one (memberone@team.com) for password store git config? [Y/n/q]: y
[init] [my-super-team] -> OK
[init] [my-super-team]Joined Team 'my-super-team'
[init] [my-super-team]Note: You still need to request access to decrypt any secret!
````

Then, sync up the changes to the team repo

````shell
$ gopass sync
````

````shell
$ gopass recipients
Hint: run 'gopass sync' to import any missing public keys
gopass
├── my-super-team (/root/.local/share/gopass/stores/my-super-team)
│   └── 0xD5B3FD499B241F69 - team member one <memberone@team.com>
└── 0xD5B3FD499B241F69 - team member one <memberone@team.com>
````

7. Add the other team members

````shell
$ gopass recipients add membertwo@team.com
Do you want to add '0x5BCA65AA285CE293 - team member two <membertwo@team.com>' as a recipient to the store 'my-super-team'? [y/N/q]: y
Reencrypting existing secrets. This may take some time ...
Starting reencrypt

Added 1 recipients
You need to run 'gopass sync' to push these changes

````


*Q*: Why do I have twice the same information related to my GPG?
*A*: One is for your local store, and the other is for the shared store.
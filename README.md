# Donjon

Donjon is a secure, multi-user store for key-value pairs.

Skip to: [Purpose](#purpose) | [Concepts](#concepts) | [Setting
up](#installation) | [Usage](#usage) | [Storing QR
codes](#storing-qr-codes-in-donjon)

![Version](https://badge.fury.io/rb/donjon.svg)
![Build status](https://travis-ci.org/mezis/donjon.svg?branch=master)


## Purpose

We built Donjon to share credentials in a (small) devops team, for services where
single user accounts don't make sense, e.g.:

- root passwords for databases and servers
- root credentials for hosting accounts
- accounts for web services that don't do multi-user/multi-admin
- Two-factor tokens for single-user web services.

Donjon uses standards for encryption: 2048-bit asymmetric RSA encryption used to
prime symmetric 256-bit AES CBC encryption with random padding.
In other words, while the NSA will probably be able to read your data should it
get its paws on it, it's unlikely Joe Hacker will.

[Online tools](https://lastpass.com) exist that serve the same purpose as Donjon, but simply
put: they're generally closed source and host the data somewhere we don't
control. We think the inconvenience of not having a cute toolbar icon for
passwords is trumped by better security.

## Concepts

A **vault** is a directory managed by Donjon. It contains encrypted key-value
pairs, and public keys for all allowed users. Each key-value pair lives in its
own directory. The name of the directory is an obfuscated (hashed) version of
the key, but it's not encrypted. The directory contains one file per user, each
containing the key-value pair encrypted with their public key.

**Syncing** the vault between users is left as an exercice to users or
integrators :)
One option is to use a shared drive (e.g. using a cloud server and
[SSHFS](http://en.wikipedia.org/wiki/SSHFS)). We prefer to sync the vault
directory using [Bittorrent Sync](http://www.bittorrent.com/sync) rather than
leave a copy of it with third parties. Another option is to use Git as a
distribution mechanism.


## Installation

The setup is slightly different different for new vaults (first subsection below)
and connecting to an existing vault (second subsection).

This section assumes the vault is synced between users using Bittorrent Sync.


### Creating a new vault

Install Donjon:
    
    $ gem install donjon

Run the Donjon configuration:

    $ dj init

Note that while you can re-use an existing private key for Donjon, it must be
encrypted and be a 2048-bit RSA key.

Add, then read a first key-value pair to confirm encryption is working:

    $ dj config:set TEST=foobar
    $ dj config:get TEST
    TEST: foobar

Download, install, and run [Bittorrent Sync](http://www.bittorrent.com/sync/downloads).

Add the vault directory you configured during `dj init` to be synced by
Bittorrent Sync.


### Connecting to an existing vault

Create an (empty) directory where you want the vault to be synced. Tyhis can
typically be `~/.donjon`.

Download and install [Bittorrent Sync](http://www.bittorrent.com/sync/downloads).

Ask a peer already using the vault you're interested in to provide you a "one
time secret" for the shared vault directory. Add this to Bittorrent Sync, and
wait for syncing to complete. Note that one-time keys can only be used by one
user!

Install Donjon:

    $ gem install donjon

Configure Donjon; when prompted for a vault path, enter the path to the relevant
synced directory:

    $ dj init
    
At this point your public key has been added to the vault, but you can't access
any data as it hasn't been encrypted for you. Obtain your public key:

    $ dj user:key

and send it over a reasonably secure medium to your peer. They will then run

    $ dj user:add <your-username>

to encrypt all key-value pairs for your user.

Test that you can read a particular key, and you're all set!


## Usage

Once you've set up a vault (you can use `vault:init` to connect to an existing
vault, e.g. on Dropbox).

```
Commands:
  dj config:get KEY...         # Decrypts the value for KEY from the vault
  dj config:set KEY=VALUE ...  # Encrypts KEY and VALUE in the vault
  dj config:del KEY            # Removes a key-value pair
  dj config:fset KEY FILE      # Encrypts KEY and the contents of FILE in the vault
  dj config:mget [REGEXP]      # Decrypts multiple keys (all readable by default)
  dj help [COMMAND]            # Describe available commands or one specific command
  dj init                      # Creates a new vault, or connects to an existing vault.
  dj user:add NAME [PATH]      # Adds user and their public key to the vault. Reads from standard input if no path is given.
  dj user:key                  # Prints your public key
```


## Storing QR codes in Donjon

Some service offer two factor authentication, which is a good thing.
Unfortunately some of those are not multi-user, which means the token for two
factor authentication also needs to be shared.

This token is usually shared as a QR code for convenience, to be used with
Google Authenticator or Authy.

You can store it in Donjon as follows:

1. Get the QR code from the service. A screenshot is fine.

2. Install [zbar](http://zbar.sourceforge.net/) (to scan the code) and
   [qrencode](http://fukuchi.org/works/qrencode/) (to generate a new, compact
   code)

3. Extract a new QR code:

     ```
     $ zbarimg --raw -q <file>.png | \
     tr -d '\n' | \
     qrencode -m 2 -d 1 -t ASCII | \
     sed -e "s/ /ESC[7m ESC[0m/g;s/#/ /g" | \
     tr 'ESC' '\033' | \
     tee /tmp/qr
     ```

     (this should output the QR code on your terminal)

4. Store the QR code in Donjon:

    ```
    $ dj config:fset mykey /tmp/qr
    ```

5. Test the code has been properly stored:

    ```
    $ dj config:get mykey
    ```


## Contributing

1. Fork it ( http://github.com/mezis/donjon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

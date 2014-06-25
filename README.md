# Donjon

TODO: Write a gem description

## Installation

Install it as you would any gem:

    $ gem install donjon

Then run the interactive setup:

    $ dj vault:init


## Usage

Once you've set up a vault (you can use `vault:init` to connect to an existing
vault, e.g. on Dropbox).

```
Commands:
  dj config:get KEY...         # Decrypts the value for KEY from the vault
  dj config:mget [REGEXP]      # Decrypts multiple keys (all readable by default)
  dj config:set KEY=VALUE ...  # Encrypts KEY and VALUE in the vault
  dj help [COMMAND]            # Describe available commands or one specific command
  dj init                      # Creates a new vault, or connects to an existing vault.
  dj user:add NAME [PATH]      # Adds user and their public key to the vault. Reads from standard input if no path is given.
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/donjon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

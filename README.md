# pass-extension-totp

A [pass](https://www.passwordstore.org/) extension for managing
time-based one-time-password (TOTP) tokens. Supports generic TOTP
algorithm, for services such as GitHub, as well as Steam's custom implementation.
Requires `openssl` to be installed.

## Usage

```
    pass totp [--clip,-c] pass-name
        Generate an TOTP code and optionally put it on the clipboard.
        If put on the clipboard, it will be cleared in 45 seconds.
```
More information may be found in the `pass-extension-totp(1)` man page.

## Examples

Generate a generic TOTP code:

```
$ pass totp github/username
```

Generate a Steam TOTP code:

```
$ pass totp steam/username
```

## Installation

### From git

```
git clone https://github.com/r-maerz/pass-extension-totp
cd pass-extension-totp
sudo make install
```

or, to install in the user dir (following the standard XDG base directory paths):

```
$ echo $XDG_DATA_HOME
/home/$USER/.local/share

$ export PASSWORD_STORE_ENABLE_EXTENSIONS=true
$ export PASSWORD_STORE_EXTENSIONS_DIR=$XDG_DATA_HOME/password-store/.extensions

$ PREFIX=$XDG_DATA_HOME \
    LIBDIR=$PREFIX \
    make install
```

## Requirements

- `pass` 1.7.0 or later for extension support
- `openssl` for generating 2FA codes

### pass-file layout

For this extension to work, you have to manually add a line to your relevant pass-files.
To do so, run:

```
$ pass edit <your pass-file>
```

Add line :

```
totp_secret: AAAAAAAAAAAAAAAA
```

Where `AAAAAAAAAAAAAAAA` is a base32-encoded string. Please only add the secret, not
an entire TOTP URI.

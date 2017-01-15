# cvetool

This is the start of a simple tool (in Lua) to download and manage CVE and related data for [Libertine Linux](https://github.com/libertine-linux/libertine).

The license is MIT.


## Usage

cvetool is designed to work entirely from source control without the need for installation. The easiest way to get it onto your machine, assuming git and a POSIX shell, is:-

```bash
git clone https://github.com/libertine-linux/cvetool.git
cd cvetool
git submodule update --init

# We do this instead of git submodule update --init --recursive because of the slow to download (and unneeded) submodules of `ljsyscall`
cd modules/halimede/middleclass
git submodule update --init
cd -

# If you now list the contents of this folder, you'll have a `cvetool` symlink.
# Verify everything works by trying help
./cvetool --help
```

### Overview

cvetool is a command line tool that uses a 'command' in the same way as git does as the first argument. To list all the available commands, do:-

```bash
./cvetool --help
```

Each command also has more detailed help. For instance, to find out about the `download-cpe` command, do:-

```bash
./cvetool --```

Rather than go into the commands themselves, we'll introduce them with some typical usage scenarios.

### Typical Usage Scenarios

#### Find an up-to-date list of CPE identifiers for a program
Let's say we want to know which CPE identifiers are used for bash. We can do:-

```bash
./cvetool download-cpe | ./cvetool list-cpe | awk 'BEGIN { FS="\t"; OFS="\t"} $1 ~/:bash:/ {print $1,$2,$3}'
```

The output has three columns - column one is the CPE, column two is its description, and column three is `true` if deprecated (and `false` if not).

#### Daily cron job to get latest data

Make a directory, such as `mkdir -m 0700 -p ~/.cvetool/downloads`. Don't use `/tmp` or `mktemp`; the downloaded files can be extremely large indeed (100s of Mb). For a system-wide choice, consider something like `/var/cache/cvetool`.

Run `crontab -e` and add these two lines:-

```bash
# Replace `/home/my-user-id` with whatever value is in $HOME, eg echo "$HOME"
00 01 * * * /path/to/cvetool/git/folder/cvetool download-cpe --output /home/my-user-id/.cvetool/downloads
00 01 * * * /path/to/cvetool/git/folder/cvetool download-cve --output /home/my-user-id/.cvetool/downloads
```

A small caveat: The `--output` option will interpret an empty path, or a path of just `-`, as meaning standard out.

#### Get CVE data for just one particular year
Let's say you want to just get CVE data for 2016 and display it on standard out. You could run:-

```bash
./cvetool download-cve --url https://cve.mitre.org/data/downloads/allitems-cvrf-year-2017.xml.gz
```

## Dependencies

cvetool requires minimal dependencies. To work effectively, it needs installed:-

* LuaJit (ideally 2.0.4)\*
* A _dynamic_ (`.so`) version of libc (eg `libz.so`)†
* A _dynamic_ (`.so`) version of zlib (eg `libz.so`)‡
* A _dynamic_ (`.so`) version of curl (eg `libcurl.so`)‡
* A POSIX shell†
* The `realpath` (preferred) or `readlink` coreutils (installed as part of BusyBox, GNU Coreutils, Mac OS X userland, etc)


\* It will work with Lua 5.1, but [luaffi](https://github.com/jmckaskill/luaffi) will need to be preloaded (if embedding) or available in the default module path
† It should work on Windows but someone will need to code an equivalent of `wrapper` as a batch file, PowerShell script or the like and modify the code slightly in `halimede.io.FileStream:fileDescriptor()` to work on Windows.
‡ These are very common; zlib is almost certainly already on your system and libcurl is very likely to be (in the latter case, just install curl if it isn't). A precompiled version of zlib libraries can be found in `modules/zlib/bin/*` (the linux version only works with glibc). Likewise a precompiled version of libcurl can be found in `module/libcurl/bin/*`. You'll need to modify your `LD_LIBRARY_PATH` (`DYLD_FALLBACK_LIBRARY_PATH` if using Mac OS X) environment variable to use these. Using these precompiled libraries is not recomended as they are compiled by a third party outside of our control and are unlikely to be up-to-date or have appropriate security hardening for your platform.

## cvetool
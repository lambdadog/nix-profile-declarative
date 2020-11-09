# nix-profile-declarative

A tool for managing your Nix user profile declaratively. Normally
one's Nix profile is managed with tools like `nix-env`, which is
antithetical to the kind of beliefs which lead one to using tools like
Nix and NixOS in the first place.

Instead, `nix-profile-declarative` aims to have you manage your
profile similar to the way you configure NixOS -- by editing the
`~/.nix/profile.nix` file.

## Why not Home Manager?

If you're familiar with the Nix ecosystem, you may be wondering why
this tool exists in parallel with [Home
Manager](https://github.com/nix-community/home-manager), a tool that
does much the same thing.

This is due to one core difference in ethos between
`nix-profile-declarative` and Home Manager: Modifying the `$HOME`
folder.

Home Manager configures your applications in a very traditional way,
by modifying the many files sitting in your home directory that these
applications read for their configuration. This gives Home Manager a
lot of freedom, but in my opinion is both messy and a *losing game*,
given that end-user applications are often prone to dropping their own
files in their configuration directory then turning around and reading
them.

`nix-profile-declarative` functions much like NixOS, in that when it
wants to configure an application, instead of doing it the messy,
stateful way, it chooses to create a wrapper for the application and
pass command-line flags to it, pointing it to configuration files in
the Nix Store. This means that the only files
`nix-profile-declarative` will touch are those in the `~/.nix-profile`
directory, which is the same place that `nix-env` already manages.

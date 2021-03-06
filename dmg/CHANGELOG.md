dmg Cookbook CHANGELOG
======================
This file is used to list changes made in each version of the dmg ookbook.


v2.0.4
------
### Bug
- **[COOK-3331](https://tickets.opscode.com/browse/COOK-3331)** - Fix an issue where `dmg_package` with no source raises an exception


v2.0.2
------
### Bug
- **[COOK-3578](https://tickets.opscode.com/browse/COOK-3578)** - Support `package_id`s with spaces
- **[COOK-3302](https://tickets.opscode.com/browse/COOK-3302)** - Fix an issue where `hdiutil detach` fails due to `cfprefsd` running in the background

v2.0.0
------
### Bug
- **[COOK-3389](https://tickets.opscode.com/browse/COOK-3389)** - Use `rsync` instead of `cp` (potentially a breaking change on some systems)

v1.1.0
------
- [COOK-1847] - accept owner parameter for installing packages

v1.0.0
------
- [COOK-852] - Support "pkg" in addition to "mpkg" package types

v0.7.0
------
- [COOK-854] - use `cp -R` instead of `cp -r`
- [COOK-855] - specify a file or directory to check for prior install

v0.6.0
------
- option to install software that is an .mpkg inside a .dmg
- ignore failure on chmod in case mode is already set, or is root owned

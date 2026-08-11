# Change Log

## 0.2.2

* Added a preflight check that validates the runtime environment before invoking
 `ffmpeg`.  The preflight check halts on fatal errors such as a missing `ffmpeg`
 binary, an unreadable input file, a missing software decoder for the input
 codec, or insufficient disk space.
* Implemented an automatic software-fallback when hardware acceleration
 initialization fails.  The tool will warn the user, retry the operation using
 software decoding (which is slower), and only abort if a required software
 decoder or resource is missing.
* Added a `--no-hwaccel` (`-H`) option to force software decoding and skip
  hardware acceleration.

## 0.2.1

* Added `spec.platform` to `media_trim.gemspec` because `RubyGems.org` now requires it
* Various Ruby syntax issues corrected


## 0.2.0

* Packaged as a gem.


## 0.1.0

* Initial release as a script.

# UniForm

UniForm orchestrates source code formating,
with an emphasis on serving multiple, diverse software projects with a single command.

The only language currently supported is JavaScript.
C++ support is in the works.

Currently, UniForm can only format git-controlled sources.

### Setup:

Depends on: [nodejs](http://nodejs.org), [attractifier](https://github.com/Mark-Simulacrum/attractifier).

For Ubuntu distributions, `nodejs-legacy` provides `node`.

Follow the steps [here](https://github.com/Mark-Simulacrum/attractifier/blob/master/README.md#installation)
to install attractifier.

Get uniform (it does not support global installation yet) and
symlink attractifier's executable into uniform directory:
```
git clone git@github.com:measurement-factory/uniform.git
cd uniform/
ln -s `which attractifier` javascript-formatter
```
The uniform.sh script runs `javascript-formatter` in its directory.

### Usage:

In most cases, you can just run uniform.sh without options
from a git-controlled directory, but you can also format specific files
(or subdirectories):
```
uniform.sh [--force] [--] [<file>...]
```

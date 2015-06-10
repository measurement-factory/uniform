# uniform

Uniform is designed to format source code.
The only language currently supported is JavaScript.
C++ support is in the works.

### Setup:

Depends on: [nodejs](http://nodejs.org), [pretty-generator](https://github.com/Mark-Simulacrum/pretty-generator).

For Ubuntu distributions, `nodejs-legacy` provides `node`.

Get pretty-generator (it does not support global installation yet):
```
git clone git@github.com:Mark-Simulacrum/pretty-generator.git
cd pretty-generator
npm install
npm run-script build
```

Get uniform (it does not support global installation yet) and
symlink pretty-generator's executable into uniform directory.
The uniform.sh script runs `javascript-formatter` in its directory.
```
git clone git@github.com:measurement-factory/uniform.git
cd uniform/
ln -s pretty-generator/lib/index.js javascript-formatter
```

### Usage:

In most cases, you can just run uniform.sh without options
from a git-controlled directory, but you can also format specific files
(or subdirectories):
```
uniform.sh [--force] [--] [<file>...]
```

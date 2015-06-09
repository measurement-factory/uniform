# uniform

Uniform is designed to format source code.
The only language currently supported is JavaScript. 

### Setup:

Depends on: [nodejs](http://nodejs.org), [pretty-generator](https://github.com/Mark-Simulacrum/pretty-generator).

For Ubuntu distributions, `nodejs-legacy` provides `node`.

Install pretty-generator:
```
git clone git@github.com:Mark-Simulacrum/pretty-generator.git
cd pretty-generator
npm install
npm run-script build
```

Install uniform:
```
git clone git@github.com:measurement-factory/uniform.git
```

Symlink pretty-generator's executable into uniform:
```
ln -s pretty-generator/lib/index.js uniform/pretty-generator.js
```

### Usage:
```
uniform.sh [--force] [--] [<file>...]
```


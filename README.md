# sphere-order-xml-import

[![Build Status](https://secure.travis-ci.org/smueller/sphere-order-xml-import.png?branch=master)](http://travis-ci.org/smueller/sphere-order-xml-import) [![Coverage Status](https://coveralls.io/repos/smueller/sphere-order-xml-import/badge.png)](https://coveralls.io/r/smueller/sphere-order-xml-import) [![Dependency Status](https://david-dm.org/smueller/sphere-order-xml-import.png?theme=shields.io)](https://david-dm.org/smueller/sphere-order-xml-import) [![devDependency Status](https://david-dm.org/smueller/sphere-order-xml-import/dev-status.png?theme=shields.io)](https://david-dm.org/smueller/sphere-order-xml-import#info=devDependencies)


Update existing order status using XML files as source.

## Getting Started
Install the module with: `npm install sphere-order-xml-import`


## Documentation
_(Coming soon)_

## Tests
Tests are written using [jasmine](http://pivotal.github.io/jasmine/) (Behavior-Driven Development framework for testing javascript code). Thanks to [jasmine-node](https://github.com/mhevery/jasmine-node), this test framework is also available for Node.js.

To run tests, simple execute the *test* task using `grunt`.

```bash
$ grunt test
```

## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).
More info [here](CONTRIBUTING.md)

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```

## Styleguide
We <3 CoffeeScript here at commercetools! So please have a look at this referenced [coffeescript styleguide](https://github.com/polarmobile/coffeescript-style-guide) when doing changes to the code.

## License
Copyright (c) 2014 Sven Mueller
Licensed under the MIT license.

![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Order Status Import

[![NPM](https://nodei.co/npm/sphere-orderstatus-xml-import.png?downloads=true)](https://www.npmjs.org/package/sphere-orderstatus-xml-import)

[![Build Status](https://secure.travis-ci.org/sphereio/sphere-orderstatus-xml-import.png?branch=master)](http://travis-ci.org/sphereio/sphere-orderstatus-xml-import) [![NPM version](https://badge.fury.io/js/sphere-orderstatus-xml-import.png)](http://badge.fury.io/js/sphere-orderstatus-xml-import) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-orderstatus-xml-import/badge.png)](https://coveralls.io/r/sphereio/sphere-orderstatus-xml-import) [![Dependency Status](https://david-dm.org/sphereio/sphere-orderstatus-xml-import.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-orderstatus-xml-import) [![devDependency Status](https://david-dm.org/sphereio/sphere-orderstatus-xml-import/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-orderstatus-xml-import#info=devDependencies)

Importing order status information from XML files, with SFTP support.

## Getting started

```bash
$ npm install -g sphere-orderstatus-xml-import

# output help screen
$ orderstatus-xml-import
```

### SFTP
By default you need to specify the path to a local file in order to read the import information, via the `--file` option.

When using SFTP, you should not use the `--file` option, instead you need to provide at least the required `--sftp*` options:
- `--sftpCredentials` (or `--sftpHost`, `--sftpUsername`, `--sftpPassword`)
- `--sftpSource`
- `--sftpTarget`

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

## License
Copyright (c) 2014 SPHERE.IO
Licensed under the [MIT license](LICENSE-MIT).

# puremagic

A pure lua module that detects the mime type of common image file based on their contents, only PNG/GIF/WEBP/JPEG supported.

Tested on Lua 5.1 and Luajit 2.0.


## Version

The current version is: `1.0.1`


## Usage

Basic usage:

```lua
local puremagic = require('puremagic')
local mimetype = puremagic.via_path('/path/to/file')
```

When dealing with temp files, you may want to pass the original filename in case the extension is needed:

```lua
local puremagic = require('puremagic')
local mimetype = puremagic.via_path('/var/tmp/xyz', 'test.xlsx')
```

If you have the contents of the file in memory, you can provide those plus the filename:

```lua
local content = '#!/bin/bash\n'
local puremagic = require('puremagic')
local mimetype = puremagic.via_content(content, 'test.sh')
```


## Supported Mime Types

The following mime types are detected:

### Images

File type                     | Mime type
------------------------------|-------------------------------------------------
GIF                           | image/gif
JPEG                          | image/jpeg
PNG                           | image/png
webp                          | image/webp


## Running Tests

```bash
lua tests.lua
```

or

```bash
luajit tests.lua
```

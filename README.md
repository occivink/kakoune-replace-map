# kakoune-replace-map

[kakoune](http://kakoune.org) plugin to replace selection contents using key-value lookups.

## Setup

Add `replace-map.kak` to your autoload dir: `~/.config/kak/autoload/`, or source it manually.

## Usage

The plugin adds a single command:
```
replace-map [<switches>]
```

By default it replaces the current selections with new values based on the content of the 'dquote' register. The register is treated as if it were a map (or associate array) where the keys and values are interleaved. The current selections are treated as keys, and replaced by their corresponding values.

See the docstring of the command for a more detailed description of all the switches.

### Example

Given a buffer with a structure like this one:
```
ipsum -> foo
amet -> bar
elit -> baz
```
We can select all words and copy them to act as a replacement map, using `exec '%<a-s>HS -> <ret>y'`.

Then if we have another buffer, where we want to replace the words according to the structure defined above, like this:
```
Lorem ipsum dolor sit amet, consectetur adipiscing elit
```
We can simply select all words (using `exec 's\w+<ret>'`), and then perform the replacement using `replace-map --not-found-keep`, which should produce the following:
```
Lorem foo dolor sit bar, consectetur adipiscing baz
```

The reverse transformation could be performed using `replace-map --map-order vkvk --not-found-keep`.

## Testing

The `test.kak_` file contains tests for the plugin. To execute these tests, simply run `kak -n -e 'source test.kak_ ; quit'`: if the kakoune instance stays open, the tests have somehow failed and the current state can be inspected.

## License

Unlicense

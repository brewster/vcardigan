# vCardigan

vCardigan is a ruby library for building and parsing vCards that supports both
v3.0 and v4.0.

## Installation

``` bash
gem install vcardigan
```

## Usage
### Creating a vCard

``` ruby
VCardigan.create(:version => "3.0")
```

### Rendering a vCard

``` ruby
vcard.to_s
```

### Adding properties to a vCard

You can add properties by passing a block to the `add` method on an existing
vCard or by passing a block at the time of creation, like so:

``` ruby
VCardigan.create do |vcard|
  # Add properties here
end
```

When adding a property, you can either do so via a block or simply by passing
the associated values and/or parameters as arguments.

##### Block format

The block format is useful for properties with many component values. Most of
these compound properties have helper methods to aid in its creation (a list of
associated helpers can be seen below). Any additional fields not specified in
this list are assumed to be property parameters. For example:

``` ruby
vcard.add do |vcard|
  vcard.name do |name|
    vcard.first = "Joe"
    vcard.last = "Strummer"
    vcard.language = "en"
  end
end
```
```
N;LANGUAGE=en:Strummer;Joe;;;
```

##### Argument format

Alternatively, you could create the same property by passing the compound
values as arguments. *Note: Arguments must be passed in the order specified by
the vCard specification.* Property parameters are added by passing a hash with
the parameter/value pair. For example:

``` ruby
vcard.add do |vcard|
  vcard.name "Strummer", "Joe", :language => "en"
end
```
```
N;LANGUAGE=en:Strummer;Joe;;;
```

##### Groups

##### Multiple values

Commas in any value will be escaped as defined in the
[specification](http://tools.ietf.org/html/rfc6350#section-3.4) unless you
pass the values as an array. For example, multiple additional names can be
accomplished with:

``` ruby
vcard.add do |vcard|
  vcard.name "Strummer", "Joe", ["Joseph", "Woody"]
end
```
```
N:Strummer;Joe;Joseph,Woody;;
```

### Parsing a vCard

Using the following output:

```
BEGIN:VCARD
N:Strummer;Joe;;;
FN:Joe Strummer
END:VCARD
```
We could parse the name, like so:

``` ruby
vcard = VCardigan.parse(vcard)
vcard.fullname
```
```
Joe Strummer
```

### Editing properties of a vCard

You can edit properties using the `edit` method on an existing vCardigan
instance. Using the above example, you could change the name like this:

``` ruby
vcard.edit do |vcard|
  vcard.name :first => "Joseph"
end
```
```
N:Strummer;Bro;;;
```

### vCard Versions

vCardigan supports vCard versions `3.0` and `4.0`. Support for `2.1` is not
currently expected. You may pass the version number as an argument to
`VCardigan.create`; the default is `4.0`. You may also change the version at
any time:

``` ruby
vcard.version '4.0'
```

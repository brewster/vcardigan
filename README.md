# vCardigan

vCardigan is a ruby library for building and parsing vCards that supports both
v3.0 and v4.0.

**Note: This library is no longer called vCardMate!**

## Installation

``` bash
gem install vcardigan
```

## Usage
### Creating a vCard

``` ruby
vcard = VCardigan.create(:version => '3.0')
```

### vCard Versions

vCardigan supports vCard versions `3.0` and `4.0`. Support for `2.1` is not
currently expected. You may pass the version number as an argument to
`VCardigan.create`; the default is `4.0`. You may also change the version at
any time:

``` ruby
vcard.version '4.0'
```

### Rendering a vCard

``` ruby
vcard.to_s
```

### Adding properties to a vCard

``` ruby
vcard = VCardigan.create
vcard.name 'Strummer', 'Joe'
vcard.fullname 'Joe Strummer'
vcard.photo 'http://strummer.com/joe.jpg', :type => 'uri'
vcard.email 'joe@strummer.com', :type => ['work', 'internet'], :preferred => 1
vcard[:item1].url 'http://strummer.com'
vcard[:item1].label 'Other'
puts vcard
```
The above would output:
```
BEGIN:VCARD
VERSION:4.0
N:Strummer;Joe;;;
FN:Joe Strummer
PHOTO;TYPE=uri:http://strummer.com/joe.jpg
EMAIL;TYPE=work,internet;PREF=1:joe@strummer.com
item1.URL:http://strummer.com
item1.LABEL:Other
END:VCARD
```

### Parsing a vCard

Using the above output as `data`, we could parse it as such:
``` ruby
vcard = VCardigan.parse(data)

vcard.n.values # ['strummer', 'joe', '', '', '']
vcard.photo.params # { 'type' => 'uri' }
vcard.email.params # { 'type' => ['work', 'internet'], 'preferred' => '1' }
vcard[:item1].url.value # http://strummer.com
```

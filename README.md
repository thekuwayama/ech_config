# ech_config

[![Gem Version](https://badge.fury.io/rb/ech_config.svg)](https://badge.fury.io/rb/ech_config)
[![CI](https://github.com/thekuwayama/ech_config/workflows/CI/badge.svg)](https://github.com/thekuwayama/ech_config/actions?workflow=CI)

`ech_config` is Ruby implementation of [Encrypted ClientHello Configuration](https://datatracker.ietf.org/doc/html/rfc9849.html).

`ech_config` supports `0xfe0b` ~ `0xfe0d` ECHConfig.version.


## Installation

The gem is available at [rubygems.org](https://rubygems.org/gems/ech_config). You can install with:

```sh-session
$ gem install ech_config
```


## Usage

```ruby
require 'ech_config'

echconfigs = ECHConfig.decode_vectors(octet)
```

Clients MUST ignore an ECHConfig that carries an unsupported mandatory ECHConfig extension ([RFC 9849 4.2](https://datatracker.ietf.org/doc/html/rfc9849.html#section-4.2-2)). This gem decodes every extension it does not know as `UnknownExtension`, so:

```ruby
echconfigs.reject do |echconfig|
  echconfig.echconfig_contents.extensions.values.any? do |ex|
    ex.mandatory? &&
      ex.is_a?(ECHConfig::ECHConfigContents::Extensions::UnknownExtension)
  end
end
```

`ech_authinfo` and `ech_auth` ([draft-sullivan-tls-signed-ech-updates-02](https://datatracker.ietf.org/doc/html/draft-sullivan-tls-signed-ech-updates-02#section-5.1)) are decoded as `ECHAuthInfo` / `ECHAuth`. `ECHConfig#to_be_signed` returns the bytes an `ech_auth` signature is computed over; validating `not_after`, `trusted_keys` and the signature itself is left to the caller.

```ruby
ech_auth = echconfig
           .echconfig_contents
           .extensions[ECHConfig::ECHConfigContents::Extensions::ECHAuth::TYPE]
OpenSSL::PKey.read(ech_auth.spki)
             .verify(nil, ech_auth.signature, echconfig.to_be_signed)
```

Both codepoints are placeholders until IANA assigns them, so they are NOT interoperable yet.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

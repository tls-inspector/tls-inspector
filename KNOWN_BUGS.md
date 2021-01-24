# Known Bugs

The following is an unordered list of known issues with TLS Inspector that cannot or will not
be fixed.

If you believe you have a solution to any of these issues, please let us know!

### Can't Inspect IDN / "Punycode" Domain Names

Issue: https://github.com/tls-inspector/tls-inspector/issues/43

International Domain Names or "IDN", sometimes called "Punycode" domain names is an encoding
scheme that enables full UTF-8 domain names despite DNS being ASCII.

TLS Inspector does not support these domains in UTF-8 form, but does support the encoded name.

For example:

Does not work: `🔒🔒🔒.scotthelme.co.uk`
Does work: `xn--lv8haa.scotthelme.co.uk`

### "Show Certificate" Share Sheet Action Sometimes Doesn't Show Up

Issue: https://github.com/tls-inspector/tls-inspector/issues/204

This is a known iOS and iPad OS bug. As of iOS 14 it is still unresolved.

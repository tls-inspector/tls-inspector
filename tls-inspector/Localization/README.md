# Localization

TLS Inspector supports multiple languages through the code located here.

Most of the text seen in the TLS Inspector application, such as labels on buttons and dialog
messages, are localized into any of the languages supported by the app.

Translated items are identified using a key, which is typically (but not always) the English
translation, and mapped to each of the translations.

For example:

```yaml
- key: Trusted
  values:
    en: Trusted
    es: De confianza
    de: Vertrauenswürdig
```

Some translated items may require values to be populated at runtime by the app, for example if we
need to specify a domain name in a translated string, that value would be different each time
depending on what the user is doing.

To help with this, some items include variables identified in the key. For example:

```yaml
- key: Renew Certificate for {domain}
  values:
    en: Renew Certificate for {0}
    es: Renovar certificado para {0}
    de: Erneuere Zertifikat für {0}
```

Here the value for `{domain}` would be populated by the app. You'll notice in the translated strings
that we use `{0}` - this number refers to the index (starting at 0) of the variable from the key. If
we had multiple variables, you would reference those with `{1}`, `{2}`, and so on. This is needed
because the position of that variable may differ between languages.

## Adding a New Language

Thank you for your interest in localizing TLS Inspector into a new language! To add a new language
to the app, you must:

- Add a translated version for each item in your language in `strings.yml`
- Add your language to `languages` and `languageNameMap` in `lang.py`

## Localization Guidelines

### Country Names

TLS Inspector includes a mapping of ISO two letter country codes to their name. As geopolitical
matters can often be complex (are are often deeply rooted in racist colonialism), use your best 
judgement when providing these translations. Keep in mind how a country is referred to may differ
greatly than how governments or political bodies may refer to it.

#### Requirements

While we ask you to use your best judgement for country names, we do have the following non-negotiable requirements:

- Taiwan (`TW`) must never include "Province of China", or use "Chinese Taipei".
- Ukraine (`UA`) must never include "Province" or "Territory" of Russia.
- Canada (`CA`), Greenland (`GL`), Panama (`PA`) must never include "Territory" or "State" of The United States of America.

Willful violation of these requirements may result in your contributions being removed as well as being banned from
future contributions to the project.

## Licensing

While TLS Inspector is primarily a GPL3.0 product, localization strings are licensed using CC BY-SA
4.0 Attribution-ShareAlike 4.0 International.

# Localization

TLS Inspector supports multiple languages through the code located here.

Nearly all the text seen in the TLS Inspector application, such as labels on buttons and dialog
messages, are localized strings which reflect the language preference of the user.

Localization helps to ensure that more than just English-reading people can use and enjoy the app.

## Translators Guide

Thank you for your interest in translating TLS Inspector! We've prepared this guide to help ensure
you have a smooth process localizing the app into your language.

To translate the app, please:

1. Review section 1 ("How Localization Works in TLS Inspector") and section 4 ("Licensing") below
2. Download a copy the [English strings file](https://github.com/tls-inspector/tls-inspector/blob/app-store/tls-inspector/Localization/Strings/en.strings)
3. Translate all the string values

If you are not comfortable making code changes or using git, you may stop here and email your
translated file to hello@tlsinspector.com and we will take care of the rest. Otherwise, you can:

4. Fork this repo and add your translated file to `tlsinspector/Localization/Strings`. Name the
file with your language's two-letter code, similar to the other files in that directory.
5. Modify the `languages` and `languageNameMap` variables in `tlsinspector/Localization/lang.py`
6. Run `lang.py` to update the localization source
7. Submit a pull request with your changes

## 1. How Localization Works in TLS Inspector

Individual localized texts are known as a string. Each string has a fixed key that identifies it 
across languages.

Typically these keys are the English translation, however, for long strings of text, a short
descriptive name may be used instead.

### 1.1. Variable Population

Sometimes strings need to have variables inserted at specific locations within them. For example
with `"Hello {name}"` we would need to replace `{name}` with a value.

To accomplish this, we would use a string entry with a key of `Hello {name}` and a value of
`Hello {0}`.

In the key, we define a variable `{name}`. We use a short, single word to describe the variable to
both help translates understand what will go there, as well as identify that value in code for
programmers.

In the value, we define the position of that variable with `{0}`. The number 0 is import here as it
refers to the first parameter (`{name}`). The number is always one less, so `{0}` refers to the
first, `{1}` would refer to the second, so on.

### 1.2. Strings Files

TLS Inspector's localized strings are stored in `.strings` files. These files contain one entry per
line in the format of the key and value separated by the TAB character (\t).

There's a few rules with strings files that you should know:

- The copyright and license at the top of the file is required and should not be changed.
- Lines that begin with a `#` are ignored and can be used for comments.
- If a string value must have a newline, instead use a literal `\n`.
- Keys are case-insensitive, duplicate keys aren't allowed.

English is the primary language, as that is the language best known by the developer. The English
strings file is used as a reference for what strings needs to be present in the other string files.

Keys that are in need of translation will have a preceding `#TODO` comment above the entry. Please
remove this comment when the translation has been completed.

### 1.3 Country Names

TLS Inspector includes a mapping of ISO two letter country codes to their name. As geopolitical
matters can often be complex (and are often deeply rooted in racist colonialism), we ask that you 
use your best judgement when providing these translations. Keep in mind how a country is referred to
may differ greatly than how governments or political bodies may wish you to refer to it.

#### 1.3.1 Requirements

While we ask you to use your best judgement for country names, we do have the following
**non-negotiable** requirements:

- Taiwan (`TW`) must never include _"Province of China"_, or be called _"Chinese Taipei"_.
- Ukraine (`UA`) must never include _"Province"_ or _"Territory"_ of Russia.
- Canada (`CA`), Greenland (`GL`), Panama (`PA`) must never include _"Territory"_ or _"State"_ of
The United States of America.

**Intentional violation of these requirements will result in your contributions being removed and
your account being banned from future contributions to the project.**

## 2. Compiling Localization

An including python script `lang.py` is used to compile the localization of the app. This script:

- Organizes the strings files
 - Sorts the strings alphabetically by key
 - Remove string entries no longer present
 - Adds missing string entries with a TODO comment
- Generates the `Localization.swift` source to be used in the app

## 3. Using Localized Strings in Code

The python script generates a swift source code file that provides the `Localize` class. This class
contains a static function for each string entry. If the entry uses variables, those are passed
through as parameters to the function.

## 4. Licensing

While TLS Inspector is primarily a GPL3.0 product, localization strings are
licensed using CC BY-SA 4.0 Attribution-ShareAlike 4.0 International.

Your contributions will be credited in the app using a name of your choice.

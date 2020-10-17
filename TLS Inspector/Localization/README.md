# Localization

TLS Inspector supports multiple languages through the code located here.

# Strings

Most of the text seen in the TLS Inspector application, such as labels on buttons and dialog messages, are localized strings which are loaded in from a dictionary at launch time.

Items are mapped from a fixed key to the translated string. The key is typically the English translation, however it may be an identifier if the string is long, or the key is determined by a variable.

## String Variables

Sometimes strings need to have variables inserted at specific locations within them. For example with `"Hello {name}"` we would need to replace `{name}` with a value.

To identify a variable within a translated string you specify the index of that variable, for example: `"Hello {0}"`. In code, we pass an array of values that are populated into the string by their index. The order of the variables does not matter in the translated string, only that the index matches that of the array. For example, this is perfectly valid: `"My name is {1}, are you {0}?"`. Variables can be repeated multiple times.

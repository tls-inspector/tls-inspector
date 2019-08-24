@implementation lang

static id _langDict;
static NSMutableArray<NSString *> * _missingKeys;

+ (void) loadDict {
    NSString * preferrendLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString * lang;
    for (NSString * supportedLanguage in @[@"en"]) {
        if ([preferrendLang hasPrefix:supportedLanguage]) {
            lang = supportedLanguage;
        }
    }
    if (lang == nil) { lang = @"en"; }
    _langDict = [NSDictionary dictionaryWithContentsOfFile:
                 [[NSBundle mainBundle] pathForResource:lang ofType:@"plist"]];
    _missingKeys = [NSMutableArray new];
}

+ (NSString *) key:(NSString *)key dict:(NSDictionary *)dict {
    NSString * translatedString = dict[key];
    if (translatedString == nil) {
        if (![_missingKeys containsObject:key]) {
            NSLog(@"Unrecognized language key: %@", key);
            [_missingKeys addObject:key];
        }
        translatedString = key;
    }
    return translatedString;
}

+ (NSString *) key:(NSString *)key args:(NSArray<NSString *> *)args dict:(NSDictionary *)dict {
    NSString * translatedString = [lang key:key dict:dict];
    NSString * stringKey;
    NSUInteger length = args.count;
    for (int i = 0; i < length; i++) {
        NSString * val = args[i];
        if (val == nil) {
            val = @"";
        }
        stringKey = [NSString stringWithFormat:@"{%u}", i];
        translatedString = [translatedString stringByReplacingOccurrencesOfString:stringKey
                                                                       withString:args[i]];
    }
    
    return translatedString;
}

+ (NSString *) key:(NSString *)key {
    if (!key) {
        return @"";
    }
    
    if (_langDict == nil) {
        [lang loadDict];
    }
    return [lang key:key dict:_langDict];
}

+ (NSString *) key:(NSString *)key args:(NSArray<NSString *> *)args {
    if (_langDict == nil) {
        [lang loadDict];
    }
    return [lang key:key args:args dict:_langDict];
}

+ (NSString *) key:(NSString *)key forLanguage:(NSString *)language {
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:language ofType:@"plist"]];
    return [lang key:key dict:dict];
}

+ (NSString *) key:(NSString *)key
              args:(NSArray<NSString *> *)args
       forLanguage:(NSString *)language {
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:language ofType:@"plist"]];
    return [lang key:key args:args dict:dict];
}

@end

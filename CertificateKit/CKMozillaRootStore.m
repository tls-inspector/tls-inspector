//
//  CKMozillaRootStore.h
//
//  LGPLv3
//
//  Copyright (c) 2022 Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>.

#import "CKMozillaRootStore.h"
#include <openssl/x509.h>

@implementation CKMozillaRootStore

+ (void) blah {
    X509_STORE * store = X509_STORE_new();
    NSString * caBundlePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"mozilla_ca_bundle" ofType:@"txt"];
    int result = X509_STORE_load_file(store, caBundlePath.UTF8String);
    if (result) {
        printf("Huh?\n");
    } else {
        printf("What?\n");
    }
}

@end

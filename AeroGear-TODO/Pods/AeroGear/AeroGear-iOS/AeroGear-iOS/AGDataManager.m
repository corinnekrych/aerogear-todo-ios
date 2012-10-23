/*
 * JBoss, Home of Professional Open Source
 * Copyright 2012, Red Hat, Inc., and individual contributors
 * by the @authors tag. See the copyright.txt in the distribution for a
 * full listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGDataManager.h"
#import "AGMemoryStorage.h"

@implementation AGDataManager {
    NSMutableDictionary* _stores;
}

- (id)init {
    self = [super init];
    if (self) {
        _stores = [NSMutableDictionary dictionary];
    }
    return self;
}

+(id)manager {
    return [[self alloc] init];
}

-(id<AGStore>)add:(NSString*) storeName {
    return [self add:storeName type:@"MEMORY"];
}

-(id<AGStore>)add:(NSString*) storeName type:(NSString*) type {
    // TODO check ALL supported types...
    if (! [type isEqualToString:@"MEMORY"]) {
        return nil;
    }
    
    
    id<AGStore> store = [[AGMemoryStorage alloc] init];;
    [_stores setValue:store forKey:storeName];
    return store;
}

-(id<AGStore>)remove:(NSString*) storeName {
    id<AGStore> store = [self get:storeName];
    [_stores removeObjectForKey:storeName];
    return store;
}

-(id<AGStore>)get:(NSString*) storeName {
    return [_stores valueForKey:storeName];
}

@end

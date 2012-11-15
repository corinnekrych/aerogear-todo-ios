/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGDataManager.h"
#import "AGMemoryStorage.h"
#import "AGStoreConfiguration.h"

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


-(id<AGStore>) store:(void (^)(id<AGStoreConfig> config)) config {
    AGStoreConfiguration* storeConfig = [[AGStoreConfiguration alloc] init];
    
    if (config) {
        config(storeConfig);
    }
   
    // TODO check ALL supported types...
    if (! [[storeConfig type] isEqualToString:@"MEMORY"]) {
        return nil;
    }

    id<AGStore> store = [AGMemoryStorage storeWithConfig:storeConfig];
    [_stores setValue:store forKey:[storeConfig name]];
    
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

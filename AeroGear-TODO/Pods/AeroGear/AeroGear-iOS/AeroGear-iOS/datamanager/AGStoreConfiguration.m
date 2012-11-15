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

#import "AGStoreConfiguration.h"

@implementation AGStoreConfiguration{
    NSMutableDictionary* _config;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [NSMutableDictionary dictionary];
        
        
        // default values:
        [_config setValue:@"MEMORY" forKey:@"type"];
        [_config setValue:@"id" forKey:@"recordId"];        
    }
    return self;
}


-(void) name:(NSString*) name {
    [_config setValue:name forKey:@"name"];
}
-(void) type:(NSString*) type {
    [_config setValue:type forKey:@"type"];
}

-(void) recordId:(NSString*) recordId {
    [_config setValue:recordId forKey:@"recordId"];
}


// getters...
-(NSString*) name {
    return [_config valueForKey:@"name"];
}
-(NSString*) type {
    return [_config valueForKey:@"type"];
}
-(NSString*) recordId {
    return [_config valueForKey:@"recordId"];
}

@end

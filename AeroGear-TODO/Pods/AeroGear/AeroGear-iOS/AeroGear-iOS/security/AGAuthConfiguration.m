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

#import "AGAuthConfiguration.h"

@implementation AGAuthConfiguration {
    NSMutableDictionary* _config;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [NSMutableDictionary dictionary];
        
        
        // default values:
        [_config setValue:@"REST" forKey:@"type"];
        [_config setValue:@"Auth-Token" forKey:@"tokenHeaderName"];
        [_config setValue:@"auth/login" forKey:@"loginEndpoint"];
        [_config setValue:@"auth/logout" forKey:@"logoutEndpoint"];
        [_config setValue:@"auth/enroll" forKey:@"enrollEndpoint"];
        
    }
    return self;
}


-(void) name:(NSString*) name {
    [_config setValue:name forKey:@"name"];
}
-(void) type:(NSString*) type {
    [_config setValue:type forKey:@"type"];
}
-(void) baseURL:(NSURL*) baseURL {
    [_config setValue:baseURL forKey:@"baseURL"];
}
-(void) loginEndpoint:(NSString*) loginEndpoint {
    [_config setValue:loginEndpoint forKey:@"loginEndpoint"];
}
-(void) logoutEndpoint:(NSString*) logoutEndpoint {
    [_config setValue:logoutEndpoint forKey:@"logoutEndpoint"];
}
-(void) enrollEndpoint:(NSString*) enrollEndpoint {
    [_config setValue:enrollEndpoint forKey:@"enrollEndpoint"];
}
-(void) tokenHeaderName:(NSString*) tokenHeaderName {
    [_config setValue:tokenHeaderName forKey:@"tokenHeaderName"];
}



// getters...
-(NSString*) name {
    return [_config valueForKey:@"name"];
}
-(NSString*) type {
    return [_config valueForKey:@"type"];
}
-(NSURL*) baseURL {
    return [_config valueForKey:@"baseURL"];
}
-(NSString*) loginEndpoint {
    return [_config valueForKey:@"loginEndpoint"];
}
-(NSString*) logoutEndpoint {
    return [_config valueForKey:@"logoutEndpoint"];
}
-(NSString*) enrollEndpoint {
    return [_config valueForKey:@"enrollEndpoint"];
}
-(NSString*) tokenHeaderName {
    return [_config valueForKey:@"tokenHeaderName"];   
}

@end

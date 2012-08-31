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

#import "AGRestAdapter.h"
#import "AGHttpClient.h"

@implementation AGRestAdapter {
    AGHttpClient* _restClient;
}

@synthesize type = _type;
@synthesize url = _url;

- (id)init
{
    self = [super init];
    if (self) {
        // base inits:
        _type = @"REST";
    }
    return self;
}

-(id) initForURL:(NSURL*) url {
    self = [self init];
    if (self) {
        _url = url.absoluteString;
        _restClient = [AGHttpClient clientFor:url];
        _restClient.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}

+(id) pipeForURL:(NSURL*) url {
    return [[self alloc] initForURL:url];
}

// read all, via HTTP GET
-(void) read:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {

    // TODO: better Endpoints....
    [_restClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];
}

-(void) readWithFilter:(id)filterObject
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure {
    // TODO...
}


-(void) save:(NSDictionary*) object
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {

    // Does a PUT or POST based on the fact if the object
    // already exists (if there is an 'id').
    
    // the blocks are unique to PUT and POST, so let's define them up-front:
    id successCallback = ^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Create Project response: %@", responseObject);
        if (success) {
            NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    };
    
    id failureCallback = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            NSLog(@"Invoking failure block....");
            failure(error);
        }
    };
    
    
    if ([object objectForKey:@"id"]) {
        NSLog(@"HTTP PUT to update the given object");
        NSString* updateIdPath = [object objectForKey:@"id"];
        [_restClient putPath:updateIdPath parameters:object success:successCallback failure:failureCallback];
    }
    else {
        NSLog(@"HTTP POST to create the given object");
        [_restClient postPath:@"" parameters:object success:successCallback failure:failureCallback];
    }
}

-(void) remove:(id) key
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure {

    id deleteKey;
    if ([key isKindOfClass:[NSString class]]) {
        deleteKey = key;
    } else {
        deleteKey = [key stringValue];
    }

    [_restClient deletePath:deleteKey parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];

}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ [type=%@, url=%@]", self.class, _type, _url];
}

@end
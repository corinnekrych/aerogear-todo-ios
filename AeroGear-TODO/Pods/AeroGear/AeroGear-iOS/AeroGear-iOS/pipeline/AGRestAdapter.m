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

#import "AGRestAdapter.h"
#import "AGAuthenticationModuleAdapter.h"

#import "AGHttpClient.h"

@implementation AGRestAdapter {
    AGHttpClient* _restClient;
    id<AGAuthenticationModuleAdapter> _authModule;
    
    NSString* _recordId;
}

// =====================================================
// ================ public API (AGPipe) ================
// =====================================================

@synthesize type = _type;
@synthesize url = _url;

// ==============================================
// ======== 'factory' and 'init' section ========
// ==============================================

+(id) pipeWithConfig:(id<AGPipeConfig>) pipeConfig {
    return [[self alloc] initWithConfig:pipeConfig];
}

-(id) initWithConfig:(id<AGPipeConfig>) pipeConfig {
    self = [super init];
    if (self) {
        _type = @"REST";

        // set all the things:
        AGPipeConfiguration* config = (AGPipeConfiguration*) pipeConfig;
     
        NSURL* baseURL = [config baseURL];
        NSString* endpoint = [config endpoint];
        // append the endpoint/name and use it as the final URL
        NSURL* finalURL = [self appendEndpoint:endpoint toURL:baseURL];
        
        _url = finalURL.absoluteString;
        _recordId = [config recordId];
        _authModule = (id<AGAuthenticationModuleAdapter>) [config authModule];
        
        _restClient = [AGHttpClient clientFor:finalURL];
        _restClient.parameterEncoding = AFJSONParameterEncoding;
    }
    
    return self;
}

// private helper to append the endpoint
-(NSURL*) appendEndpoint:(NSString*)endpoint toURL:(NSURL*)baseURL {
    if (endpoint == nil) {
        endpoint = @"";
    }
    
    // append the endpoint name and use it as the final URL
    return [baseURL URLByAppendingPathComponent:endpoint];
}

// =====================================================
// ======== public API (AGPipe) ========
// =====================================================

// read all, via HTTP GET
-(void) read:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {
    
    // try to add auth.token:
    [self applyAuthToken];
    
    // TODO: better Endpoints....
    [_restClient getPath:_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];
}

-(void) readWithFilter:(id)filterObject
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure {
//    // try to add auth.token:
//    [self applyAuthToken];
// TODO...
}

-(void) save:(NSDictionary*) object
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {

    // try to add auth.token:
    [self applyAuthToken];
    
    // Does a PUT or POST based on the fact if the object
    // already exists (if there is an 'id').
    
    // the blocks are unique to PUT and POST, so let's define them up-front:
    id successCallback = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    };
    
    id failureCallback = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    };
    
    
    if ([object objectForKey:_recordId]) {
        //TODO: NSLog(@"HTTP PUT to update the given object");
        
        id key = [object objectForKey:_recordId];
        
        NSString* updateId;
        if ([key isKindOfClass:[NSString class]]) {
            updateId = key;
        } else {
            updateId = [key stringValue];
        }
        
        [_restClient putPath:[self appendObjectPath:updateId] parameters:object success:successCallback failure:failureCallback];
        return;
    }
    else {
        //TODO: NSLog(@"HTTP POST to create the given object");
        [_restClient postPath:_url parameters:object success:successCallback failure:failureCallback];
        return;
    }
}

-(void) remove:(id) key
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure {

    // try to add auth.token:
    [self applyAuthToken];

    id deleteKey;
    if ([key isKindOfClass:[NSString class]]) {
        deleteKey = key;
    } else {
        deleteKey = [key stringValue];
    }

    [_restClient deletePath:[self appendObjectPath:deleteKey] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    } ];
}

// appends the path for delete/updates to the URL
-(NSString*) appendObjectPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@/%@", _url, path];
}

// helper method:
-(void) applyAuthToken {
    if ([_authModule isAuthenticated]) {
        [_restClient setDefaultHeader:@"Auth-Token" value:[_authModule authToken]];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ [type=%@, url=%@]", self.class, _type, _url];
}

+ (BOOL) accepts:(NSString *) type {
    return [type isEqualToString:@"REST"];
}

@end
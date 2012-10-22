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

#import "AGRestAuthentication.h"
#import "AGHttpClient.h"


// TODO: Use #pragma marks to categorize methods and protocol implementations.

@implementation AGRestAuthentication {
    // ivars
    AGHttpClient* _restClient;
    
}

// =====================================================
// ======== public API (AGAuthenticationModule) ========
// =====================================================
@synthesize type = _type;
@synthesize baseURL = _baseURL;
@synthesize loginEndpoint = _loginEndpoint;
@synthesize logoutEndpoint = _logoutEndpoint;
@synthesize enrollEndpoint = _enrollEndpoint;

// custom getters for our properties (from AGAuthenticationModule)
-(NSString*) loginEndpoint {
    return [_baseURL stringByAppendingString:_loginEndpoint];
}

-(NSString*) logoutEndpoint {
    return [_baseURL stringByAppendingString:_logoutEndpoint];
}

-(NSString*) enrollEndpoint {
    return [_baseURL stringByAppendingString:_enrollEndpoint];
}

// ==============================================================
// ======== internal API (AGAuthenticationModuleAdapter) ========
// ==============================================================
@synthesize authToken = _authToken;



// ==============================================
// ======== 'factory' and 'init' section ========
// ==============================================

+(id) moduleForBaseURL:(NSURL*) baseURL {
    return [[self alloc] initForBaseURL:baseURL];
}

- (id)init {
    self = [super init];
    if (self) {
        // defaults:
        _type = @"REST";
        _loginEndpoint  = @"auth/login";
        _logoutEndpoint = @"auth/logout";
        _enrollEndpoint = @"auth/register";
        
        
    }
    return self;
}

-(id) initForBaseURL:(NSURL*) baseURL {
    self = [self init];
    if (self) {
        _baseURL = baseURL.absoluteString;
        _restClient = [AGHttpClient clientFor:baseURL];
        _restClient.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}

-(void)dealloc {
    _restClient = nil;
}


// =====================================================
// ======== public API (AGAuthenticationModule) ========
// =====================================================
-(void) enroll:(id) userData
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure {
    
    
    [_restClient postPath:_enrollEndpoint parameters:userData success:^(AFHTTPRequestOperation *operation, id responseObject) {

        // stash the auth token...:
        [self readAndStashToken:operation];
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    }];
    
}

-(void) login:(NSString*) username
   password:(NSString*) password
    success:(void (^)(id object))success
    failure:(void (^)(NSError *error))failure {
    
    NSDictionary* loginData = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil];
    
    [_restClient postPath:_loginEndpoint parameters:loginData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // stash the auth token...:
        [self readAndStashToken:operation];
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    }];
    
    
}

-(void) logout:(void (^)())success
     failure:(void (^)(NSError *error))failure {
    
    // stash the token to the header:
    [_restClient setDefaultHeader:@"Auth-Token" value:_authToken];
    
    // logoff:
    [_restClient postPath:_logoutEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // hrm, really needed....:
        [self deauthorize];
        
        if (success) {
            //TODO: NSLog(@"Invoking successblock....");
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            //TODO: NSLog(@"Invoking failure block....");
            failure(error);
        }
    }];
}

// private method
-(void) readAndStashToken:(AFHTTPRequestOperation*) operation {
    // TODO: hard-coded header name:
    _authToken = [[[operation response] allHeaderFields] valueForKey:@"Auth-Token"];
}

// ==============================================================
// ======== internal API (AGAuthenticationModuleAdapter) ========
// ==============================================================
- (BOOL)isAuthenticated {
    //return !!_authToken;
    return (nil != _authToken);
}
- (void)deauthorize {
    _authToken = nil;
}

// general override...
-(NSString *) description {
    return [NSString stringWithFormat: @"%@ [type=%@, loginEndpoint=%@, logoutEndpoint=%@, enrollEndpoint=%@]", self.class, _type, _loginEndpoint, _logoutEndpoint, _enrollEndpoint];
}

@end

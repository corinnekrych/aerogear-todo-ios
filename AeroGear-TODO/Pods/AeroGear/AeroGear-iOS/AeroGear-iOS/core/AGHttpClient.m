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

#import "AGHttpClient.h"


@implementation AGHttpClient

+ (AGHttpClient *)clientFor:(NSURL *)url {
    return [[self alloc] initWithBaseURL:url];
}

- (id)initWithBaseURL:(NSURL *)url {
	
	// TODO: remove below trailing slash section, once we are using AFNetworking 1.0
	// since we are still supporting iOS 4, we can't use AFNetworking 1.0,
	// however we need this fix to get the library working correctly...
	
    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

// override to not handle the cookies
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    // invoke the 'requestWithMethod:path:parameters:' from AFNetworking:
    NSMutableURLRequest* req = [super requestWithMethod:method path:path parameters:parameters];
    
    // disable the default cookie handling in the override:
    [req setHTTPShouldHandleCookies:NO];

    return req;
}

@end

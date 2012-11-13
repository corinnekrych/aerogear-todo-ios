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

#import <Foundation/Foundation.h>
#import "AGConfig.h"

/**
 * Represents the public API to configure AGAuthenticationModule objects.
 */
@protocol AGAuthConfig <AGConfig>

/**
 * Applies the baseURL to the configuration.
 *
 * @param baseURL The baseURL of the actual AGAuthenticationModule object.
 */
-(void) baseURL:(NSURL*) baseURL;

/**
 * Applies the "login endpoint" to the configuration.
 *
 * @param loginEndpoint The login endpoint of the actual AGAuthenticationModule object.
 */
-(void) loginEndpoint:(NSString*) loginEndpoint;

/**
 * Applies the "logout endpoint" to the configuration.
 *
 * @param logoutEndpoint The logout endpoint of the actual AGAuthenticationModule object.
 */
-(void) logoutEndpoint:(NSString*) logoutEndpoint;

/**
 * Applies the "enroll endpoint" to the configuration.
 *
 * @param enrollEndpoint The enroll endpoint of the actual AGAuthenticationModule object.
 */
-(void) enrollEndpoint:(NSString*) enrollEndpoint;

/**
 * Applies the tokenHeaderName header name to the configuration.
 *
 * @param tokenHeaderName The token-header-name of the actual AGAuthenticationModule object.
 */
-(void) tokenHeaderName:(NSString*) tokenHeaderName;

@end

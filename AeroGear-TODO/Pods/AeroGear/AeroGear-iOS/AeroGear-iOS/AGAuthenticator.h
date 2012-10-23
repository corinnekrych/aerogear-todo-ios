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

#import <Foundation/Foundation.h>
#import "AGAuthenticationModule.h"

/**
 * AGAuthenticator manages different AGAuthenticationModule implementations. It is basically a
 * factory that hides the concrete instanciation of a specific AGAuthenticationModule implementation.
 * The class offers simple APIs to add, remove or get access to a 'authentication module'.
 *
 */
@interface AGAuthenticator : NSObject


/**
 * A factory method to instantiate an empty AGAuthenticator.
 *
 * @return the AGAuthenticator object
 */
+(id) authenticator;

/**
 * Creates a new default (REST) AGAuthenticationModule implemention.
 *
 * @param moduleName The name of the actual auth module object.
 * @param baseURL the base url for the server.
 */
-(id<AGAuthenticationModule>)add:(NSString*) moduleName baseURL:(NSURL*)baseURL;

/**
 * Creates a new AGAuthenticationModule implemention. The actual type is determined by the type argument.
 *
 * @param moduleName The name of the actual auth module object.
 * @param baseURL the base url for the server.
 * @param type The type of the new auth module object.
 */
-(id<AGAuthenticationModule>)add:(NSString*) moduleName baseURL:(NSURL*)baseURL type:(NSString*) type;

/**
 * Removes a AGAuthenticationModule implemention from the AGAuthenticator. The auth module,
 * to be removed is determined by the moduleName argument.
 *
 * @param moduleName The name of the actual auth module object.
 */
-(id<AGAuthenticationModule>)remove:(NSString*) moduleName;

/**
 * Loads a given AGAuthenticationModule implemention, based on the given moduleName argument.
 *
 * @param moduleName The name of the actual auth module object.
 */
-(id<AGAuthenticationModule>)get:(NSString*) moduleName;


@end

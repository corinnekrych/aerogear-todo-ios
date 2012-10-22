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

/**
 * AGAuthenticationModule represents an authentication module...
 */
@protocol AGAuthenticationModule <NSObject>

/**
 * Returns the type of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* type;

/**
 * Returns the baseURL string of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* baseURL;

/**
 * Returns the 'login endpoint' of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* loginEndpoint;

/**
 * Returns the 'logout endpoint' of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* logoutEndpoint;

/**
 * Returns the 'enroll endpoint' of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* enrollEndpoint;


/**
 * Performs a signup of a new user. The request accepts a NSDictionary which will be translated to JSON 
 * and send to the endpoint.
 *
 * @param userData A map (NSDictionary) containing all the information requested by the
 * 'registration' service.
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: A collection (NSDictionary), containing the response
 * from the 'signup' service.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) enroll:(id) userData
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure;

/**
 * Performs the login of the give user. Since the data will be send in plaintext, it is IMPORTANT,
 * to run the signin via TLS/HTTPS.
 *
 * @param username username
 *
 * @param password password
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: A collection (NSDictionary), containing the response
 * from the 'login' service.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) login:(NSString*) username
    password:(NSString*) password
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure;

/**
 * Performs the logout of the current user.
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes no argument.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) logout:(void (^)())success
     failure:(void (^)(NSError *error))failure;

@end

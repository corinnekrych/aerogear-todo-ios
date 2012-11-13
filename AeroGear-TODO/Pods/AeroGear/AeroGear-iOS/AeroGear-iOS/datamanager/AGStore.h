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

/**
 * AGStore represents an abstraction layer for a storage system.
 */
@protocol AGStore <NSObject>

/**
 * Returns the type of the underlying 'store implementation'
 */
@property (nonatomic, readonly) NSString* type;

/**
 * Reads all the data from the underlying storage system.
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: A collection (NSArray), containing all stored
 * objects.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) readAll:(void (^)(NSArray* objects))success
        failure:(void (^)(NSError *error))failure;

/**
 * Reads a specific object/record from the underlying storage system.
 *
 * @param recordId id from the desired object
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: The object (or nil) read from the
 * underlying storage.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) read:(id) recordId
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure;

/**
 * Reads all, based on a filter, from the underlying storage system.
 *
 * @param filterObject the filter criteria.
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: A collection (NSArray), containing all stored
 * objects, matching the given filter. The argument is nil, if nothing matches the criteria.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) filter:(id)filterObject
       success:(void (^)(NSArray* objects))success
       failure:(void (^)(NSError *error))failure;


/**
 * Saves the given object in the underlying storage system.
 *
 * @param data An object or a collection (e.g. NSArray) which is being persisted.
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: The object that has been stored.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) save:(id) data
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure;


/**
 * Resets the entire storage system.
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes no argument.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) reset:(void (^)())success
      failure:(void (^)(NSError *error))failure;


/**
 * Removes a specific object/record from the underlying storage system.
 *
 * @param recordId id from the desired object
 *
 * @param success A block object to be executed when the operation finishes successfully.
 * This block has no return value and takes one argument: The object that has been removed.
 *
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 * This block has no return value and takes one argument: The `NSError` object describing
 * the error that occurred.
 */
-(void) remove:(id) recordId
       success:(void (^)(id object))success
       failure:(void (^)(NSError *error))failure;

@end

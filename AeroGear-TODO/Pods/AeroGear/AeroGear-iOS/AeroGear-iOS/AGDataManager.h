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
#import "AGStore.h"

/**
 * AGDataManager manages different AGStore implementations. It is basically a
 * factory that hides the concrete instanciation of a specific AGStore implementation.
 * The class offers simple APIs to add, remove or get access to a 'data store'.
 *
 * NOTE: Right now, there is NO automatic data sync. This is up to the user.
 */
@interface AGDataManager : NSObject


/**
 * An initializer method to instantiate the AGDataManager, which
 * contains an in-memory AGStore object.
 *
 * @param name the logical name of the first AGStore object
 *
 * @return the AGDataManager object
 */
-(id) initWithStore:(NSString*) name;

/**
 * An initializer method to instantiate the AGDataManager, which
 * contains a AGStore object. The actual type is determined by the type argument.
 *
 * @param name the logical name of the first AGStore object
 * @param type the type of the actual storage system
 *
 * @return the AGDataManager object
 */
-(id) initWithStore:(NSString*) name type:(NSString*)type;

/**
 * A factory method to instantiate the AGDataManager, which
 * contains an in-memory AGStore object.
 *
 * @param name the logical name of the first AGStore object
 *
 * @return the AGDataManager object
 */
+(id) store:(NSString*) name;

/**
 * A factory method to instantiate the AGDataManager, which
 * contains a AGStore object. The actual type is determined by the type argument.
 *
 * @param name the logical name of the first AGStore object
 * @param type the type of the actual storage system
 *
 * @return the AGDataManager object
 */
+(id) store:(NSString*) name type:(NSString*)type;

/**
 * Creates a new default (in memory) AGStore implemention.
 *
 * @param storeName The name of the actual data store object.
 */
-(id<AGStore>)add:(NSString*) storeName;

/**
 * Creates a new AGStore implemention. The actual type is determined by the type argument.
 *
 * @param storeName The name of the actual data store object.
 * @param type The type of the new data store object.
 */
-(id<AGStore>)add:(NSString*) storeName type:(NSString*) type;

/**
 * Removes a AGStore implemention from the AGDataManager. The store to be removed
 * is determined by the storeName argument.
 *
 * @param storeName The name of the actual data store object.
 */
-(id<AGStore>)remove:(NSString*) storeName;

/**
 * Loads a given AGStore implemention, based on the given storeName argument.
 *
 * @param storeName The name of the actual data store object.
 */
-(id<AGStore>)get:(NSString*) storeName;

@end

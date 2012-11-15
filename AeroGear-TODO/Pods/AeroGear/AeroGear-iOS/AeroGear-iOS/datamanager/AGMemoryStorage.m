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

#import "AGMemoryStorage.h"

@implementation AGMemoryStorage {
    // ivars
    NSMutableArray* _array;
    NSString* _recordId;
}

@synthesize type = _type;

// ==============================================
// ======== 'factory' and 'init' section ========
// ==============================================

+(id) storeWithConfig:(id<AGStoreConfig>) storeConfig {
    return [[self alloc] initWithConfig:storeConfig];
}

-(id) initWithConfig:(id<AGStoreConfig>) storeConfig {
    self = [super init];
    if (self) {
        // base inits:
        _type = @"MEMORY";
        _array = [NSMutableArray array];

        AGStoreConfiguration *config = (AGStoreConfiguration*) storeConfig;
        _recordId = [config recordId];
    }
    
    return self;
}

// =====================================================
// ======== public API (AGStore) ========
// =====================================================

-(void) readAll:(void (^)(NSArray* objects))success
        failure:(void (^)(NSError *error))failure {
    
    // TODO: delegate to filter???


    @try {
        if (success) {
            // pass along all the data...
            success(_array);
        }
    }
    @catch (NSException *exception) {
        if (failure) {
            // TODO: better Error...
            failure(nil);
        }
    }
    
}

-(void) read:(id) recordId
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure {
    
    id retVal;
    
    @try {
        for (id record in _array) {
            // check the 'id':
            if ([[record objectForKey:_recordId] isEqual:recordId]) {
                // replace/update it:
                retVal = record;
                break;
            }
        }
    }
    @catch (NSException *exception) {
        if (failure) {
            // TODO: better Error...
            failure(nil);
        }
    }
    @finally {
        if (success) {
            success(retVal);
        }
    }
}

-(void) filter:(id)filterObject
       success:(void (^)(NSArray* objects))success
       failure:(void (^)(NSError *error))failure {
    
    // TODO........
    
}

-(void) save:(id) data
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure {
    
    // a 'collection' of objects:
    if ([data isKindOfClass:[NSArray class]]) {

        @try {
            for (id record in data) {
                // we pass in NO success block/callback
                [self saveOne:record success:nil failure:failure];
            }
        }
        @catch (NSException *exception) {
            // should be handles inside of the [saveOne];
        }
        @finally {
            if (success) {
                // once ALL data is stored, we invoke the callback:
                success(data);
            }
        }
        
    } else if([data isKindOfClass:[NSDictionary class]]) {
        // single obj:
        [self saveOne:data success:success failure:failure];
    }
    
}

//private save for one item:
-(void) saveOne:(NSDictionary*) data
     success:(void (^)(id object))success
     failure:(void (^)(NSError *error))failure {
    
    
    @try {
        
        // does the record already exist ?
        BOOL _objFound = NO;
        for (id record in _array) {
            // check the 'id':
            if ([[record objectForKey:_recordId] isEqual:[data objectForKey:_recordId]]) {
                // replace/update it:
                NSUInteger index = [_array indexOfObject:record];
                [_array removeObjectAtIndex:index];
                [_array addObject:data];
                //
                _objFound = YES;
                break;
            }
        }

        if (!_objFound) {
            [_array addObject:data];
        }
        
        
    }
    @catch (NSException *exception) {
        if (failure) {
            // TODO: better Error...
            failure(nil);
        }
    }
    @finally {
        if (success) {
            success(data);
        }
    }
}

-(void) reset:(void (^)())success
      failure:(void (^)(NSError *error))failure {
    
    @try {
        [_array removeAllObjects];
    }
    @catch (NSException *exception) {
        if (failure) {
            // TODO: better Error...
            failure(nil);
        }
    }
    @finally {
        if (success) {
            success();
        }
    }
    
    
}

-(void) remove:(id) recordId
       success:(void (^)(id object))success
       failure:(void (^)(NSError *error))failure {

    id objectToDelete;
    
    @try {
        for (id record in _array) {
            // check the 'id':
            if ([[record objectForKey:_recordId] isEqual:recordId]) {
                // replace/update it:
                objectToDelete = record;
                NSUInteger index = [_array indexOfObject:record];
                [_array removeObjectAtIndex:index];
                break;
            }
        }
    }
    @catch (NSException *exception) {
        if (failure) {
            // TODO: better Error...
            failure(nil);
        }
    }
    @finally {
        if (success) {
            success(objectToDelete);
        }
    }
}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ [type=%@]", self.class, _type];
}

@end

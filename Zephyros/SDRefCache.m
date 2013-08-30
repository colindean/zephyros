//
//  SDRefCache.m
//  Zephyros
//
//  Created by Steven Degutis on 8/30/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDRefCache.h"

@interface SDRefCache ()

@property int64_t maxRespObjID;
@property NSMutableDictionary* objects;

@end

@implementation SDRefCache

- (id) init {
    if (self = [super init]) {
        self.objects = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) store:(id)obj withKey:(id)key {
    [self.objects setObject:obj forKey:key];
}

- (id) refForKey:(id)key {
    return [self.objects objectForKey:key];
}

- (id) storeRef:(id)ref {
    NSArray* keys = [self.objects allKeysForObject: ref];
    
//    NSLog(@"REF: %@", [[ref valueForKey:@"receiver"] title]);
    NSLog(@"KEYS: %@", keys);
    
    if ([keys count] == 0) {
        self.maxRespObjID++;
        NSNumber* newMaxID = @(self.maxRespObjID);
        
        [self.objects setObject:ref
                         forKey:newMaxID];
        
        return newMaxID;
    }
    else if ([keys count] == 1) {
        return [keys lastObject];
    }
    else {
        NSLog(@"crap, somehow we have %ld references to %@", [keys count], ref);
        return [keys lastObject];
    }
}

- (void) removeRefForKey:(id)key {
    [self.objects removeObjectForKey:key];
}

@end

//
//  cdCommit.m
//  Codesaur
//
//  Created by Zak.
//  Copyright (c) 2013 Zak. All rights reserved.
//

#import "MGITCommit.h"

@implementation MGITCommit

- (id)init
{
    self = [super init];
    if (self) {
        self.id = [NSUUID UUID];
    }
    return self;
}

@end

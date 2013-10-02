//
//  cdCommit.h
//  Codesaur
//
//  Created by Zak.
//  Copyright (c) 2013 Zak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGITCommit : NSObject

@property (strong) NSUUID *id;
@property (strong) NSMutableArray *children;

@end

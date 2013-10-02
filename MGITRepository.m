//
//  cdRepository.m
//  Codesaur
//
//  Created by Zak.
//  Copyright (c) 2013 Zak. All rights reserved.
//

#import "MGITRepository.h"

@implementation MGITRepository

- (id)init
{
    self = [super init];
    if (self) {
        _commits = [NSMutableSet setWithCapacity:100];
        self.childrenKeyPath = @"children";
    }

    return self;
}

- (void)mergeChangeFromStage {
    
    MGITCommit *stagedCommit = self.stagedCommit;
    
    if (!stagedCommit || [self.commits containsObject:stagedCommit]) {
		@throw @"ERROR: You tried to add either a nil commit or a commit that's already in the repository.";
        return;
    }
    
    NSLog(@"count key path: %@", self.arrangedObjects);

    
    if (self.commits.count == 0) {
        [self insertObject:stagedCommit atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];
    }
    else {
        [self insertChild:stagedCommit];
    }
    
    self.stagedCommit = nil;
    MGITCommit *commit = stagedCommit;
    
    if ([self.delegate respondsToSelector:@selector(didCommitChange:)]) {
        [self.delegate didCommitChange:commit];
    }
}

- (BOOL)isForwardCommit:(MGITCommit *)commit
{
    BOOL isForwardCommit = YES;
    for (MGITCommit *repoCommit in self.commits) {
        if([commit.id isEqual:repoCommit.id]) {
            isForwardCommit = NO;
            break;
        };
    }
    return isForwardCommit;
}
@end

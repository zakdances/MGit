//
//  cdRepository.m
//  Codesaur
//
//  Created by Zak.
//  Copyright (c) 2013 Zak. All rights reserved.
//

#import "MGITRepository.h"
#import "MGITCommit.h"

//@interface MGITRepository ()
//
//@property (weak) NSOrderedSet		*commits;
//
//@end

@implementation MGITRepository

- (id)initWithMode:(MGITRepositoryMode)mode repositoryCapacity:(NSUInteger)repositoryCapacity stageCapacity:(NSUInteger)stageCapacity
{
    self = [super init];
    if (self) {
		
        _stagedChangesOrCommits	= [NSMutableOrderedSet orderedSetWithCapacity:repositoryCapacity];
		_mode					= mode;
        self.childrenKeyPath	= @"children";
		
		switch (_mode) {
			case MGITRepositoryModeRepository:
				// The stage has no stage
				_stage			= [self.class newStageWithCapacity:stageCapacity];
				_stage.owner	= self;
				break;
				
			default:
				break;
		}
		
    }

    return self;
}

+ (instancetype)repositoryWithCapacity:(NSUInteger)repositoryCapacity
{
	return [[self alloc] initWithMode:MGITRepositoryModeRepository repositoryCapacity:repositoryCapacity stageCapacity:repositoryCapacity];
}

+ (instancetype)repositoryWithCapacity:(NSUInteger)repositoryCapacity stageCapacity:(NSUInteger)stageCapacity
{
	return [[self alloc] initWithMode:MGITRepositoryModeRepository repositoryCapacity:repositoryCapacity stageCapacity:stageCapacity];
}

+ (instancetype)newStageWithCapacity:(NSUInteger)stageCapacity
{
	return [[self alloc] initWithMode:MGITRepositoryModeStage repositoryCapacity:stageCapacity stageCapacity:0];
}
//+ (instancetype)stage
//{
//	return [[self alloc] initWithMode:MGITRepositoryModeStage];
//}

- (void)mergeLastStagedChange {
    
    MGITCommit *change = [self lastStagedChange];
    
//    if (!change || [self.commits containsObject:change]) {
//		@throw @"ERROR: You tried to add either a nil commit or a commit that's already in the repository.";
//        return;
//    }
    
//    NSLog(@"count key path: %@", self.arrangedObjects);

    [self _mergeChange:change];
    
    
//	MGITCommit *commit = change;
//    self.stage.change = nil;
    
    if ([self.delegate respondsToSelector:@selector(didMergeStagedChange:toRepository:)]) {
        [self.delegate didMergeStagedChange:change toRepository:self];
    }
}

// Private method to merge a change
- (void)_mergeChange:(MGITCommit *)change
{
	[_stagedChangesOrCommits addObject:change];
	
	if ([[self arrangedObjects] count] == 0) {
//		NSLog(@"no staged changes or commits yet. Adding now...");
        [self insertObject:change atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndex:0]];
//		NSIndexPath *ip = [self indexPathToObject:_stagedChangesOrCommits.lastObject];
//		NSLog(@"getting index of last commit... %@ model: %@", ip, _stagedChangesOrCommits);
    }
    else {
		// TODO: should be different node
//        [self insertChild:change];
		id lastModelObject = [_stagedChangesOrCommits objectAtIndex:[_stagedChangesOrCommits indexOfObject:change] - 1];
		NSIndexPath *ip = [self indexPathToObject:lastModelObject];
		
//		NSLog(@"getting index of last commit... %@ %@ model: %@", ip, lastModelObject, _stagedChangesOrCommits);
		if (ip == nil) {
			// TODO: fix exception
			NSString *exceptionMessage = [NSString stringWithFormat:@"Something went real bad wrong. There's an orphan object. %@", @(_mode)];
			NSLog(@"%@", exceptionMessage);
			@throw exceptionMessage;
			return;
		}
		
		self.selectionIndexPath = ip;

		NSIndexPath *newChildIndex = [ip indexPathByAddingIndex:[self.selectedNodes[0] childNodes].count ];
		[self insertObject:change atArrangedObjectIndexPath:newChildIndex];



    }
	
	if (_mode == MGITRepositoryModeRepository) {
		[self _removeStagedChange:change];
	}
}

- (void)_removeStagedChange:(MGITCommit *)stagedChange
{
//	NSLog(@"change removed from stage");
	switch (_mode) {
		case MGITRepositoryModeRepository:
			[_stage _removeStagedChange:stagedChange];
			break;
		case MGITRepositoryModeStage:
			
			// Remove change from stage repo
			for (MGITCommit *commit in self.content)
			{
				MGITCommit *_stagedChange = commit;
				if ([stagedChange.id isEqual:_stagedChange.id]) {
					// TODO: Remove node or object or both?
					[self remove:commit];
					break;
				}
			}
			
			[_stagedChangesOrCommits removeObject:stagedChange];
			break;
		default:
			break;
	}
}

- (void)stageChange:(MGITCommit *)change
{
	switch (_mode) {
		case MGITRepositoryModeRepository:
			[_stage stageChange:change];
			break;
		case MGITRepositoryModeStage:
			[self _mergeChange:change];
//			NSLog(@"change merged into stage %@", self.stagedChanges);
			if ([self.owner.delegate respondsToSelector:@selector(didStageChange:toRepository:)]) {
				[self.owner.delegate didStageChange:change toRepository:self.owner];
			}
			break;
		default:
			break;
	}
}

- (MGITCommit *)lastStagedChange
{
	switch (_mode) {
		case MGITRepositoryModeRepository:
			return _stage.stagedChanges.lastObject;
			break;
		case MGITRepositoryModeStage:
			return _stagedChangesOrCommits.lastObject;
			break;
		default:
			break;
	}
}

- (BOOL)isForwardCommit:(MGITCommit *)commit
{
    BOOL isForwardCommit = YES;
//	NSLog(@"hmm %@ %@", (isForwardCommit ? @"YES" : @"NO"), commit.id.UUIDString);
	if (!commit) return NO;

    for (MGITCommit *repoCommit in _stagedChangesOrCommits) {

        if([commit.id isEqual:repoCommit.id]) {
			
            isForwardCommit = NO;
            break;
        };
    }
	
    return isForwardCommit;
}
- (BOOL)isForwardStagedChange:(MGITCommit *)change
{
//    BOOL isForwardStagedChange = YES;
//    for (MGITCommit *stagedChange in _stagedChangesOrCommits) {
//        if([change.id isEqual:stagedChange.id]) {
//            isForwardStagedChange = NO;
//            break;
//        };
//    }
//	NSLog(@"stage search... %@", _stage);
    return [_stage isForwardCommit:change];
}
- (BOOL)isForwardStagedChangeOrCommit:(MGITCommit *)changeOrCommit
{
//    BOOL isForwardStagedChange = (![self isForwardCommit:changeOrCommit] && ![self isForwardStagedChange:changeOrCommit]);
//    for (MGITCommit *stagedChange in _stagedChangesOrCommits) {
//        if([change.id isEqual:stagedChange.id]) {
//            isForwardStagedChange = NO;
//            break;
//        };
//    }
    return [self isForwardCommit:changeOrCommit] && [self isForwardStagedChange:changeOrCommit];
}


//- (NSIndexPath *)indexPathForInsertion
//{
//	NSUInteger rootTreeNodesCount = [[self rootNodes] count];
//	NSArray *selectedNodes = [self selectedNodes];
//	NSTreeNode *selectedNode = nil;
//	NSIndexPath *indexPath;
//	
//	if (selectedNodes.count == 0) {
//		indexPath = [NSIndexPath indexPathWithIndex:rootTreeNodesCount];
//    } else if ([selectedNodes count] == 1) {
//        selectedNode = selectedNodes[0];
//		
//		if ([selectedNode isLeaf] == NO) {
//			indexPath = [[selectedNode indexPath] indexPathByAddingIndex:0];
//		} else {
//			if ([selectedNode parentNode])
//				indexPath = [selectedNode adjacentIndexPath];
//			else
//				indexPath = [NSIndexPath indexPathWithIndex:rootTreeNodesCount];
//		}
//	} else {
//		indexPath = [selectedNodes.lastObject adjacentIndexPath];
//	}
//    
//	return indexPath;
//}

- (NSIndexPath *)indexPathToObject:(id)object {
	
	
	return [self _indexPathToObject:object inTree:self.arrangedObjects];
}

- (NSIndexPath *)_indexPathToObject:(id)object inTree:(NSTreeNode *)node {
	for (NSTreeNode *currentNode in [node childNodes]) {

		
		if ([currentNode representedObject] == object) return [currentNode indexPath];
		
		NSIndexPath *indexPath = [self _indexPathToObject:object inTree:currentNode];
		if (indexPath != nil) return indexPath;
	}
	
	return nil;
}




- (NSOrderedSet *)commits
{
	return _stagedChangesOrCommits;
}

- (NSOrderedSet *)stagedChanges
{
	switch (_mode) {
		case MGITRepositoryModeRepository:
			return _stage.stagedChanges;
			break;
		case MGITRepositoryModeStage:
			return _stagedChangesOrCommits;
			break;
		default:
			break;
	}
}
- (void)setStagedChanges:(NSOrderedSet *)stagedChanges
{

}
@end

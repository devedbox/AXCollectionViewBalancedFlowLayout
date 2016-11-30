//
//  AXCollectionViewFlowLayout.m
//  ExchangeStreet
//
//  Created by devedbox on 2016/10/17.
//  Copyright © 2016年 jiangyou. All rights reserved.
//

#import "AXCollectionViewBalancedFlowLayout.h"

@implementation AXCollectionViewBalancedFlowLayout
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

#pragma mark - Setters
- (void)setFixsSpace:(BOOL)fixsSpace {
    _fixsSpace = fixsSpace;
    [self invalidateLayout];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *modifiedAttributes = [@[] mutableCopy];
    NSMutableSet *originYs = [NSMutableSet set];
    for (int i = 0; i < attributes.count; i ++) {
        UICollectionViewLayoutAttributes *currentAttributes = [[attributes objectAtIndex:i] copy];
        if (currentAttributes.representedElementCategory == UICollectionElementCategorySupplementaryView || currentAttributes.representedElementCategory == UICollectionElementCategoryDecorationView) {
            [modifiedAttributes addObject:currentAttributes];
            continue;
        }
        if (currentAttributes.indexPath.item == 0) {
            // Get section inset.
            UIEdgeInsets sectionInset = [self sectionInsetForSectionAtIndex:currentAttributes.indexPath.section];
            if (currentAttributes.frame.origin.x != sectionInset.left) {
                CGRect frame = currentAttributes.frame;
                frame.origin.x = sectionInset.left;
                currentAttributes.frame = frame;
            }
            [modifiedAttributes addObject:currentAttributes];
            [originYs addObject:@(currentAttributes.frame.origin.y)];
            continue;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentAttributes.indexPath.item-1 inSection:currentAttributes.indexPath.section];
        NSArray *arr = [modifiedAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath = %@", indexPath]];
        UICollectionViewLayoutAttributes *lastAttributes;
        if (arr.count) {
            lastAttributes = [arr firstObject];
        } else {
            lastAttributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
        }
        
        if (CGRectGetMinY(lastAttributes.frame) < CGRectGetMinY(currentAttributes.frame)) {
            // Get section inset.
            UIEdgeInsets sectionInset = [self sectionInsetForSectionAtIndex:lastAttributes.indexPath.section];
            // Get minimum interitem spacing.
            CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingForSectionIndex:lastAttributes.indexPath.section];
            if (CGRectGetWidth(self.collectionView.frame)- sectionInset.right - CGRectGetMaxX(lastAttributes.frame) - minimumInteritemSpacing >= CGRectGetWidth(currentAttributes.frame)) {
                CGRect frame = currentAttributes.frame;
                frame.origin.y = lastAttributes.frame.origin.y;
                frame.origin.x = CGRectGetMaxX(lastAttributes.frame)+minimumInteritemSpacing;
                currentAttributes.frame = frame;
            } else {
                if (currentAttributes.frame.origin.x != sectionInset.left) {
                    CGRect frame = currentAttributes.frame;
                    frame.origin.x = sectionInset.left;
                    currentAttributes.frame = frame;
                }
            }
        } else {
            // Get minimum interitem spacing.
            CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingForSectionIndex:currentAttributes.indexPath.section];
            if (currentAttributes.frame.origin.y == lastAttributes.frame.origin.y) {
                if (currentAttributes.frame.origin.x != CGRectGetMaxX(lastAttributes.frame)+minimumInteritemSpacing) {
                    CGRect frame = currentAttributes.frame;
                    frame.origin.x = CGRectGetMaxX(lastAttributes.frame)+minimumInteritemSpacing;
                    currentAttributes.frame = frame;
                }
            } else {
                // Get section inset.
                UIEdgeInsets sectionInset = [self sectionInsetForSectionAtIndex:currentAttributes.indexPath.section];
                if (currentAttributes.frame.origin.x != sectionInset.left) {
                    CGRect frame = currentAttributes.frame;
                    frame.origin.x = sectionInset.left;
                    currentAttributes.frame = frame;
                }
            }
        }
        [modifiedAttributes addObject:currentAttributes];
        
        [originYs addObject:@(currentAttributes.frame.origin.y)];
    }
    if (_fixsSpace) {
        for (NSNumber *originY in originYs) {
            NSArray<UICollectionViewLayoutAttributes *> *attributes = [modifiedAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                if (evaluatedObject.frame.origin.y == [originY floatValue]) {
                    return YES;
                }
                return NO;
            }]];
            [self fixsSpaceWithAttrobutes:attributes sectionInset:[self sectionInsetForSectionAtIndex:[[attributes firstObject] indexPath].section] minimumInteritemSpacing:[self minimumInteritemSpacingForSectionIndex:[[attributes firstObject] indexPath].section]];
        }
    }
    return modifiedAttributes;
}

#pragma mark - Prive
- (CGFloat)minimumInteritemSpacingForSectionIndex:(NSInteger)section {
    // Get minimum interitem spacing.
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        minimumInteritemSpacing = [((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return minimumInteritemSpacing;
}

- (UIEdgeInsets)sectionInsetForSectionAtIndex:(NSInteger)section {
    // Get section inset.
    UIEdgeInsets sectionInset = self.sectionInset;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInset = [((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return sectionInset;
}

- (void)fixsSpaceWithAttrobutes:(NSArray<UICollectionViewLayoutAttributes *>*)attributes sectionInset:(UIEdgeInsets)sectionInset minimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    if (attributes.count) {
        // Do fixs.
        CGFloat totalWidth = 0;
        for (UICollectionViewLayoutAttributes *att in attributes) {
            totalWidth+=att.frame.size.width;
        }
        CGFloat widthDiff = (CGRectGetWidth(self.collectionView.frame)-sectionInset.left-sectionInset.right-minimumInteritemSpacing*(attributes.count-1)-totalWidth)/attributes.count;
        if (widthDiff == 0) return;
        for (int i = 0; i < attributes.count; i++) {
            if (i == 0) {
                UICollectionViewLayoutAttributes *attribute = attributes[i];
                CGRect frame = attribute.frame;
                frame.size.width += widthDiff;
                attribute.frame = frame;
            } else {
                UICollectionViewLayoutAttributes *lasAttribute = attributes[i-1];
                UICollectionViewLayoutAttributes *attribute = attributes[i];
                CGRect frame = attribute.frame;
                frame.size.width += widthDiff;
                frame.origin.x = CGRectGetMaxX(lasAttribute.frame)+minimumInteritemSpacing;
                attribute.frame = frame;
            }
        }
    }
}
@end

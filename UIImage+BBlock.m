//
//  UIImage+BBlock.m
//  BBlock
//
//  Created by David Keegan on 3/21/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "UIImage+BBlock.h"

@interface UIImage(BBlockPrivate)
+ (NSCache *)drawingCache;
@end

@implementation UIImage(BBlock)

+ (NSCache *)drawingCache{
    static NSCache *cache = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (UIImage *)imageForSize:(CGSize)size withDrawingBlock:(void(^)())drawingBlock{
    if(size.width <= 0 || size.width <= 0){
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    @autoreleasepool{
        drawingBlock();
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#if !__has_feature(objc_arc)
    return [image autorelease];
#else
    return image;
#endif
}

+ (UIImage *)imageWithIdentifier:(NSString *)identifier forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock{
    UIImage *image = [[self drawingCache] objectForKey:identifier];
    if(image == nil){
        image = [self imageForSize:size withDrawingBlock:drawingBlock];
        if(image != nil){
            [[self drawingCache] setObject:image forKey:identifier];
        }
    }
    return image;
}

@end

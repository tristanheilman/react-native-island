#import <Foundation/Foundation.h>
#import <SwiftUI/SwiftUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComponentRenderer : NSObject

+ (instancetype)shared;
- (UIView *)renderComponentWithId:(NSString *)componentId 
                            props:(NSString *)props 
                            frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
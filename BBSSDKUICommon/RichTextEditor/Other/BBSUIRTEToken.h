
#import <Foundation/Foundation.h>

@interface BBSUIRTEToken : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *expression;
@property (nonatomic, strong) NSDictionary *attributes;

+ (instancetype)tokenWithName:(NSString *)name expression:(NSString *)expression attributes:(NSDictionary *)attributes;

@end

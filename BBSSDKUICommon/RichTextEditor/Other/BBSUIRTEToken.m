
#import "BBSUIRTEToken.h"

@implementation BBSUIRTEToken

+ (instancetype)tokenWithName:(NSString *)name expression:(NSString *)expression attributes:(NSDictionary *)attributes
{
    BBSUIRTEToken *textAttribute = [BBSUIRTEToken new];
    
    textAttribute.name = name;
    textAttribute.expression = expression;
    textAttribute.attributes = attributes;
    
    return textAttribute;
}

@end

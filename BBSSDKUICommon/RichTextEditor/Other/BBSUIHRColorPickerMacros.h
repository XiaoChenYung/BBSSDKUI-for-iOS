
#ifndef BBSUIHRColorPickerMacros_h
#define BBSUIHRColorPickerMacros_h

#if !__has_feature(objc_arc_weak)
#define weak    unsafe_unretained
#undef __weak
#define __weak  __unsafe_unretained
#endif

#endif

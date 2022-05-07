#import "StaggeredReorderablePlugin.h"
#if __has_include(<staggered_reorderable/staggered_reorderable-Swift.h>)
#import <staggered_reorderable/staggered_reorderable-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "staggered_reorderable-Swift.h"
#endif

@implementation StaggeredReorderablePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStaggeredReorderablePlugin registerWithRegistrar:registrar];
}
@end

#import "AliplayerPlugin.h"
#if __has_include(<aliplayer_plugin/aliplayer_plugin-Swift.h>)
#import <aliplayer_plugin/aliplayer_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "aliplayer_plugin-Swift.h"
#endif

@implementation AliplayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAliplayerPlugin registerWithRegistrar:registrar];
}
@end

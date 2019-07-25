#import "DaniloconnectivityPlugin.h"
#import <daniloconnectivity/daniloconnectivity-Swift.h>

@implementation DaniloconnectivityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDaniloconnectivityPlugin registerWithRegistrar:registrar];
}
@end

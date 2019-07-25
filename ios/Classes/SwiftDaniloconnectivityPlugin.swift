import Flutter
import UIKit

public class SwiftDaniloconnectivityPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    public static var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftDaniloconnectivityPlugin()

        let channel = FlutterMethodChannel(name: "plugins.flutter.io/connectivity", binaryMessenger: registrar?.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)

        let streamChannel = FlutterEventChannel(name: "plugins.flutter.io/connectivity_status", binaryMessenger: registrar?.messenger())
        streamChannel.streamHandler = instance
    }

    func findNetworkInfo(_ key: String?) -> String? {
        var info: String? = nil
        let interfaceNames = CNCopySupportedInterfaces() as? [Any]
        for interfaceName in interfaceNames ?? [] {
            guard let interfaceName = interfaceName as? String else {
                continue
            }
            let networkInfo = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? [AnyHashable : Any]
            if networkInfo?[key ?? ""] != nil {
                info = networkInfo?[key ?? ""] as? String
            }
        }
        return info
    }

    func getWifiName() -> String? {
        return findNetworkInfo("SSID")
    }

    func getBSSID() -> String? {
        return findNetworkInfo("BSSID")
    }

    func getWifiIP() -> String? {
        var address = "error"
        var interfaces: ifaddrs? = nil
        var temp_addr: ifaddrs? = nil
        var success = 0

        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces)
        if success == 0 {
            // Loop through linked list of interfaces
            temp_addr = interfaces
            while temp_addr != nil {
                if temp_addr.ifa_addr.sa_family == AF_INET {
                    // Check if interface is en0 which is the wifi connection on the iPhone
                    if (String(utf8String: temp_addr.ifa_name) == "en0") {
                        // Get NSString from C String
                        address = String(utf8String: inet_ntoa((temp_addr.ifa_addr as? sockaddr_in)?.sin_addr))
                    }
                }

                temp_addr = temp_addr.ifa_next
            }
        }

        // Free memory
        freeifaddrs(interfaces)

        return address
}


//  Converted to Swift 5 by Swiftify v5.0.7505 - https://objectivec2swift.com/
func status(from reachability: Reachability?) -> String? {

    let status = reachability?.currentReachabilityStatus()
    switch status {
        case NotReachable?:
            return "none"
        case ReachableViaWiFi?:
            return "wifi"
        case ReachableViaWWAN?:
            return "mobile"
        default:
            break
    }
}









//  Converted to Swift 5 by Swiftify v5.0.7505 - https://objectivec2swift.com/
func handle(_ call: FlutterMethodCall?, result: FlutterResult) {
    if (call?.method == "check") {
        // This is supposed to be quick. Another way of doing this would be to
        // signup for network
        // connectivity changes. However that depends on the app being in background
        // and the code
        // gets more involved. So for now, this will do.
        result(status(from: Reachability()))
    } else if (call?.method == "wifiName") {
        result(getWifiName())
    } else if (call?.method == "wifiBSSID") {
        result(getBSSID())
    } else if (call?.method == "wifiIPAddress") {
        result(getWifiIP())
    } else {
        result(FlutterMethodNotImplemented)
    }
}

func onReachabilityDidChange(_ notification: Notification?) {
    let curReach = notification?.object as? Reachability
    eventSink(status(from: curReach))
}


func onListen(withArguments arguments: Any?, eventSink: FlutterEventSink) -> FlutterError? {
    self.eventSink = eventSink
    NotificationCenter.default.addObserver(self, selector: #selector(onReachabilityDidChange(_:)), name: kReachabilityChangedNotification, object: nil)
    Reachability().startNotifier()
    return nil
}

-( as? FlutterError)!
do {
    Reachability().stopNotifier()
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    return nil
}
- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[Reachability reachabilityForInternetConnection] stopNotifier];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}

import Flutter
import UIKit
import Reachability

public class SwiftDaniloconnectivityPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let channel = FlutterMethodChannel(name: "plugins.flutter.io/connectivity", binaryMessenger: registrar.messenger())
        let instance = SwiftDaniloconnectivityPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let messageChannel = FlutterEventChannel(name: "plugins.flutter.io/connectivity_status", binaryMessenger: registrar.messenger())
        messageChannel.setStreamHandler(instance)
        
    }

    /*func findNetworkInfo(_ key: String?) -> String? {
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
    }*/

    /*func getWifiIP() -> String? {
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
        
    }*/

    func status(from reachability: Reachability) -> String? {
        return  reachability.connection.description;
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "check") {
            
            let reachability = Reachability()!
            
            result(status(from: reachability))
        } /*else if (call.method == "wifiName") {
            result(getWifiName())
        } else if (call.method == "wifiBSSID") {
            result(getBSSID())
        } else if (call.method == "wifiIPAddress") {
            result(getWifiIP())
        }*/ else {
            result(FlutterMethodNotImplemented)
        }
    }

    func onReachabilityDidChange(notification: Notification) {
        let curReach = notification.object as! Reachability;
        
        self.eventSink!(status(from: curReach));
    }


    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events;
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReachabilityDidChange(notification:)), name: Notification.Name.reachabilityChanged, object: nil)
        
        let reachability = Reachability()!
        
        try! reachability.startNotifier();
        
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        
        let reachability = Reachability()!
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        self.eventSink = nil
        return nil
    }


}


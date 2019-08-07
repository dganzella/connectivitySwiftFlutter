import Flutter
import UIKit
import Reachability
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

public class SwiftDaniloconnectivityPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    var eventSink : FlutterEventSink?
    var reachability : Reachability?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let channel = FlutterMethodChannel(name: "plugins.flutter.io/connectivity", binaryMessenger: registrar.messenger())
        let instance = SwiftDaniloconnectivityPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let messageChannel = FlutterEventChannel(name: "plugins.flutter.io/connectivity_status", binaryMessenger: registrar.messenger())
        messageChannel.setStreamHandler(instance)
    }
    
    public override init() {
        reachability = Reachability()!
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
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    func status(from reachability: Reachability) -> String? {
        return  reachability.connection.description;
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "check") {
            result(reachability!.connection.description)
        } else if (call.method == "wifiName") {
            result(getWifiName())
        } else if (call.method == "wifiBSSID") {
            result(getBSSID())
        } else if (call.method == "wifiIPAddress") {
            result(getWifiIP())
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    @objc func onReachabilityDidChange(notification: Notification) {
        let curReach = notification.object as! Reachability
        self.eventSink!(curReach.connection.description)
    }
    
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(onReachabilityDidChange(notification:)), name: Notification.Name.reachabilityChanged, object: nil)
        
        do {
            try reachability!.startNotifier()
        } catch let e as NSError {
            print("Reachability error: " + e.localizedDescription)
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        self.eventSink = nil
        return nil
    }
}


import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      
//      let uniqueSpineMechanismrArray = ["Spine","Mechan"]
//      for indexRow in uniqueSpineMechanismrArray{
//          debugPrint("\(indexRow)")
//      }
//      let indexRowThree = uniqueSpineMechanismrArray[5]
//      print("indexRow\(indexRowThree)")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

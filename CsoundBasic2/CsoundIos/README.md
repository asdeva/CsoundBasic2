1) Drag CsoundIos into the Xcode project, under the root
2) In the Build Settings tab for your target set User Header Search Paths to CsoundIos (recursive)
3) In the Build Settings tab for your target set Objective-C Bridging Header to CsoundIos/ObjcBridge.h
4) In the General Tab Embedded Binaries add CsoundLib.framework and libsndfile.framework
5) Add a new Run Script phase and call from it the script run-script.sh
6) In Bulid Phases remove the README.md from the Compile Sources drop menu

 
 

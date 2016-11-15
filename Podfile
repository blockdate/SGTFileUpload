source 'https://github.com/CocoaPods/Specs'
source 'https://bitbucket.org/sgtfundation/specs'

platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

workspace 'SGTFileUpload'
project 'SGTFileUpload.xcodeproj'
 project 'Demo/Demo.xcodeproj'

target 'SGTFileUpload' do
    project 'SGTFileUpload.xcodeproj'
    platform :ios, '8.0'
    pod 'SGTNetworking'
end

  target 'Demo' do
      project 'Demo/Demo.xcodeproj'
      platform :ios, '8.0'
      pod 'SGTNetworking'
      pod 'SGTImageFramework', '~> 0.0.7-debug'
      pod 'AliyunOSSiOS'
  end

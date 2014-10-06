Pod::Spec.new do |s|
  s.name         = "GeoFire"
  s.version      = "1.0.0"
  s.summary      = "Realtime location queries with Firebase."
  s.homepage     = "https://github.com/firebase/geofire-objc"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.source       = { :http => "https://github.com/firebase/geofire-objc/releases/download/v1.0.0/GeoFire.framework.zip" }
  s.source_files = "GeoFire/**/*.{h,m}"
  s.docset_url   = "https://geofire-ios.firebaseapp.com/docs/"
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.dependency  'Firebase'
  s.framework = 'CoreLocation'
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Firebase"'}
end

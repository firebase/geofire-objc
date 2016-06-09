Pod::Spec.new do |s|
  s.name         = "GeoFire"
  s.version      = "2.0.0"
  s.summary      = "Realtime location queries with Firebase."
  s.homepage     = "https://github.com/firebase/geofire-objc"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.source       = { :git => "https://github.com/firebase/geofire-objc.git", :tag => 'v2.0.0' }
  s.source_files = "GeoFire/**/*.{h,m}"
  s.docset_url   = "https://geofire-ios.firebaseapp.com/docs/"
  s.ios.deployment_target = '7.0'
  s.ios.dependency  'Firebase', '~> 3.2'
  s.framework = 'CoreLocation'
  s.requires_arc = true
end

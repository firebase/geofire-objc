Pod::Spec.new do |s|
  s.name         = "GeoFire"
  s.version      = "5.0.0"
  s.summary      = "Realtime location queries with Firebase."
  s.homepage     = "https://github.com/firebase/geofire-objc"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = "Firebase"
  s.source       = { :git => "https://github.com/firebase/geofire-objc.git", :tag => 'v' + s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.default_subspec = 'Database'

  s.subspec 'Database' do |db|
    db.ios.dependency 'Firebase/Database', '> 7.0.0', '< 12.0.0'
    db.ios.dependency 'GeoFire/Utils'
    db.public_header_files = "GeoFire/API/*"
    db.source_files = ["GeoFire/Implementation/*", "GeoFire/API/*"]
    db.frameworks = 'FirebaseDatabase'
  end

  s.subspec 'Utils' do |utils|
    utils.source_files = "GeoFire/Utils/*"
    utils.frameworks = 'CoreLocation'
  end
end

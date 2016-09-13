Pod::Spec.new do |s|
  s.name     = 'SYSegmentedControl'
  s.version  = '1.0'
  s.license  = 'Custom, see Readme.md'
  s.summary  = 'Custom UISegmentedControl'
  s.homepage = 'https://github.com/dvkch/SYSegmentedControl'
  s.author   = { 'Stan Chevallier' => 'contact@stanislaschevallier.fr' }
  s.source   = { :git => 'https://github.com/dvkch/SYSegmentedControl.git', :tag => s.version.to_s }
  s.source_files = 'SYSegmentedControl/SYSegmentedControl.{h,m}'
  s.requires_arc = true

  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target  = '5.0'
  s.tvos.deployment_target = '9.0'
end

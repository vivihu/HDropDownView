Pod::Spec.new do |s|
  s.name         = "HDropDownView"
  s.version      = "1.0.0"
  s.summary      = "下拉筛选框架"
  s.homepage     = "https://github.com/vivihu/HDropDownView"
  s.license      = "MIT"
  s.authors      = { 'vvho' => 'wenzhou.1991@163.com'}
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/vivihu/HDropDownView.git", :tag => s.version }
  s.source_files = 'HDropDownView', 'HDropDownView/**/*.{h,m}'
  s.requires_arc = true
end

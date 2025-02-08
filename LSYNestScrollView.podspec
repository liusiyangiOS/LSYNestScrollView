Pod::Spec.new do |s|

  s.name         = "LSYNestScrollView"
  s.version      = "1.0.0"
  s.summary      = "LSYNestScrollView is a util."

  s.homepage     = "https://github.com/liusiyangiOS/LSYNestScrollView"
  s.license      = "MIT"
  s.author       = { "liusiyangiOS" => "liusiyang_iOS@163.com" }
  
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/liusiyangiOS/LSYNestScrollView.git", :tag => s.version.to_s }
  s.source_files = "LSYNestScrollView/*.{h,m}"
  s.requires_arc = true
    
end

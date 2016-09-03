Pod::Spec.new do |s|

  s.name         = "QiniuUpload"
  s.version      = "2.0.0"
  s.summary      = "支持批量上传的七牛上传sdk，音频、视频、图片都是支持滴"

  s.description  = <<-DESC
                   A longer description of QiniuUpload in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/huhuanming/qiniu_upload"

  s.license      = "MIT"
  
  s.authors = { "huhuanming" => "workboring@gmail.com"}

  s.ios.deployment_target = '7.0'

 # s.osx.deployment_target = '10.9'

  s.source       = { :git => "https://github.com/huhuanming/qiniu_upload.git", :tag => "2.0.0" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.frameworks = 'Foundation', 'UIKit'

  s.requires_arc = true
end

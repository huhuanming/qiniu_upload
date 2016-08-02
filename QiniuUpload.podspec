#
#  Be sure to run `pod spec lint QiniuUpload.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "QiniuUpload"
  s.version      = "1.5.4"
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
<<<<<<< a2057986bebafda10403aa4568d2bb4587e8f14d
  s.osx.deployment_target = '10.9'


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/huhuanming/qiniu_upload.git", :tag => "1.5.4" }

=======
 # s.osx.deployment_target = '10.9'
>>>>>>> add clicks to demo

  s.source       = { :git => "https://github.com/huhuanming/qiniu_upload.git", :tag => "1.5.4" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.frameworks = 'Foundation', 'UIKit'

  s.requires_arc = true

  s.dependency "AFNetworking", ">= 3.0"

end

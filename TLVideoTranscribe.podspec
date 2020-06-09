
Pod::Spec.new do |s|
    s.name         = "TLVideoTranscribe"
    s.version      = "1.0.0"
    s.summary      = "video"
    s.homepage     = "https://github.com/XFCT/TLVideoTranscribe"
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { "xfc" => "1016042696@qq.com" }
    s.platform = :ios
    s.platform = :ios, "13.0"
    s.source       = { :git => "https://github.com/XFCT/TLVideoTranscribe.git", :tag => "1.0.0" }
    s.source_files  = "TLVideoTranscribe/*.{swift}"
    s.frameworks  = "UIKit","Foundation"
    s.requires_arc = true
    
end

Pod::Spec.new do |spec|

  spec.name         = "MediaService"
  spec.version      = "1.0"
  spec.summary      = ""

  spec.homepage     = "https://github.com/rosberry/MediaService"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "Rosberry" => "develop@rosberry.com" }

  spec.swift_version = "5.0"
  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/rosberry/MediaService.git", :tag => "#{spec.version}" }

  spec.source_files  = "MediaService/Sources/*.{swift, h}"

end

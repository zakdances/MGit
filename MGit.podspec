Pod::Spec.new do |s|


  s.name         = "MGit"
  s.version      = "0.0.1"
  s.summary      = "A short description of MGit."

  s.description  = <<-DESC
                   A git-like system for in-memory objects. Objective-C edition.

                   * Ever wanted to version your objects? Well today is your day, my friend.
                   * Rejoice!
                   DESC

  s.homepage     = "https://github.com/zakdances/MGit"

  s.license      = 'MIT'

  s.author       = 'Zak'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'

  s.source       = { :git => "http://EXAMPLE/MGit.git", :tag => "0.0.1" }

  s.source_files  = '*.{h,m}'

  s.ios.framework  = 'AppKit'
  s.osx.frameworks = 'Foundation'

  s.requires_arc = true

end

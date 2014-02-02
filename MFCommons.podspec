Pod::Spec.new do |s|
  s.name         = "MFCommons"
  s.version      = "0.1.6"
  s.summary      = "A short description of MFCommons."

  s.description  = <<-DESC
                   A longer description of MFCommons in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://gitlab.ad.dimension.it:8001/gitlab/ios/mfcommons.git"
  s.license      = 'MIT'
  s.author       = { "Nicolò Tosi" => "nick@mobfarm.eu" }

  s.source       = { :git => "http://gitlab.ad.dimension.it:8001/gitlab/ios/mfcommons.git", :tag => s.version.to_s }

  s.source_files  = 'Classes'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true
end

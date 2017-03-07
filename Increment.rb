begin
    Gem::Specification.find_by_name('plist')
rescue
    puts 'The plist gem is required to use this sync utility.'
    puts 'Install using: `[sudo] gem install plist`'
    exit 0
end

require 'plist'

$currentVersion = 0

$pwd = File.expand_path(File.dirname(__FILE__))

["TLS Inspector/Info.plist", "Inspect Website/Info.plist"].each do |path|
    properties = Plist::parse_xml("#{$pwd}/#{path}")
    $currentVersion = properties["CFBundleVersion"].to_i
    $currentVersion = $currentVersion += 1
    properties["CFBundleVersion"] = $currentVersion.to_s

    File.write("#{$pwd}/#{path}", properties.to_plist)
    `git add "#{path}"`
end
`git commit -m "Increment build to #{$currentVersion}"`

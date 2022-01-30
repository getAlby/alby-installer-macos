require 'json'
require 'open-uri'

release = JSON.parse(URI.open('https://api.github.com/repos/getAlby/alby-companion-rs/releases/latest').read)

puts ""
puts "Downloading latest companion app release:"
puts ""
puts "#{release["tag_name"]} - #{release["name"]}"
puts "draft? #{release["draft"]}"
puts ""

asset = release["assets"].find {|asset|
  !asset['name'].match(/macos\.zip/).nil?
}

url = asset['browser_download_url']

Kernel.system "curl -L -o alby-macos.zip #{url} && unzip alby-macos.zip"

release = JSON.parse(URI.open('https://api.github.com/repos/getAlby/lightning-browser-extension/releases/latest').read)

puts ""
puts "Downloading latest lightning-browser-extension release:"
puts ""
puts "#{release["tag_name"]} - #{release["name"]}"
puts "draft? #{release["draft"]}"
puts ""

asset = release["assets"].find {|asset|
  !asset['name'].match(/chrome/).nil?
}

url = asset['browser_download_url']

Kernel.system "curl -L -o alby-chrome.zip #{url} && unzip alby-chrome.zip -d macExtension/Resources"
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

Kernel.exec "curl -L -o alby-macos.zip #{url} && unzip alby-macos.zip"
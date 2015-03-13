#!/usr/bin/env ruby

require "open-uri"
require "fileutils"

kaigis = ["tokyo01", "sapporo01", "kyushu01", "kansai01", "sendai01", "matsue01", "tochigi01", "hiroshima01", "nagoya01", "tochigi02", "kansai02", "sapporo02", "tokyu01", "matsue02", "tokyo03", "sendai02", "tokyu02", "sapporo03", "kansai03", "tokyo05", "nagoya02", "tochigi03", "oedo01", "tokyu03", "matsue03", "tokyu04", "kansai04", "tochigi04", "sapporo2012", "okayama01", "minato01", "tokyu05", "tokyo10", "matsue04", "oedo03", "fukuoka01", "oedo02", "gunma01", "kyushu02", "tokyu06", "okayama02", "tochigi05", "kansai05", "chuork01", "okrk01", "matsue05", "oedo04", "tokyu07", "tokyu08", "shibuya01"]

redirect_to_external = {
  "kyushu02"=>"http://rubyist-kyushu.doorkeeper.jp/events/3342",
  "oedo02"=>"http://jp.rubyist.net/magazine/?0039-MetPragdaveAtAsakusarb",
  "sapporo2012"=>"http://sapporo.rubykaigi.org/2012",
#  "okrk01"=>"http://regional.rubykaigi.org/okrk01/",
#  "chuork01"=>"http://regional.rubykaigi.org/chuork01",
  "tokyo10"=>"http://tokyo10.rubykaigi.info/",
  "fukuoka01"=>"http://fukuokarb.doorkeeper.jp/events/2049",
  "matsue05"=>"http://matsue.rubyist.net/matrk05/",
#  "tokyu08"=>"http://regional.rubykaigi.org/tokyu08",
#  "shibuya01"=>"http://regional.rubykaigi.org/shibuya01/"
}

only_nginx_redirect_configured = {
  "kana01" => "http://kawasakirb.github.io",
  "oedo04" => "http://oedo04.herokuapp.com",
  "hamamatsu01" => "http://rubykaigi-hamamatsu.s3-website-ap-northeast-1.amazonaws.com"
}

tokyo_mappings = {
  'tokyo02' => 'tokyu01',
  'tokyo04' => 'tokyu02',
  'tokyo06' => 'oedo01',
  'tokyo07' => 'tokyu03',
  'tokyo08' => 'tokyu04',
}.freeze

legacy_kaigis = kaigis - redirect_to_external.keys - only_nginx_redirect_configured.keys

def filter(html)
  html.sub!(%r|<div id='user-bar'>.*?\n</div>\n</div>|m, "")
  html.sub!(%r|<!-- IE 6 hacks -->.*?</script>\n\n|m, "")
  html.sub!(%r|<link href="/stylesheets/simplemodal\.css.*? />|, "")
  html
end

def redirect_to(to)
  %|<html><head><meta http-equiv="refresh" content="0; url=#{to}" /></head><body><p>Redirecting to <a href="#{to}">#{to}</a></body></html>|
end

tokyo_mappings.each do |from, to|
  FileUtils.mkdir_p(from)
  dest_path = File.join(from, "index.html")
  url = "/" + to
  File.write(dest_path, redirect_to(url))
end

redirect_to_external.each do |from, to|
  FileUtils.mkdir_p(from)
  dest_path = File.join(from, "index.html")
  File.write(dest_path, redirect_to(to))
end
exit

index = URI("http://regional.rubykaigi.org/").read
index_filtered = filter(index)
File.write("index.html", index_filtered)

legacy_kaigis.each do |kaigi|
  u = URI("http://regional.rubykaigi.org/#{kaigi}")
  p u

  html = u.read
  filtered = filter(html)

  FileUtils.mkdir_p(kaigi)
  dest_path = File.join(kaigi, "index.html")
  File.write(dest_path, filtered)
end

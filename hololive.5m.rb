#!/usr/bin/env ruby

#
#  <xbar.title>Hololive Xbar Plugin</xbar.title>
#  <xbar.version>v1.0</xbar.version>
#  <xbar.author>Daniils Petrovs</xbar.author>
#  <xbar.author.github>danirukun</xbar.author.github>
#  <xbar.desc>Short description of what your plugin does.</xbar.desc>
#  <xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>
#  <xbar.dependencies>ruby</xbar.dependencies>
#  <xbar.abouturl>http://url-to-about.com/</xbar.abouturl>

# Variables become preferences in the app:
#
#  <xbar.var>string(VAR_NAME="Mat Ryer"): Your name.</xbar.var>
#  <xbar.var>number(VAR_COUNTER=1): A counter.</xbar.var>
#  <xbar.var>boolean(VAR_VERBOSE=true): Whether to be verbose or not.</xbar.var>
#  <xbar.var>select(VAR_STYLE="normal"): Which style to use. [small, normal, big]</xbar.var>

require 'json'
require 'uri'
require 'net/http'
require 'openssl'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

def fetch_airing
  url = URI('https://api.holotools.app/v1/videos?limit=10&status=live&with_comments=0')
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)

  response = http.request(request)
  JSON.parse(response.read_body)['videos']
end

videos = fetch_airing
videos.each { |video| puts video['title'] }

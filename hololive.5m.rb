#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

#
#  <xbar.title>Hololive Xbar Plugin</xbar.title>
#  <xbar.version>v1.0</xbar.version>
#  <xbar.author>Daniils Petrovs</xbar.author>
#  <xbar.author.github>danirukun</xbar.author.github>
#  <xbar.desc>Plugin to quickly see live and upcoming Hololive streams.</xbar.desc>
#  <xbar.dependencies>ruby</xbar.dependencies>
#  <xbar.abouturl>http://url-to-about.com/</xbar.abouturl>
#
#  <xbar.var>number(VAR_COUNTER=1): A counter.</xbar.var>
#  <xbar.var>boolean(VAR_VERBOSE=true): Whether to be verbose or not.</xbar.var>
#  <xbar.var>select(VAR_STYLE="normal"): Which style to use. [small, normal, big]</xbar.var>


    # Hololive xbar plugin.
    # Copyright (C) 2021 Daniils Petrovs
    # https://github.com/DaniruKun

    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <https://www.gnu.org/licenses/>.

require 'json'
require 'uri'
require 'net/http'
require 'openssl'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

IMG_BASE64 = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAJZlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgExAAIAAAARAAAAWodpAAQAAAABAAAAbAAAAAAAAACQAAAAAQAAAJAAAAABd3d3Lmlua3NjYXBlLm9yZwAAAAOgAQADAAAAAQABAACgAgAEAAAAAQAAABigAwAEAAAAAQAAABgAAAAAXjAL1AAAAAlwSFlzAAAWJQAAFiUBSVIk8AAAActpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDYuMC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx4bXA6Q3JlYXRvclRvb2w+d3d3Lmlua3NjYXBlLm9yZzwveG1wOkNyZWF0b3JUb29sPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4K56DsKAAAAVlJREFUSA21ljtOxDAQhsNLVAiEOABUHAEKxCEoKLgGQlyAlpaKC9Cj5VHTUCJOgUAUdIjn9y/50ewGr2KcjPSt7SSePzMeO1tVP7ZMcwYvcA07MAuyGZga9gp+jpj7BR91q/4AtsE2TUdk2xwzzkFO30Ai7/X4lfYUVsGm57MiWmLCDUjAji2mVjzDAehZmQRaR7PIw38JyPEnxLTdMd4DW6u0TRJwBBJS+jy+or9pFVoVRDKiVIrsLLYxheqfwBrYVHENyxGQ2HjaHrh2CAvB80g0uQKpiO4R2A0iv9GUCEgslrXGF7BeCw0jKRVwRBJS+jR+hA1Ir7xuZpreVvtDm3MF9qFTAflr2MhqN+7mXXB65pn2BMea3oWAy9YpusTvFtzaf8kix43XWZn6jV09nW60+Matj4reD7tJAuPp+NdxnVrkeDwXfXB6/2RSrlWvH30J9Pa35RsDtfNl2vuLzQAAAABJRU5ErkJggg=='

def fetch_airing
  url = URI('https://api.holotools.app/v1/videos?limit=20&status=live&with_comments=0')
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)

  response = http.request(request)

  if response.code == '200'
    JSON.parse(response.read_body)['videos']
  else
    puts 'Error: could not fetch videos from Holofans API!'
    []
  end
end

def video_entry_str(video)
  channel_emoji(video['channel']['yt_channel_id']) +
    " #{video['title']} |" \
    " href=https://youtu.be/#{video['yt_video_key']}"
end

def channel_emoji(yt_channel_id)
  channel_emoji = {
    # 0th Generation
    'UCp6993wxpyDPHUpavwDFqgg' => '🐻',
    'UCDqI2jOz0weumE8s7paEk6g' => '🤖',
    'UC-hM6YJuNYVAmUWxeIr9FeA' => '🌸',
    'UC5CwaMl1eIgY8h02uZw7u8A' => '☄️',
    'UC0TXe_LYZ4scaW2XMyi5_kw' => '⚒️',
    # 1st Generation
    'UCD8HOxPs4Xvsm8H0ZxXGiBw' => '🌟',
    'UC1CfXB_kRs3C-zaeTG3oGyg' => '♥️',
    'UCdn5BQ06XqgXoAxIhbqw5Rg' => '🌽',
    'UCQ0UDLQCjY0rmuxCDE38FGg' => '🏮',
    'UCLbtM3JZfRTg8v2KGag-RMw' => '🍎',
    # 2nd Generation
    'UC1opHUrw8rvnsadT-iGp7Cg' => '⚓',
    'UCXTpFs_3PqI41qX2d9tL2Rw' => '🌙',
    'UC7fk0CB07ly8oSl0aqKkqFg' => '😈',
    'UC1suqwovbL1kzsoaZgFZLKg' => '💋',
    'UCvzGlP9oQwU--Y0r9id_jnA' => '🚑',
    # Hololive GAMERS
    'UCp-5t9SrOQwXMU7iIjQfARg' => '🌲',
    'UCvaTdHTWBGv3MKj3KVqJVCw' => '🍙',
    'UChAnqc_AY5_I3Px5dig3X1Q' => '🥐',
    # 3rd Generation
    'UC1DCedRgGHBdm81E1llLhOQ' => '👯',
    'UCl_gCybOJRIgOXw6Qb4qJzQ' => '🦋',
    'UCvInZx9h3jC2JzsIzoOebWg' => '🔥',
    'UCdyqAaZDKHXg4Ahi7VENThQ' => '⚔️',
    'UCCzUftO8KOVkV4wQG1vkUvg' => '🏴‍☠️',
    # 4th Generation
    'UCZlDXzGoo7d44bwdNObFacg' => '💫',
    'UCS9uQI-jC3DE0L4IpXyvr6w' => '🐉',
    'UCqm3BQLlJfvkTsX_hvm0UmA' => '🐏',
    'UC1uv2Oq6kNxgATlCiez59hw' => '👾',
    'UCa9Y57gfeY0Zro_noHRVrnw' => '🍬',
    # 5th Generation
    'UCFKOVgVbGmX65RxO3EtH3iw' => '☃️',
    'UCAWSyEs_Io8MtpY3m-zqILA' => '🥟',
    'UCUKD-uaobj9jiqB-VXt71mA' => '♌',
    'UCK9V2B22uJYu3N7eR_BT9QA' => '🎪',
    # Holostars
    'UC6t3-_N8A6ME1JShZHHqOMw' => '🌺',
    'UCZgOv3YDEs-ZnZWDYVwJdmA' => '🎸',
    'UCKeAhJvy8zgXWbh9duVjIaQ' => '🍕',
    'UC9mf_ZVpouoILRY9NUIaK-w' => '⚙️',
    'UCNVEsYbiZjH5QLmGeSgTSzg' => '🎭',
    'UCGNI4MENvnsymYjKiZwv9eg' => '🦔',
    'UCANDOlYTJT7N5jlRC3zfzVA' => '🍷',
    'UChSvpZYRPh0FvG4SJGSga3g' => '🟣',
    'UCwL7dgTxKo8Y4RFIKWaf8gA' => '🐃',
    # HoloID
    'UCOyYb1c43VlX9rc_lT6NKQw' => '🐿',
    'UCP0BspO_AMEe3aQqqpo89Dg' => '🔮',
    'UCAoy6rzhSf4ydcYjJw3WoVg' => '🎨',
    'UCYz_5n-uDuChHtLo7My1HnQ' => '🧟‍♀️',
    'UC727SQYUvx5pDDGQpTICNWg' => '🍂',
    'UChgTyjG-pdNvxxhdsXfHQ5Q' => '🦚',
    # HololiveEN
    'UCL_qhgtOy0dy1Agp8vkySQg' => '💀',
    'UCHsx4Hqa-1ORjQTh9TYDhww' => '🐔',
    'UCMwGHR0BTZuLsmjY_NT5Pwg' => '🐙',
    'UCoSrY_IQQVpmIRZ9Xf-y93g' => '🔱',
    'UCyl1z3jo3XHR1riLFKG5UAg' => '🔎',
    'UC8rcEBzJSleTkf_-agPM20g' => '💎'
  }

  channel_emoji.fetch(yt_channel_id, '')
end

puts "| size=14 color=#BFBFBF trim=false templateImage=#{IMG_BASE64}"
puts '---'

videos = Array(fetch_airing)

# Output airing streams
puts 'Airing'
puts "Live channels: #{videos.length}"
puts '---'

if videos.length.positive?
  videos.each { |video| puts video_entry_str video }
else
  puts 'No one streaming'
end

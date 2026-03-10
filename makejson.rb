require 'digest/md5'
require 'json'
require 'gyazo'
require 'fileutils'

# S3関連の設定は不要なのでコメントアウト
# S3ROOT = ENV['S3ROOT']
# unless S3ROOT
#   STDERR.puts "S3ROOT not defined"
#   exit
# end
# STDERR.puts "using #{S3ROOT}..."
# 
# # original: "#{S3ROOT}/masui.org"
# ROOT = "#{S3ROOT}/nhiro.org"
# # original: "http://masui.org.s3.amazonaws.com"
# S3URLROOT = "http://nhiro.org.s3.amazonaws.com"

token = ENV['GYAZO_TOKEN']
gyazo = Gyazo::Client.new access_token: token

# usage: makejson PREFIX *.jpg > new.json
jsondata = {}
pages = []
jsondata['pages'] = pages
prefix = ARGV[0]

# JPGとPNGファイルを対象にする
imagefiles = ARGV.grep(/\.(jpg|png)$/i)

(0..imagefiles.length).each { |i|
  file = imagefiles[i]

  data = nil
  begin
    data = File.read(file)
  rescue
  end

  if data
    STDERR.puts file
  
    # S3へのアップロード関連のコードをコメントアウト
    # md5 = Digest::MD5.new.update(data).to_s
    # md5 =~ /^(.)(.)/
    # d1 = $1
    # d2 = $2
    # s3dir = "#{ROOT}/#{d1}/#{d2}"
    # s3path = "#{s3dir}/#{md5}.jpg"
    # FileUtils.mkdir_p(s3dir, :mode => 0755)
    # s3url = "#{S3URLROOT}/#{d1}/#{d2}/#{md5}.jpg"
    # STDERR.puts s3url
    # STDERR.puts s3path
    #
    # unless File.exist?(s3path)
    #   File.write(s3path, data)
    # end

    # Gyazoへの直接アップロードを行う
    res = gyazo.upload imagefile: file
    gyazourl = res[:permalink_url]
    sleep 1

    page = {}
    title_format = '%03d'
    page['title'] = sprintf(title_format, i)
    lines = []
    page['lines'] = lines
    lines << page['title']
    if i == 0
      line1 = "[#{sprintf(title_format, 0)}]  [#{sprintf(title_format, 1)}]"
    elsif i == imagefiles.length - 1
      line1 = "[#{sprintf(title_format, i - 1)}]  [#{sprintf(title_format, i)}]"
    else
      line1 = "[#{sprintf(title_format, i - 1)}]  [#{sprintf(title_format, i + 1)}]"
    end

    # S3 URLは不要なので、Gyazo URLのみを使用
    lines << "[#{gyazourl}]"
    lines << line1
    lines << ""

    pages << page

  end
}

puts jsondata.to_json
#!/usr/bin/env ruby
# encoding: UTF-8
require "sinatra"
require "sinatra/json"
require "json"
require "open3"
require "base64"

set :bind, '0.0.0.0'

class Sinatra::Application
  set :protection, :except => [:http_origin]

  # Retourne la liste des langages disponibles sur la plateforme
  # Return: Json Array
  get '/languages' do
    languages = JSON.parse(IO.read("config_languages.json"))

    array = []
    languages["languages"].each_key do |language|
      array << language
    end

    json :languages => array
  end

  # Executer un code.
  # Params : code, langage
  # Return: Json, stderr et stdout
  post '/execute' do
    json = params

    if json["language"].nil? || json["code"].nil?
      return {"stdout" => "", "stderr" => "Error: Language and/or code variable missing"}.to_json
    end

    if (json["code"] =~ /\A[a-zA-Z\d\/+]+={,2}\z/).nil?
      return {"stdout" => "", "stderr" => "Error: Variable code must be encoded in base64"}.to_json
    end

    language = JSON.parse(IO.read("config_languages.json"))["languages"][json["language"]]
    if language.nil?
      return {"stdout" => "", "stderr" => "Error: language not available"}.to_json
    end
    id = SecureRandom.uuid
    
    begin
      FileUtils.mkdir "tmp/#{id}"
    rescue Exception => e  
      $stderr.puts e.message
      return {"stdout" => "", "stderr" => "Error: Contact the administrator"}.to_json
    end

    File.open("tmp/#{id}/code.#{language["extension"]}", 'wb') {|f| f.write(Base64.decode64(json["code"]))}

    # pour limiter la taille mémoire d'un conteneur -m='128m' 
    cmd = "docker run -rm=true -n=false -v #{Dir.pwd}/tmp/#{id}:/compil/code:rw ubuntu:#{json["language"]} /root/timeout.sh  #{language["timeout"]}"

    stream_stdout, stream_stderr, exit_status = nil
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stream_stderr = stderr.read.to_s
      if stream_stderr.include? "Killed"
        stream_stderr = "Error: timeout after #{language["timeout"]}s"
      else
        stream_stdout = stdout.read.to_s
      end
    end

    system("rm -R tmp/#{id}")

    return {"stdout" => stream_stdout.to_s, "stderr" => stream_stderr.to_s}.to_json
  end
end

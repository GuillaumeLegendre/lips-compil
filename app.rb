require "sinatra"
require "sinatra/json"
require "json"
require 'open3'

set :bind, '0.0.0.0'

class Sinatra::Application
  set :protection, :except => [:http_origin]

  get '/languages' do
    languages = JSON.parse(IO.read("config_languages.json"))

    array = []
    languages["languages"].each_key do |language|
      array << language
    end

    json :languages => array
  end

  post '/execute' do
    json = params
    language = JSON.parse(IO.read("config_languages.json"))["languages"][json["language"]]

    if language.nil?
      #TODO
      puts "ERREUR !!! langage pas dans le fichier de config"
    end
    id = SecureRandom.uuid
    
    system("mkdir tmp/#{id}")
    
    #TODO verif why 2 times json code

    if json["name"]
      code = "echo '#{json["code"]}' > tmp/#{id}/#{json["name"]}.#{language["extension"]}"
    else
      code = "echo '#{json["code"]}' > tmp/#{id}/code.#{language["extension"]}"
    end
    code.sub!("\[code\]", json["code"].gsub(/['"\\\x0]/,'\\\\\0'))
    system(code)

    if json["name"]
      cmd = "docker run -i -n=false -m='128m' -rm=true -v /srv/website/tmp/[hash]:/compil/code:rw ubuntu:#{json["language"]} /root/script.sh"
    else
      cmd = "docker run -n=false -m='128m' -v /srv/website/tmp/[hash]:/compil/code:rw ubuntu:#{json["language"]} /root/script.sh"
    end
    cmd.gsub!("\[hash\]", id)

    if json["name"] && language["stdin"]
      cmd = language["stdin"] + json["name"] + " | " + cmd
    end

    puts cmd.inspect

    stream_stdout, stream_stderr, exit_status = nil
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stream_stdout = stdout.read.to_s
      stream_stderr = stderr.read.to_s
      exit_status = wait_thr.value.exitstatus
    end

    system("rm -R tmp/#{id}")
    
    if exit_status != 0
      # erreur server
    end

    return {"stdout" => stream_stdout.to_s, "stderr" => stream_stderr.to_s}.to_json
  end

  error 404 do
    'Not Found'
  end
end

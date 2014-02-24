require "sinatra"
require "sinatra/json"
require "json"
require "open3"
require "base64"

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

    if json["language"].nil? || json["code"].nil?
      return {"stdout" => "", "stderr" => "Error: Language and/or code variable missing"}.to_json
    end

    language = JSON.parse(IO.read("config_languages.json"))["languages"][json["language"]]
    if language.nil?
      return {"stdout" => "", "stderr" => "Error: language not available"}.to_json
    end
    id = SecureRandom.uuid
    
    begin
      FileUtils.mkdir "tmp/#{id}"
    rescue
      return {"stdout" => "", "stderr" => "Error: Contact the administrator"}.to_json
    end

    File.open("tmp/#{id}/code.#{language["extension"]}", 'wb') {|f| f.write(Base64.decode64(json["code"])) }

    #-rm=true -n=false -m='128m'
    cmd = "docker run -v /srv/website/tmp/#{id}:/compil/code:rw ubuntu:#{json["language"]} timeout -k #{language["timeout"]} -s 9 #{language["timeout"]} /root/script.sh"
    puts cmd.inspect

    stream_stdout, stream_stderr, exit_status = nil
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      exit_status = wait_thr.value.exitstatus
      if(exit_status == 124)
        stream_stderr = "Error: timeout after #{language["timeout"]}s"
      else
        stream_stdout = stdout.read.to_s
        stream_stderr = stderr.read.to_s
      end
    end

    # system("rm -R tmp/#{id}")

    if exit_status != 0
      # erreur server
    end

    return {"stdout" => stream_stdout.to_s, "stderr" => stream_stderr.to_s}.to_json
  end
end

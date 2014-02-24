class utils

  def init language, script
    return "docker run ubuntu:#{language} #{script}"
  end

  def rm_container cmd
    cmd.split "run"
  end

  def network cmd, status

  end

  def memory_limit cmd, limit

  end

  def timeout cmd, timeout

  end

  def common_folder cmd, folder_host, folder_vm, id

  end

end
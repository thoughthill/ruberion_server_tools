
def clean_up
  File.move("tmp",".tmp.bak")
  File.move("config/database.yml", "config/database.yml.bak")
  File.move("config/ultrasphinx", "config/ultrasphinx.bak")
end

def restore
  File.move(".tmp.bak", "tmp")
  File.move("config/database.yml.bak", "config/database.yml")
  File.move("config/ultrasphinx.bak", "config/ultrasphinx")
end

def backup_file(file)
  if File.exist?(file)
    File.move(file, file+"__.bak" )
  end
end

def restore_file(file)
  if File.exist?(file)
    File.delete(file)
    File.move(file+"__.bak", file)
  end
end

def remove_file(file)
  if File.exist?(file)
    FileUtils.rm_rf(file)
  end
end

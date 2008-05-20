
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
    system("mv #{file} #{file}__.bak")
  end
end

def restore_file(file)
  if File.exist?(file+"__.bak")
    system("mv #{file}__.bak #{file}")
  end
end

def remove_file(file)
  if File.exist?(file)
    system("rm -rf #{file}")
  end
end

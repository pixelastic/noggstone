require 'json'
require 'fileutils'

module HearthstoneHelper
  __scriptDir = File.expand_path(File.dirname(__FILE__))
  __rootDir = File.expand_path(File.join(__scriptDir, '..'))
  __configFile = File.join(__rootDir, 'config.json')
  # Load generic config
  @@config = JSON.parse(File.read(__configFile))
  @@config['appPath'] = File.join(__rootDir, 'app')
  @@config['tmpPath'] = File.join(__rootDir, 'tmp')

  # Full path to a file in the data root dir
  def data_path(path)
    return File.expand_path(File.join(@@config['dataPath'], path))
  end
  
  # Full path to a file in the tmp dir
  def tmp_path(path)
    return File.expand_path(File.join(@@config['tmpPath'], path))
  end
  
  # Full path to a file in the app dir
  def app_path(path)
    return File.expand_path(File.join(@@config['appPath'], path))
  end

  # Extract a unity3d file in its own directory
  def disunity_extract(src: nil)
  end

  # Extract a file from a unity3d file to our tmp directory.
  def import_from_unity(filename: nil, inner_path: nil, dest: nil)
    dest = tmp_path(dest)
    tmp_name = tmp_path(filename)
    # Copy the unity3d file into our tmp directory
    FileUtils.mkdir_p(File.dirname(tmp_name))
    FileUtils.cp(data_path(filename), tmp_name)

    # Extract it
    disunity_jar = File.expand_path(File.join(@@config['disunityPath'], 'disunity.jar'))
    %x[java -jar #{disunity_jar} extract #{tmp_name}]

    # Copy only the matching files to dest
    subdirectory = File.basename(filename, File.extname(filename))
    glob = File.join(tmp_path(subdirectory), inner_path)

    # Creating destination directory
    if File.extname(dest) == ""
      FileUtils.mkdir_p(dest)
      FileUtils.copy(Dir[glob], dest)
    else
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.copy(Dir[glob][0], dest)
    end
  end
end

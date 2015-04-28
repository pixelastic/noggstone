require 'json'
require 'fileutils'
require 'digest/sha1'

module HearthstoneHelper
  # Load generic config
  @@config = JSON.parse(File.read('../config.json'))

  # Most of the work will consist in extracting and converting files from the
  # HearthStone directory to our ./dist directory. As we do not want to mess
  # with the install files, we'll copy them to ./tmp and operate on them. Our
  # ./tmp directory will mostly work as caching directory. If the cached
  # version is the same as the one in the root directory, we'll use the cached
  # one, otherwise, we'll copy a fresh version from the root.
  @@config['distPath'] = File.expand_path('../dist')
  @@config['tmpPath'] = File.expand_path('../tmp')

  # Full path to a file in the data root dir
  def data_path(path)
    return File.expand_path(File.join(@@config['rootPath'], @@config['dataPath'], path))
  end
  
  # Full path to a file in the tmp dir
  def tmp_path(path)
    return File.expand_path(File.join(@@config['tmpPath'], path))
  end

  def files_equal?(file1, file2)
    return false if !File.exists?(file1) || !File.exists?(file2)
    Digest::SHA1.file(file1).hexdigest == Digest::SHA1.file(file2).hexdigest
  end

  # Import a file from the HearthStone directory to our local tmp directory.
  def import_from_root(src: nil, dest: nil)
    dest = src if !dest

    src = data_path(src)
    dest = tmp_path(dest)

    FileUtils.copy(src, dest)
  end

  # Extract a unity3d file in its own directory
  def disunity_extract(src: nil)
    disunity_jar = File.expand_path(File.join(@@config['disunityPath'], 'disunity.jar'))
    src = tmp_path(src)
    %x[java -jar #{disunity_jar} extract #{src}]
  end

  # Extract a file from a unity3d file to our tmp directory.
  def import_from_unity(src: nil, inner_path: nil, dest: nil)
    dest = File.expand_path(tmp_path(dest))
    # If the unity3d file in tmp is the same as in root, no need to extract
    # anything
    # if files_equal?(data_path(src), tmp_path(src))
    #   puts "✘ #{src} already in ./tmp, skipping"
    #   return
    # end


    # Extract all the content
    disunity_extract(:src => src)

    # Getting only files matching the glob pattern
    basename = File.basename(src, File.extname(src))
    glob = File.join(@@config['tmpPath'], basename, inner_path)
    p glob
    files = Dir[glob]
    puts files

    if files.size == 1
      FileUtils.mv(files[0], dest)
    else
      FileUtils.mkdir_p(dest)
      files.each do |file|
        FileUtils.mv(file, dest)
      end
    end
  end
end

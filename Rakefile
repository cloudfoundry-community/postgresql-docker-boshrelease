require 'yaml'
require 'fileutils'

namespace :jobs do
  desc "Update job specs"
  task :update_specs do
    include JobSpecs
    update_job_specs
  end
end

namespace :images do
  desc "Export docker images locally; in Concourse get them via resources"
  task :pull, [:image] do |_, args|
    include ImageConfig

    images(args[:image]).each do |image|
      sh "docker pull #{image.name}"
      sh "docker save #{image.name} > #{tmp_dir(image.tar)}"
    end
  end

  desc "Package exported images"
  task :package, [:image] do |_, args|
    include DockerImagePackaging
    include ImageConfig

    images(args[:image]).each do |image|
      Dir.mktmpdir do |dir|
        repackage_image_blobs(tmp_dir(image.tar), dir).tap do |blobs|
          blobs.each { |b| sh "bosh add blob #{b.target(dir)} #{b.prefix}" }
          create_package(image.package, blobs.map(&:path))
        end
      end
    end
  end
end

module CommonDirs
  def repo_dir
    File.expand_path("../", __FILE__)
  end

  def tmp_dir(path = "")
    File.join(repo_dir, 'tmp', path)
  end

  def packages_dir(path = "")
    File.join(repo_dir, 'packages', path)
  end

  def jobs_dir(path = "")
    File.join(repo_dir, 'jobs', path)
  end
end

module JobSpecs
  include CommonDirs

  def image_packages
    Dir.chdir(packages_dir) { Dir.glob("*_image") }
  end

  def update_job_specs
    Dir["#{jobs_dir}*/spec"].map do |file|
      spec = YAML.load_file(file)
      spec["packages"].concat(image_packages).uniq!
      IO.write(file, spec.to_yaml)
      puts "Updated: #{file}"
    end
  end
end

module ImageConfig
  include CommonDirs

  def images(image = nil)
    @images ||= begin
      images = YAML.load_file(File.expand_path('../images.yml', __FILE__))
      images.keep_if { |i| i['image'].to_s == image } if image
      images.map! { |i| Image.new(i["image"], i["tag"]) }
    end
  end

  class Image
    def initialize(name, tag)
      @name = name
      @tag = tag
    end

    def name
      @name + ":" + @tag
    end

    def package
      name.gsub(/[\/\-\:\.]/, '_') + "_image"
    end

    # file that matches output from concourse docker-image-resource
    def tar
      "#{package}/image"
    end
  end
end

module DockerImagePackaging
  include CommonDirs

  PREFIXES = %w(docker_layers docker_images)

  class Blob
    attr_reader :source, :target, :prefix
    def initialize(source, target, prefix)
      @source = source
      @target = target.sub('.tgz', '') + '.tgz'
      @prefix = prefix
    end

    def target(dir = nil)
      dir ? File.join(dir, @target) : @target
    end

    def path
      "#{@prefix}/#{@target}"
    end
  end

  def repackage_image_blobs(image_tar, target_dir)
    Dir.chdir(target_dir) do
      sh "tar -xf #{image_tar}"

      blobs = Dir.glob("*/").map! { |d| Blob.new(d.chop, d.chop, PREFIXES[0]) }
      blobs << Blob.new('repositories', File.basename(image_tar), PREFIXES[1])

      package_blobs(blobs)
    end
  end

  def package_blobs(blobs)
    blobs.each { |b| sh "tar -zcf #{b.target} #{b.source}" }
  end

  def create_package(name, files)
    package_dir = File.expand_path("../packages/#{name}", __FILE__)
    FileUtils.mkdir_p package_dir
    spec = { "name" => name, "files" => files }
    IO.write(File.join(package_dir, 'spec'), spec.to_yaml)
    IO.write(File.join(package_dir, 'packaging'), packaging_script)
  end

  def packaging_script
    <<-END.gsub(/^ {6}/, '')
      set -e; set -u
      cd docker_layers
      for layer in *.tgz; do tar -xf "$layer"; rm "$layer"; done
      tar -xf ../docker_images/*.tgz
      tar -zcf image.tgz ./*
      cp -a image.tgz $BOSH_INSTALL_TARGET
    END
  end
end

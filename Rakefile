require 'yaml'
require 'fileutils'
require 'tmpdir'

DOCKER_IMAGES_JOB = "postgresql_images"

namespace :jobs do
  desc "Update #{DOCKER_IMAGES_JOB} job spec"
  task :update_spec do
    include JobSpecs
    update_job_spec
  end
end

namespace :images do
  desc "Export docker images locally; in Concourse get them via resources"
  task :pull, [:image] do |_, args|
    include ImageConfig

    images(args[:image]).each do |image|
      sh "docker pull #{image.name}" if ENV["DOCKER_PULL"]
      FileUtils.mkdir_p(source_image_dir(File.dirname(image.tar)))
      sh "docker save #{image.name} > #{source_image_dir(image.tar)}"
    end
  end

  desc "Package exported images"
  task :package, [:image] do |_, args|
    include DockerImagePackaging
    include ImageConfig

    images(args[:image]).each do |image|
      Dir.mktmpdir do |dir|
        repackage_image_blobs(source_image_dir(image.tar), dir).tap do |blobs|
          blobs.each { |b| sh "bosh add blob #{b.blob_target(dir)} #{b.prefix}" }
          create_package(image.package, blobs.map(&:package_spec_path))
        end
      end
    end
  end

  task :cleanout do
    FileUtils.rm_rf("blobs/docker_images")
    FileUtils.rm_rf("blobs/docker_layers")
    file = "config/blobs.yml"
    blobs = YAML.load_file(file)
    blobs = blobs.keep_if { |blob, _| !(blob =~ /^(docker_layers|docker_images)/) }
    IO.write(file, blobs.to_yaml)
  end
end

module CommonDirs
  def repo_dir
    File.expand_path("../", __FILE__)
  end

  def source_image_dir(relative_path = "")
    image_base_dir = ENV['IMAGE_BASE_DIR'] || File.join(repo_dir, 'tmp')
    File.join(image_base_dir, relative_path)
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

  def update_job_spec
    file = "jobs/#{DOCKER_IMAGES_JOB}/spec"
    spec = YAML.load_file(file)
    spec["packages"] = image_packages
    IO.write(file, spec.to_yaml)
    puts "Updated: #{file}"
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

  class Blob
    attr_reader :source, :target_dir, :prefix

    # target_dir is a folder akin to output from concourse/docker-image-resource
    # with an +image+ file that is the `docker save` tgz file (see +source_blob+)
    def initialize(source, target_name, prefix)
      @source = source
      @target_name = target_name
      @prefix = prefix
    end

    def target
      "#{@target_name}.tgz"
    end

    def blob_target(dir)
      File.join(dir, target)
    end

    def package_spec_path
      "#{@prefix}/#{target}"
    end
  end

  def repackage_image_blobs(image_tar, tmp_layers_dir)
    Dir.chdir(tmp_layers_dir) do
      sh "tar -xf #{image_tar}"

      blobs = Dir.glob("*/").map! do |d|
               Blob.new(d.chop, d.chop, 'docker_layers')
      end
      blobs << Blob.new('repositories', File.basename(File.dirname(image_tar)), 'docker_images')

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

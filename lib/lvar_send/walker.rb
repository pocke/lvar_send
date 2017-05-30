require 'find'

module LvarSend
  module Walker
    Extensions = %w[
      .rb .builder .fcgi .gemspec .god .jbuilder .jb .mspec .opal .pluginspec
      .podspec .rabl .rake .rbuild .rbw .rbx .ru .ruby .spec .thor .watchr
    ].freeze
    BaseNames = %w[
      .irbrc .pryrc buildfile Appraisals Berksfile Brewfile Buildfile Capfile
      Cheffile Dangerfile Deliverfile Fastfile Gemfile Guardfile Jarfile Mavenfile
      Podfile Puppetfile Rakefile Snapfile Thorfile Vagabondfile Vagrantfile
    ].freeze

    def self.walk(root_dir, &block)
      Find.find(root_dir) do |path|
        if Extensions.include?(File.extname(path)) || BaseNames.include?(File.baesname(path))
          block.call(path)
        end
      end
    end
  end
end

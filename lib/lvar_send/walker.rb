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

    # TODO: it is not a walker
    def self.ruby_file?(path)
      Extensions.include?(File.extname(path)) ||
        BaseNames.include?(File.basename(path))
    end
  end
end

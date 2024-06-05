# frozen_string_literal: true

module Bundler
  class CLI::Fund
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def run
      Bundler.definition.validate_runtime!

      groups = Array(options[:group]).map(&:to_sym)

      fund_info = requested_dependencies_for(groups).each_with_object([]) do |dep, arr|
        spec = Bundler.definition.specs[dep.name].first
        if spec.metadata.key?("funding_uri")
          arr << "* #{spec.name} (#{spec.version})\n  Funding: #{spec.metadata["funding_uri"]}"
        end
      end

      if fund_info.empty?
        Bundler.ui.info "None of the installed gems you directly depend on are looking for funding."
      else
        Bundler.ui.info fund_info.join("\n")
      end
    end

    private

    def requested_dependencies_for(groups)
      dependencies = Bundler.definition.requested_dependencies
      return dependencies if groups.empty?

      dependencies.select! do |dependency|
        if RUBY_VERSION >= "3.1"
          dependency.groups.intersect?(groups)
        else
          !(dependency.groups & groups).empty?
        end
      end
    end
  end
end

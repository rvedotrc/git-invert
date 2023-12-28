# frozen_string_literal: true

module GitInvert
  class RefReader
    Ref = Data.define(:commit, :ref)

    def self.each_ref(git_dir:, **, &)
      new(git_dir:).each_ref(**, &)
    end

    def initialize(git_dir:)
      @git_dir = git_dir
    end

    attr_reader :git_dir

    def each_ref(args:, &block)
      return enum_for(:each_ref, args:, &block) unless block_given?

      require 'open3'
      o, s = Open3.capture2(
        "git",
        "--git-dir", git_dir,
        "show-ref",
        *args,
        stdin_data: "",
      )
      s.success? or abort

      o.each_line do |line|
        commit, ref = line.chomp.split(" ")
        yield Ref.new(commit:, ref:)
      end
    end
  end
end

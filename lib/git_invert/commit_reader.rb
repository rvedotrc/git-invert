# frozen_string_literal: true

module GitInvert
  class CommitReader
    def self.each_commit(git_dir:, **, &)
      new(git_dir:).each_commit(**, &)
    end

    def initialize(git_dir:)
      @git_dir = git_dir
    end

    attr_reader :git_dir

    def each_commit(revisions:, &block)
      return enum_for(:each_commit, revisions:, &block) unless block_given?

      format = FIELDS.map { |f| "%#{f}" }.join("%n")

      require 'open3'
      Open3.popen2(
        "git",
        "--git-dir", git_dir,
        "rev-list",
        ("--all" if revisions.nil?),
        "--no-commit-header",
        "--pretty=format:#{format}%x00",
        '--',
        *(revisions || []),
        ) do |i, o, t|
        i.close

        o.each_line("\0\n") do |l|
          l.sub!(/^commit /, '')
          l.sub!(/\x00\n\z/, '')

          values = l.split("\n", FIELDS.length)
          hash = FIELDS.map(&:to_sym).zip(values).to_h

          c = CommitData.new(**hash)
          yield c
        end
      end
    end
  end
end

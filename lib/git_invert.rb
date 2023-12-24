# frozen_string_literal: true

class GitInvert
  FIELDS = %w[ H T P at an ae ct cn ce B ].freeze
  CommitData = Data.define(*FIELDS.map(&:to_sym)) do
    alias_method :commit, :H
    alias_method :tree, :T
    alias_method :author_name, :an
    alias_method :author_email, :ae
    alias_method :committer_name, :cn
    alias_method :committer_email, :ce
    alias_method :message, :B

    def parents
      self.P.split(' ')
    end

    def author_time
      self.at.to_i
    end

    def committer_time
      self.ct.to_i
    end
  end

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

# frozen_string_literal: true

require 'open3'

module GitInvert
  class CommitCreator
    def initialize(git_dir:)
      @git_dir = git_dir
    end

    attr_reader :git_dir

    def create_commit(commit:, new_parents:)
      env = {
        GIT_AUTHOR_DATE: commit.author_time.to_s,
        GIT_AUTHOR_NAME: commit.author_name,
        GIT_AUTHOR_EMAIL: commit.author_email,
        GIT_COMMITTER_DATE: commit.committer_time.to_s,
        GIT_COMMITTER_NAME: commit.committer_name,
        GIT_COMMITTER_EMAIL: commit.committer_email,
      }.transform_keys(&:to_s)

      args = [
        env,
        "git",
        "--git-dir", git_dir,
        "commit-tree",
        *new_parents.flat_map { |new_parent| ["-p", new_parent] },
        commit.tree,
        stdin_data: commit.message,
      ]

      o, s = Open3.capture2(*args)
      raise unless s.success?

      o.chomp
    end

    def create_tail(new_parents:)
      args = [
        "git",
        "--git-dir", git_dir,
        "commit-tree",
        *new_parents.flat_map { |new_parent| ["-p", new_parent] },
        empty_tree,
        stdin_data: "TAIL created by git-invert\n",
      ]

      o, s = Open3.capture2(*args)
      raise unless s.success?

      o.chomp
    end

    def empty_tree
      o, s = Open3.capture2(
        "git",
        "--git-dir", git_dir,
        "mktree",
        stdin_data: "",
      )
      raise unless s.success?

      o.chomp
    end
  end
end

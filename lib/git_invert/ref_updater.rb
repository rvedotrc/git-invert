# frozen_string_literal: true

module GitInvert
  class RefUpdater
    def initialize(git_dir:)
      @git_dir = git_dir
    end

    attr_reader :git_dir

    def update(old_to_new:, tail_commit:)
      commands = GitInvert::RefReader.each_ref(
        git_dir:,
        args: ["--heads", "--tags"]
      ).map do |ref|
        new_commit = old_to_new.fetch(ref.commit)
        "update #{ref.ref} #{new_commit} #{ref.commit}\n"
      end

      commands = [
        "start\n",
        *commands,
        "update refs/heads/TAIL #{tail_commit}\n",
        "prepare\n",
        "commit\n"
      ]

      o, s = Open3.capture2(
        "git",
        "--git-dir", git_dir,
        "update-ref",
        "--stdin",
        stdin_data: commands.join,
        )
      s.success? or abort
    end
  end
end

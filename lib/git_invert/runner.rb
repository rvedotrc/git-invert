# frozen_string_literal: true

module GitInvert
  class Runner
    def run(argv:)
      git_dir = `git rev-parse --absolute-git-dir`.chomp

      commits = GitInvert::CommitReader.each_commit(git_dir:, revisions: nil)
      creator = GitInvert::CommitCreator.new(git_dir:)
      result = GitInvert::Inverter.new(commits:).invert(&creator.method(:create_commit))

      old_to_new = result.fetch(:old_to_new)
      tail_commit = creator.create_tail(new_parents: result.fetch(:new_tips))
      puts tail_commit

      GitInvert::RefUpdater.new(git_dir:).update(old_to_new:, tail_commit:)

      if `git rev-parse --is-inside-work-tree`.chomp == 'true'
        system "git checkout TAIL"
      end
    end
  end
end

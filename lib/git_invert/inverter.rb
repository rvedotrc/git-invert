# frozen_string_literal: true

require_relative 'commit_data'

module GitInvert
  class Inverter
    def initialize(commits:)
      @commits = [*commits].freeze
    end

    attr_reader :commits

    def invert
      children = Hash.new do |h, k|
        h[k] = []
      end

      commits.each do |commit|
        commit.parents.each do |parent|
          children[parent] << commit.commit
        end
      end

      # C's parent is B
      # B*'s parent is C*
      # A -> B -> C

      roots = commits.select { |c| c.parents.empty? }.map(&:commit)

      tips = commits.map(&:commit).select do |c|
        children[c].empty?
      end

      queue = [*tips]
      commits_by_sha = commits.to_h { |c| [c.commit, c] }
      old_to_new = {}

      while !queue.empty?
        sha = queue.shift
        next if old_to_new.key?(sha)

        ch = children[sha]
        new_ch = ch.map { |sha| old_to_new.fetch(sha, nil) }
        next if new_ch.any?(&:nil?)

        commit = commits_by_sha.fetch(sha)
        new_sha = yield commit:, new_parents: new_ch
        old_to_new[sha] = new_sha

        queue.unshift(*commit.parents)
      end

      abort if commits.size != old_to_new.size

      { old_to_new:, new_tips: roots.map(&old_to_new.method(:fetch)) }
    end
  end
end

# frozen_string_literal: true

module GitInvert
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
end

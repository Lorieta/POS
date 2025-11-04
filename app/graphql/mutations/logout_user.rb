# frozen_string_literal: true

module Mutations
  class LogoutUser < BaseMutation
    field :success, Boolean, null: false

    def resolve
      # The frontend simply discards its token. This mutation exists for symmetry
      # and can be extended later (e.g., token blacklisting).
      { success: true }
    end
  end
end

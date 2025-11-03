# frozen_string_literal: true

module Mutations
  # Use non-Relay mutation base so mutations accept named arguments directly
  # (e.g. `createUser(credentials: ...)`) instead of a single `input` arg.
  class BaseMutation < GraphQL::Schema::Mutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    # `input_object_class` and `object_class` are Relay-specific helpers
    # and not available on non-Relay Mutation base. If you need custom
    # behavior for input objects or result objects, configure them on
    # the types themselves instead.
  end
end

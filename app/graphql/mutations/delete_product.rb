module Mutations
  class DeleteProduct < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: true

    def resolve(id:)
      product = Product.find_by(id: id)

      if product.nil?
        return { success: false, errors: ["Product not found"] }
      end

      begin
        if product.destroy
          { success: true, errors: [] }
        else
          { success: false, errors: product.errors.full_messages }
        end
      rescue ActiveRecord::DeleteRestrictionError => e
        { success: false, errors: ["Cannot delete product because it has associated orders or deliveries."] }
      end
    end
  end
end

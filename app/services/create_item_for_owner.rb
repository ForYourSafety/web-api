# frozen_string_literal: true

module LostNFound
  # Create an new item for an owner
  class CreateItemForOwner
    # Custom error class for owner not found
    class OwnerNotFoundError < StandardError
      def message = 'Owner not found'
    end

    def self.call(owner_id:, item_data:)
      owner = Account.first(id: owner_id)
      raise(OwnerNotFoundError) unless owner

      item_data = item_data.clone
      item_data['type'] = item_data['type'].to_sym # Convert string to enum
      owner.add_item(item_data)
    end
  end
end

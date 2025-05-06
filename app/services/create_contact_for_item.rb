# frozen_string_literal: true

module LostNFound
  # Create a new contact for an item
  class CreateContactForItem
    # Custom error class for item not found
    class ItemNotFoundError < StandardError
      def message = 'Item not found'
    end

    def self.call(item_id:, contact_data:)
      item = Item.first(id: item_id)
      raise(ItemNotFoundError) unless item

      new_data = contact_data.transform_keys(&:to_sym)
      # safely convert contact_type to symbol if it's a string
      new_data[:contact_type] = new_data[:contact_type].to_sym if new_data[:contact_type].is_a?(String)
      item.add_contact(new_data)
    end
  end
end

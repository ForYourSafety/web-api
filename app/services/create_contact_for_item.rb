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

      contact_data = contact_data.clone
      contact_data['contact_type'] = contact_data['contact_type'].to_sym # Convert string to enum
      item.add_contact(contact_data)
    end
  end
end

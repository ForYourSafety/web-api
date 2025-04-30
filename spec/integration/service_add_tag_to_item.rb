# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddTagToItem service' do
  before do
    account_data = DATA[:accounts].first.clone
    @account = LostNFound::Account.create(account_data)

    item_data = DATA[:items][1].clone
    item_data['type'] = item_data['type'].to_sym
    item_data['created_by'] = @account.id
    LostNFound::Item.create(item_data).save_changes
    @item = LostNFound::Item.first

    tag_data = DATA[:tags].first.clone
    @tag_name = LostNFound::Tag.create(tag_data)

    it 'HAPPY: should be able to add a tag to an item' do
      LostNFound::AddTagToItem.call(item_id: @item.id, tag_name: @tag_name)

      _(@item.tags.count).must_equal 1
      _(@item.tags.first.name).must_equal @tag_name
    end

    it 'HAPPY: should reuse existing tag if already exists' do
      LostNFound::Tag.create(name: @tag_name)

      LostNFound::AddTagToItem.call(item_id: @item.id, tag_name: @tag_name)

      _(LostNFound::Tag.where(name: @tag_name).count).must_equal 1
      _(@item.tags.first.name).must_equal @tag_name
    end
  end
end

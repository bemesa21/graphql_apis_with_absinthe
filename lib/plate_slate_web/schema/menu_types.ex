defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field :name, :string
    @desc "Matching a category name"
    field :category, :string
    @desc "Matching a tag"
    field :tag, :string
    @desc "Priced above a value"
    field :priced_above, :float
    @desc "Priced below a value"
    field :priced_below, :float
    @desc "Added to the meenu before this date"
    field :added_before, :date
    @desc "Added to the menu after this date"
    field :added_after, :date
  end

  @desc "menu item is the object that contains the info of the food?"
  object :menu_item do
    field :id, :id
    field :name, :string
    @desc "The description of the menu item"
    field :description, :string
    @desc "The price of the menu item"
    field :price, :float
    @desc "The date where the item is added"
    field :added_on, :date
  end

end
#---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
#---
defmodule PlateSlateWeb.Schema do
  alias PlateSlate.{Menu, Repo}
  alias PlateSlateWeb.Resolvers

  use Absinthe.Schema
  import Ecto.Query


  enum :sort_order do
    value :asc
    value :desc
  end

  query do
    @desc "The list of the available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg :matching, :string
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end
  end

  @desc "menu item is the object that contains the info of the food?"
  object :menu_item do
    field :id, :id
    field :name, :string
    @desc "The description of the menu item"
    field :description, :string
    @desc "The price of the menu item"
    field :price, :float
  end
end

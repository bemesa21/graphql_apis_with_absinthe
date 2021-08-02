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
  import_types __MODULE__.MenuTypes

  enum :sort_order do
    value :asc
    value :desc
  end

  query do
    @desc "The list of the available items on the menu"
    field :menu_items, list_of(:menu_item) do
      #arg :filter, non_null(:menu_item_filter) we can set as non_null the args
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end
  end

  #scalar macro to build our own scalar types
  scalar :date do
    #from user to elixir term
    parse fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
      {:ok, date} <- Date.from_iso8601(input.value) do
          {:ok, date}
      else
        _ -> :error
      end
    end
    #from elixir term to a value that can be returnet via JSON
    serialize fn date ->
      Date.to_iso8601(date)
    end
  end
end

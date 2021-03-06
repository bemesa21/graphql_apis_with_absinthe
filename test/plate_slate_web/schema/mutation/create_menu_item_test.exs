defmodule PlateSlateWeb.Schema.Mutation.CreateMenuTest do
  use PlateSlateWeb.ConnCase, async: true
  alias PlateSlate.{Repo, Menu}
  import Ecto.Query

  @query """
  mutation ($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      errors { key message }
      menuItem {
        name
        description
        price
      }
    }
  }
  """

  setup do
    PlateSlate.Seeds.run()
    category_id =
    from(t in Menu.Category, where: t.name == "Sandwiches")
    |> Repo.one!
    |> Map.fetch!(:id)
    |> to_string

    {:ok, category_id: category_id}
  end


  test "createMenuItem field creates an item", %{category_id: category_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }
    conn = build_conn()
    conn = post conn, "/api", query: @query, variables: %{"menuItem" => menu_item}

    assert json_response(conn, 200) == %{
      "data" => %{
        "createMenuItem" => %{
          "errors" => nil,
          "menuItem" => %{
            "name" => menu_item["name"],
            "description" => menu_item["description"],
            "price" => menu_item["price"]
          }
        }
      }
    }
  end

  test "creating a menu item with an existing name fails", %{category_id: category_id} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id,
    }

    conn = build_conn()

    conn = post conn, "/api", query: @query, variables: %{"menuItem" => menu_item}
    assert json_response(conn, 200) == %{
      "data" => %{
        "createMenuItem" => %{
          "menuItem" => nil,
          "errors" => [
            %{"key" => "name", "message" => "has already been taken"}
          ]
        }
      }
    }
  end
end

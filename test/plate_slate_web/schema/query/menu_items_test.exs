defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  test "menuItems field returns menu items" do

    query = """
    {
      menuItems {
        name
      }
    }
    """
    conn = build_conn()

    conn = get conn, "/api", query: query

    assert json_response(conn, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Bánh mì"},
          %{"name" => "Chocolate Milkshake"},
          %{"name" => "Croque Monsieur"},
          %{"name" => "French Fries"},
          %{"name" => "Lemonade"},
          %{"name" => "Masala Chai"},
          %{"name" => "Muffuletta"},
          %{"name" => "Papadum"},
          %{"name" => "Pasta Salad"},
          %{"name" => "Reuben"},
          %{"name" => "Soft Drink"},
          %{"name" => "Vada Pav"},
          %{"name" => "Vanilla Milkshake"},
          %{"name" => "Water"}
        ]
      }
    }
  end

  test "menuItems field returns menu items filtered by name" do
    query = """
    {
      menuItems(matching: "reu") {
        name
      }
    }
    """

    response = get(build_conn(), "/api", query: query)

    assert json_response(response, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Reuben"},
        ]
      }
    }
    end


    test "menuItems field returns errors when using a bad value" do
      query = """
      {
        menuItems(matching: 123) {
          name
        }
      }
      """
      response = get(build_conn(), "/api", query: query)

      assert %{"errors" => [
        %{"message" => message}
      ]} = json_response(response, 400)


      assert message == "Argument \"matching\" has invalid value 123."
      end


      test "menuItems field filters by name when using a variable" do
        query = """
        query ($term: String) {
          menuItems(matching: $term) {
            name
          }
        }
        """
        variables = %{"term" => "reu"}
        response = get(build_conn(), "/api", query: query, variables: variables)
        assert json_response(response, 200) == %{
          "data" => %{
            "menuItems" => [
              %{"name" => "Reuben"},
            ]
          }
        }
      end

      test "menuItems field returns items descending using literals" do
        query =  """
        {
          menuItems(order: DESC) {
            name
        } }
        """
        ##By convention, enum values are passed in all uppercase letters!!!
        response = get(build_conn(), "/api", query: query)
        assert %{"data" =>
          %{
          "menuItems" => [
            %{"name" => "Water"} | _]
            }
        } = json_response(response, 200)
      end

      test "menuItems field returns items descending using variables" do
        query = """
          query ($order: SortOrder!) {
            menuItems(order: $order) {
              name
            }
          }
          """
          ##By convention, enum values are passed in all uppercase letters!!!
          variables = %{"order" => "DESC"}

          response = get(build_conn(), "/api", query: query, variables: variables)
          assert %{
            "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
          } = json_response(response, 200)
      end

end

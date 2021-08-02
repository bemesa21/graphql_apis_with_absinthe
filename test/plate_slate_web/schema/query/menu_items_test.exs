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
    #query = """
    #{
    #  menuItems(matching: "reu") {
    #    name
    #  }
    #}
    #"""

    query = """
    {
      menuItems(filter: {name: "reu"}) {
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
      #query = """
      #{
      #  menuItems(matching: 123) {
      #    name
      #  }
      #}
      #"""

      query = """
      {
        menuItems(filter: {name: 123}) {
          name
        }
      }
      """
      response = get(build_conn(), "/api", query: query)

      assert %{"errors" => [
        %{"message" => message}
      ]} = json_response(response, 400)


      assert message == "Argument \"filter\" has invalid value {name: 123}.\nIn field \"name\": Expected type \"String\", found 123."
      end


      test "menuItems field filters by name when using a variable" do
        #query = """
        #query ($term: String) {
        #  menuItems(matching: $term) {
        #    name
        #  }
        #}
        #"""
        #variables = %{"term" => "reu"}

        query = """
        query ($filter: MenuItemFilter!) {
          menuItems(filter: $filter) {
            name
          }
        }
        """

        variables = %{filter: %{"name" => "reu"}}

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

      test "menuItems field returns menuItems, filtering with a literal" do
        query = """
        {
          menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
            name
          }
        }
        """
        response = get(build_conn(), "/api", query: query)
        assert %{
          "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
        } == json_response(response, 200)
      end

      test "menuItems field returns menuItems, filtering with a variable" do
        query = """
        query ($filter: MenuItemFilter!) {
          menuItems(filter: $filter) {
            name
        } }
        """
        variables = %{filter: %{"tag" => "Vegetarian", "category" => "Sandwiches"}}
        response = get(build_conn(), "/api", query: query, variables: variables)
        assert %{
        "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]} } == json_response(response, 200)
        end

        test "menuItems filtered by custom scalar (date)" do
          query = """
              query ($filter: MenuItemFilter!) {
              menuItems(filter: $filter) {
                name
                addedOn
              }
            }
          """
          variables = %{filter: %{"addedBefore" => "2017-01-20"}}
          sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")

          %PlateSlate.Menu.Item{
            name: "Garlic Fries", added_on: ~D[2017-01-01], price: 2.50,
            category: sides
                 } |> PlateSlate.Repo.insert!
            response = get(build_conn(), "/api", query: query, variables: variables)
            assert %{
              "data" => %{
              "menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2017-01-01"}]
              }
            } == json_response(response, 200)
        end

        test "menuItems filtered by custom scalar with error" do
          query = """
            query ($filter: MenuItemFilter!) {
              menuItems(filter: $filter) {
                name
              }
            }
          """
          variables = %{filter: %{"addedBefore" => "not-a-date"}}

          response = get(build_conn(), "/api", query: query, variables: variables)

          assert %{"errors" => [%{"locations" => [
            %{"column" => 0, "line" => 2}], "message" => message}
            ]} = json_response(response, 400)

            expected = """
          Argument "filter" has invalid value $filter.
          In field "addedBefore": Expected type "Date", found "not-a-date".\
          """
          assert expected == message
        end
      end

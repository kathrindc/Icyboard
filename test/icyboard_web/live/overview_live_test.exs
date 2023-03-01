defmodule IcyboardWeb.OverviewLiveTest do
  use IcyboardWeb.ConnCase

  import Phoenix.LiveViewTest
  import Icyboard.ProjectsFixtures

  @create_attrs %{name: "some name", short: "some short"}
  @update_attrs %{name: "some updated name", short: "some updated short"}
  @invalid_attrs %{name: nil, short: nil}

  defp create_overview(_) do
    overview = overview_fixture()
    %{overview: overview}
  end

  describe "Index" do
    setup [:create_overview]

    test "lists all projects", %{conn: conn, overview: overview} do
      {:ok, _index_live, html} = live(conn, Routes.overview_index_path(conn, :index))

      assert html =~ "Listing Projects"
      assert html =~ overview.name
    end

    test "saves new overview", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.overview_index_path(conn, :index))

      assert index_live |> element("a", "New Overview") |> render_click() =~
               "New Overview"

      assert_patch(index_live, Routes.overview_index_path(conn, :new))

      assert index_live
             |> form("#overview-form", overview: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#overview-form", overview: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.overview_index_path(conn, :index))

      assert html =~ "Overview created successfully"
      assert html =~ "some name"
    end

    test "updates overview in listing", %{conn: conn, overview: overview} do
      {:ok, index_live, _html} = live(conn, Routes.overview_index_path(conn, :index))

      assert index_live |> element("#overview-#{overview.id} a", "Edit") |> render_click() =~
               "Edit Overview"

      assert_patch(index_live, Routes.overview_index_path(conn, :edit, overview))

      assert index_live
             |> form("#overview-form", overview: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#overview-form", overview: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.overview_index_path(conn, :index))

      assert html =~ "Overview updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes overview in listing", %{conn: conn, overview: overview} do
      {:ok, index_live, _html} = live(conn, Routes.overview_index_path(conn, :index))

      assert index_live |> element("#overview-#{overview.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#overview-#{overview.id}")
    end
  end

  describe "Show" do
    setup [:create_overview]

    test "displays overview", %{conn: conn, overview: overview} do
      {:ok, _show_live, html} = live(conn, Routes.overview_show_path(conn, :show, overview))

      assert html =~ "Show Overview"
      assert html =~ overview.name
    end

    test "updates overview within modal", %{conn: conn, overview: overview} do
      {:ok, show_live, _html} = live(conn, Routes.overview_show_path(conn, :show, overview))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Overview"

      assert_patch(show_live, Routes.overview_show_path(conn, :edit, overview))

      assert show_live
             |> form("#overview-form", overview: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#overview-form", overview: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.overview_show_path(conn, :show, overview))

      assert html =~ "Overview updated successfully"
      assert html =~ "some updated name"
    end
  end
end

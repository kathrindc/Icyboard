defmodule Icyboard.ProjectsTest do
  use Icyboard.DataCase

  alias Icyboard.Projects

  describe "projects" do
    alias Icyboard.Projects.Overview

    import Icyboard.ProjectsFixtures

    @invalid_attrs %{name: nil, short: nil}

    test "list_projects/0 returns all projects" do
      overview = overview_fixture()
      assert Projects.list_projects() == [overview]
    end

    test "get_overview!/1 returns the overview with given id" do
      overview = overview_fixture()
      assert Projects.get_overview!(overview.id) == overview
    end

    test "create_overview/1 with valid data creates a overview" do
      valid_attrs = %{name: "some name", short: "some short"}

      assert {:ok, %Overview{} = overview} = Projects.create_overview(valid_attrs)
      assert overview.name == "some name"
      assert overview.short == "some short"
    end

    test "create_overview/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_overview(@invalid_attrs)
    end

    test "update_overview/2 with valid data updates the overview" do
      overview = overview_fixture()
      update_attrs = %{name: "some updated name", short: "some updated short"}

      assert {:ok, %Overview{} = overview} = Projects.update_overview(overview, update_attrs)
      assert overview.name == "some updated name"
      assert overview.short == "some updated short"
    end

    test "update_overview/2 with invalid data returns error changeset" do
      overview = overview_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_overview(overview, @invalid_attrs)
      assert overview == Projects.get_overview!(overview.id)
    end

    test "delete_overview/1 deletes the overview" do
      overview = overview_fixture()
      assert {:ok, %Overview{}} = Projects.delete_overview(overview)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_overview!(overview.id) end
    end

    test "change_overview/1 returns a overview changeset" do
      overview = overview_fixture()
      assert %Ecto.Changeset{} = Projects.change_overview(overview)
    end
  end
end

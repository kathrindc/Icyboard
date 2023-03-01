defmodule Icyboard.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Icyboard.Projects` context.
  """

  @doc """
  Generate a overview.
  """
  def overview_fixture(attrs \\ %{}) do
    {:ok, overview} =
      attrs
      |> Enum.into(%{
        name: "some name",
        short: "some short"
      })
      |> Icyboard.Projects.create_overview()

    overview
  end
end

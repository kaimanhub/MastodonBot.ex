defmodule MastodonBotEx.Schema.RepoCheck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "repo_checks" do
    field(:repo, :string)
    field(:last_checked, :naive_datetime)
    field(:last_release_tag, :string)
    field(:tags, {:array, :string})

    timestamps()
  end

  def changeset(repo_check, attrs) do
    repo_check
    |> cast(attrs, [:repo, :last_checked, :last_release_tag, :tags])
    |> validate_length(:repo, max: 255)
    |> validate_length(:tags, max: 5)
    |> validate_required([:repo, :last_checked])
    |> unique_constraint(:repo,
      message: "I am already watching this repository."
    )
  end
end

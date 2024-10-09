defmodule MastodonBotEx.Schema.UserRepoCheck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_repo_checks" do
    field(:user_acct, :string)
    field(:repo, :string)
    field(:complains, {:array, :string})
    field(:suggestions, {:array, :string})

    timestamps()
  end

  def changeset(user_repo_check, attrs) do
    user_repo_check
    |> cast(attrs, [:user_acct, :repo, :complains, :suggestions])
    |> validate_length(:complains, max: 5)
    |> validate_length(:suggestions, max: 5)
    |> validate_required([:user_acct, :repo])
    |> unique_constraint([:user_acct, :repo],
      error_key: :repo_error,
      message: "You are already watching this repository."
    )
  end
end

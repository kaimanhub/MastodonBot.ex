defmodule MastodonBotEx.Repo.Migrations.UserRepoCheck do
  use Ecto.Migration

  def change do
    create table(:user_repo_checks) do
      add(:user_acct, :string)
      add(:repo, :string)
      add(:complains, {:array, :string}, default: [])
      add(:suggestions, {:array, :string}, default: [])

      timestamps()
    end

    create(unique_index(:user_repo_checks, [:user_acct, :repo]))
  end
end

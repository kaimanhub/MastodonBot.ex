defmodule MastodonBotEx.Repo.Migrations.CreateRepoChecks do
  use Ecto.Migration

  def change do
    create table(:repo_checks) do
      add(:repo, :string, null: false)
      add(:last_checked, :naive_datetime, null: false)
      add(:last_release_tag, :string, null: false)
      add(:tags, {:array, :string}, null: false)

      timestamps()
    end

    create(unique_index(:repo_checks, :repo))
  end
end

defmodule Phoenixtester.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :organization_id, :binary_id, primary_key: true
      add :title, :string
      add :domain, :string

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:organizations, [:domain]))
  end
end

defmodule Phoenixtester.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:organization_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :domain, :string
    field :title, :string

    has_many(:users, Phoenixtester.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(organization, attrs, opts \\ []) do
    organization
    |> cast(attrs, [:title, :domain])
    |> validate_title
    |> validate_domain
    |> maybe_validate_domain_uniqueness(opts)
    |> cast_assoc(:users,
      with: &Phoenixtester.Accounts.User.registration_changeset(&1, &2, opts),
      required: true
    )
  end

  defp maybe_validate_domain_uniqueness(changeset, opts) do
    if Keyword.get(opts, :validate_domain_uniqueness, true) do
      changeset
      |> unsafe_validate_unique(:domain, Phoenixtester.Repo,
        repo_opts: [skip_organization_id: true]
      )
      |> unique_constraint(:domain)
    else
      changeset
    end
  end

  defp validate_domain(changeset) do
    changeset
    |> validate_required([:domain])
    # Allowed:
    # - Alphanumeric
    |> validate_format(:domain, ~r/^[A-Za-z0-9]+$/, message: "Allowed characters: alphanumeric")
    |> validate_length(:domain, min: 1, max: 255)
  end

  defp validate_title(changeset) do
    changeset
    |> validate_required([:title])
    # Allowed:
    # - Alphanumeric
    # - Spaces
    # - Symbols + - _ @ ! . , ' " |
    |> validate_format(:title, ~r/^[\sA-Za-z0-9+-_@!.,'"|]+$/,
      message:
        "Allowed characters: alphanumeric, spaces, and the following special characters: + - _ @ ! . , ' \" |"
    )
    |> validate_length(:title, min: 1, max: 255)
  end
end

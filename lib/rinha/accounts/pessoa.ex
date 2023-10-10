defmodule Rinha.Accounts.Pessoa do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pessoas" do
    field :apelido, :string
    field :nome, :string
    field :nascimento, :date
    field :stack, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(pessoa, attrs) do
    pessoa
    |> cast(attrs, [:apelido, :nome, :nascimento, :stack])
    |> validate_required([:apelido, :nome, :nascimento])
    |> validate_length(:apelido, count: :bytes, min: 1, max: 32)
    |> validate_length(:nome, count: :bytes, min: 1, max: 100)
    |> validate_apelido_with_cache
    |> unique_constraint(:apelido)
    |> validate_stack
  end

  defp validate_apelido_with_cache(changeset) do
    with true <- Enum.empty?(changeset.errors),
         apelido <- get_field(changeset, :apelido),
         true <- Cachex.get!(:pessoas_apelido, apelido) do
      add_error(changeset, :nome, "must be a valid string")
    else
      _ -> changeset
    end
  end

  defp validate_stack(changeset) do
    with true <- Enum.empty?(changeset.errors),
         stack <- get_field(changeset, :stack),
         true <- is_list(stack),
         false <- Enum.all?(stack, &(is_binary(&1) && byte_size(&1) in 1..32)) do
      add_error(changeset, :stack, "is invalid", type: :string, validation: :cast)
    else
      _ -> changeset
    end
  end
end

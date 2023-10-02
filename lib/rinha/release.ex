defmodule Rinha.Release do
  def setup_database do
    Application.load(:rinha)

    for repo <- Application.fetch_env!(:rinha, :ecto_repos) do
      repo.__adapter__.storage_up(repo.config)

      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end
end

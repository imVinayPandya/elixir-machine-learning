defmodule News.Enrichments.NER do
  @moduledoc """
  Bumblebee-based NER on headlines
  """
  alias News.Article

  def predict(%Article{title: title} = article) do
    %{entities: entities} = Nx.Serving.batched_run(__MODULE__, title)
    %{article | entities: entities}
  end

  def predict(articles) when is_list(articles) do
    preds = Nx.Serving.batched_run(__MODULE__, Enum.map(articles, & &1.title))
    Enum.zip_with(articles, preds, fn article, %{entities: entities} ->
      %{article | entities: entities}
    end)
  end

  def serving() do
    {:ok, model} = Bumblebee.load_model({:hf, "dslim/bert-base-NER"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-uncased"})

    Bumblebee.Text.token_classification(model, tokenizer,
      aggregation: :same,
      defn_options: [compiler: EXLA],
      compile: [batch_size: 8, sequence_length: 128]
    )
  end
end

defmodule News.Article do
  defstruct [
    :author,
    :content,
    :description,
    :published_at,
    :source,
    :title,
    :url,
    :url_to_image,
    :entities,
    :sentiment
  ]
end

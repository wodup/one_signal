defmodule OneSignal.API do
  def get(url, query \\ []) do
    HTTPoison.start()
    query = OneSignal.Utils.encode_body(query)

    unless String.length(query) == 0 do
      url = "#{url}?#{query}"
    end

    HTTPoison.get(url, OneSignal.auth_header())
    |> handle_response
  end

  def post(url, body) do
    HTTPoison.start()

    req_body = Poison.encode!(body)

    HTTPoison.post(url, req_body, OneSignal.auth_header())
    |> handle_response
  end

  def delete(url) do
    HTTPoison.start()

    HTTPoison.delete(url, OneSignal.auth_header())
    |> handle_response
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body, status_code: code}})
       when code in 200..299 do
    {:ok, Poison.decode!(body)}
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body, status_code: code}}) do
    case Poison.decode(body) do
      {:ok, error} ->
        {:error, %{error: error, status: code}}

      {:error, _error} ->
        {:error, %{error: :json_decode_error, body: body, status: code}}
    end
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end

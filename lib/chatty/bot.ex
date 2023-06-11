defmodule Chatty.Bot do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, model_info} = Bumblebee.load_model({:hf, "facebook/blenderbot-1B-distill"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "facebook/blenderbot-1B-distill"})

    {:ok, generation_config} =
      Bumblebee.load_generation_config({:hf, "facebook/blenderbot-1B-distill"})

    generation_config = Bumblebee.configure(generation_config, max_new_tokens: 100)

    serving =
      Bumblebee.Text.conversation(model_info, tokenizer, generation_config,
        compile: [batch_size: 1, sequence_length: 100],
        defn_options: [compiler: EXLA]
      )

    {:ok, serving}
  end

  def handle_cast({:send, %{text: message, history: history}, sender}, serving) do
    %{text: message, history: history} =
      Nx.Serving.run(serving, %{text: message, history: history})

    send(sender, {:response, %{text: message, history: history}})
    {:noreply, serving}
  end

  def send_message(%{text: message, history: history}) do
    GenServer.cast(__MODULE__, {:send, %{text: message, history: history}, self()})
  end
end

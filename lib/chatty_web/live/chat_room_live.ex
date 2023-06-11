defmodule ChattyWeb.ChatRoomLive do
  use ChattyWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       messages: [],
       history: [],
       form: to_form(%{message: ""})
     )}
  end

  def handle_event("send", %{"message" => message}, socket) do
    messages = socket.assigns.messages ++ [{:input, message}]

    Chatty.Bot.send_message(%{text: message, history: socket.assigns.history})
    {:noreply, assign(socket, messages: messages)}
  end

  def handle_info({:response, %{text: message, history: history}}, socket) do
    messages = socket.assigns.messages ++ [{:bot, message}]
    {:noreply, assign(socket, messages: messages, history: history)}
  end

  def render(assigns) do
    ~H"""
    <div class="border-3 border-black p-2 rounded-4xl max-h-screen flex flex-col gap-2">
      <%= for {type, message} <- @messages do %>
        <div :if={type == :bot} class="rounded-4xl bg-sky-300 p-2 px-4 w-fit">
          <p class="text-xl"><span class="pr-2">🤖</span><%= message %></p>
        </div>
        <div :if={type == :input} class="rounded-4xl bg-emerald-300 p-2 px-4 w-fit">
          <p class="text-xl"><span class="pr-2">🕺</span><%= message %></p>
        </div>
      <% end %>
      <p class="only:block hidden text-xl rounded-4xl bg-orange-300 p-2 px-4 w-fit">輸入訊息 👇</p>
    </div>
    <div class="border-black border-3 rounded-4xl mt-4 p-1 w-full">
      <.form for={@form} phx-submit="send" class="flex w-full">
        <.input field={@form[:message]} class="grow w-full" phx-debounce="2000" />
        <.button class="flex-none text-xl" phx-debounce="2000">送出</.button>
      </.form>
    </div>
    """
  end
end

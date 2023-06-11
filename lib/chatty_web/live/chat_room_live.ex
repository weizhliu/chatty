defmodule ChattyWeb.ChatRoomLive do
  use ChattyWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       messages: [],
       history: [],
       form: to_form(%{"message" => ""}),
       loading: false
     )}
  end

  def handle_event("send", _params, %{assigns: %{loading: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("send", %{"message" => message}, socket) do
    messages = socket.assigns.messages ++ [{:input, message}]

    Chatty.Bot.send_message(%{text: message, history: socket.assigns.history})
    {:noreply, assign(socket, messages: messages, loading: true)}
  end

  def handle_info({:response, %{text: message, history: history}}, socket) do
    messages = socket.assigns.messages ++ [{:bot, message}]
    {:noreply, assign(socket, messages: messages, history: history, loading: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="border-3 border-black rounded-4xl p-2 bg-gray-200">
      <div class="border-3 border-black p-2 rounded-3xl flex flex-col gap-2 bg-white">
        <%= for {type, message} <- @messages do %>
          <div :if={type == :bot} class="rounded-2xl bg-sky-300 p-2 px-4 w-fit">
            <p class="text-xl"><span class="pr-2">🤖</span><%= message %></p>
          </div>
          <div :if={type == :input} class="rounded-2xl bg-emerald-300 p-2 px-4 w-fit">
            <p class="text-xl"><span class="pr-2">🕺</span><%= message %></p>
          </div>
        <% end %>
        <div class="only:block hidden rounded-2xl bg-orange-300 p-2 px-4 w-fit">
          <p class="text-xl">Say some thing 👇</p>
        </div>
        <div :if={@loading} class="rounded-2xl bg-sky-100 p-2 px-4 w-fit animate-pulse">
          <p class="text-xl"><span class="pr-2">🤖</span>is typing</p>
        </div>
      </div>
      <div class="border-black border-3 rounded-3xl mt-2 p-2 w-full bg-white">
        <.form for={@form} phx-submit="send" class="flex w-full">
          <.input field={@form[:message]} class="grow w-full" />
          <.button class="flex-none text-xl">Send</.button>
        </.form>
      </div>
    </div>
    """
  end
end

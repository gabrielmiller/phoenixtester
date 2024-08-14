defmodule PhoenixtesterWeb.UserRegistrationLive do
  use PhoenixtesterWeb, :live_view

  alias Phoenixtester.Accounts
  alias Phoenixtester.Accounts.Organization
  alias Phoenixtester.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/organizations/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate" method="post">
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:title]} type="text" label="Organization title" />
        <.input field={@form[:domain]} type="text" label="Organization domain" />
        <.inputs_for :let={user_form} field={@form[:users]}>
          <.input field={user_form[:email]} type="email" label="Email" />
          <.input field={user_form[:password]} type="password" label="Password" />
        </.inputs_for>

        <div class="mt-2 flex items-center justify-between gap-6">
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset =
      Accounts.change_organization_registration(%Organization{
        users: [%User{}]
      })

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"organization" => organization_params}, socket) do
    case Accounts.register_organization(organization_params) do
      {:ok, organization} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            Enum.at(organization.users, 0),
            &url(~p"/users/confirm/#{&1}")
          )

        {:noreply,
         redirect(socket |> put_flash(:info, "Check your email to confirm your account."),
           to: ~p"/users/confirm"
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"organization" => organization_params}, socket) do
    changeset =
      Accounts.change_organization_registration(
        %Organization{
          users: [%User{}]
        },
        organization_params
      )

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "organization")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end

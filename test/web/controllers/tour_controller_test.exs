defmodule PedalApp.Web.TourControllerTest do
  use PedalApp.Web.ConnCase

  alias PedalApp.Tour

  setup do
    user = insert(:user)
    conn = login(user)
    {:ok, conn: conn, user: user}
  end

  test "index", %{conn: conn, user: user} do
    insert(:tour, %{user: user})
    conn = get conn, "/rider/tours"
    assert response(conn, 200)
    assert template(conn) == "index.html"
    assert length(assigns(conn, :tours)) == 1
  end

  test "show", %{conn: conn, user: user} do
    tour = insert(:tour, %{user: user})
    conn = get conn, "rider/tours/#{tour.id}"
    assert response(conn, 200)
    assert template(conn) == "show.html"
    assert assigns(conn, :tour)
  end

  test "show not found", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, "/rider/tours/0"
    end
  end

  test "new", %{conn: conn} do
    conn = get conn, "/rider/tours/new"
    assert response(conn, 200)
    assert template(conn) == "new.html"
  end

  test "create", %{conn: conn} do
    conn = post conn, "/rider/tours", tour: %{
      title:        "Test Tour",
      description:  "Test Description"
    }
    tour = Repo.one(Tour)
    assert redirected_to(conn) == "/rider/tours/#{tour.id}"
  end

  test "create failure", %{conn: conn} do
    conn = post conn, "/rider/tours", tour: %{}
    assert response(conn, 200)
    assert template(conn) == "new.html"
  end

  test "edit", %{conn: conn, user: user} do
    tour = insert(:tour, user: user)
    conn = get conn, "/rider/tours/#{tour.id}/edit"
    assert response(conn, 200)
    assert template(conn) == "edit.html"
    assert assigns(conn, :tour)
    assert assigns(conn, :changeset)
  end

  test "update", %{conn: conn, user: user} do
    tour = insert(:tour, user: user)
    conn = put conn, "/rider/tours/#{tour.id}", tour: %{
      title: "Updated tour"
    }
    assert redirected_to(conn) == "/rider/tours/#{tour.id}"
    assert Repo.get_by(Tour, id: tour.id, title: "Updated tour")
  end

  test "update failure", %{conn: conn, user: user} do
    tour = insert(:tour, user: user)
    conn = put conn, "/rider/tours/#{tour.id}", tour: %{
      title: ""
    }
    assert response(conn, 200)
    assert template(conn) == "edit.html"
    refute Repo.get_by(Tour, id: tour.id, title: "")
  end

  test "delete", %{conn: conn, user: user} do
    tour = insert(:tour, user: user)
    conn = delete conn, "/rider/tours/#{tour.id}"
    assert redirected_to(conn) == "/rider/tours"
    refute Repo.get(Tour, tour.id)
  end
end
defmodule LoadedBike.WaypointTest do
  use LoadedBike.ModelCase

  import LoadedBike.TestFactory
  import LoadedBike.Web.Test.BuildUpload

  alias LoadedBike.Waypoint

  describe "changeset" do
    test "with valid attributes" do
      tour = insert(:tour)
      changeset = Waypoint.changeset(build_assoc(tour, :waypoints), params_for(:waypoint))
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Waypoint.changeset(%Waypoint{}, %{})
      refute changeset.valid?
    end

    test "position setting" do
      waypoint = insert(:waypoint)
      changeset = Waypoint.changeset(build_assoc(waypoint.tour, :waypoints), params_for(:waypoint))
      assert changeset.changes.position == 1
    end

    test "position setting for existing record" do
      waypoint = insert(:waypoint, position: 99)
      changeset = Waypoint.changeset(waypoint, %{title: "Updated"})
      refute changeset.changes[:position]
    end

    test "new with gpx track" do
      tour = insert(:tour)
      params = %{params_for(:waypoint) | gpx_file: build_upload(path: "test/files/test.gpx")}
      changeset = Waypoint.changeset(build_assoc(tour, :waypoints), params)
      data = get_field(changeset, :geojson)
      map = %{
        type: "LineString",
        coordinates: [
          [8.89241667, 46.57608333, 2376],
          [8.89252778, 46.57619444, 2375],
          [8.89266667, 46.57641667, 2372]
        ]
      }
      assert data == map

      assert get_field(changeset, :lat) == 46.57641667
      assert get_field(changeset, :lng) == 8.89266667
    end

    test "new with gpx route" do
      tour = insert(:tour)
      params = %{params_for(:waypoint) | gpx_file: build_upload(path: "test/files/test-route.gpx")}
      changeset = Waypoint.changeset(build_assoc(tour, :waypoints), params)
      data = get_field(changeset, :geojson)
      map = %{
        type: "LineString",
        coordinates: [
          [141.6774785, 42.7832427],
          [141.6776047, 42.7832561],
          [141.6784915, 42.7751368]
        ]
      }
      assert data == map

      assert get_field(changeset, :lat) == 42.7751368
      assert get_field(changeset, :lng) == 141.6784915
    end

    test "existing with gpx" do
      waypoint = insert(:waypoint)
      changeset = Waypoint.changeset(waypoint, %{gpx_file: build_upload(path: "test/files/test.gpx")})
      refute get_field(changeset, :lat) == 46.57641667
      refute get_field(changeset, :lng) == 8.89266667
    end

    test "with gpx invalid" do
      tour = insert(:tour)
      params = %{params_for(:waypoint) | gpx_file: build_upload(path: "test/files/test.jpg")}
      changeset = Waypoint.changeset(build_assoc(tour, :waypoints), params)
      refute get_field(changeset, :geojson)
    end

    test "with gpx no track" do
      tour = insert(:tour)
      params = %{params_for(:waypoint) | gpx_file: build_upload(path: "test/files/test-blank.gpx")}
      changeset = Waypoint.changeset(build_assoc(tour, :waypoints), params)
      refute get_field(changeset, :geojson)
    end
  end

  test "insert" do
    tour = insert(:tour)
    {status, _} = Repo.insert(Waypoint.changeset(build_assoc(tour, :waypoints), params_for(:waypoint)))
    assert status == :ok
  end

  test "to_json" do
    waypoint = insert(:waypoint)
    assert Poison.encode!(waypoint) == "{\"title\":\"Test Waypoint\",\"lng\":-123.2616348,\"lat\":49.262206,\"is_planned\":false}"
  end

  describe "scope" do
    test "published" do
      waypoint = insert(:waypoint, %{is_published: false})
      query = Waypoint.published(Waypoint)
      assert Repo.aggregate(query, :count, :id) == 0

      Repo.update!(change(waypoint, %{is_published: true}))
      assert Repo.aggregate(query, :count, :id) == 1
    end

    test "previous and next" do
      wp_1 = insert(:waypoint, %{position: 0})
      wp_2 = insert(:waypoint, %{position: 1, tour: wp_1.tour})
      wp_3 = insert(:waypoint, %{position: 2, tour: wp_1.tour})

      # different tour (i hate factories)
      user = insert(:user, %{email: "test@test.test"})
      tour = insert(:tour, %{user: user})
      insert(:waypoint, %{position: 3, tour: tour})

      refute Repo.one(Waypoint.previous(wp_1))
      assert Repo.one(Waypoint.previous(wp_2)).id == wp_1.id
      assert Repo.one(Waypoint.previous(wp_3)).id == wp_2.id

      assert Repo.one(Waypoint.next(wp_1)).id == wp_2.id
      assert Repo.one(Waypoint.next(wp_2)).id == wp_3.id
      refute Repo.one(Waypoint.next(wp_3))
    end

    test "select_without_gps" do
      insert(:waypoint, %{geojson: %{some: "junk"}})
      wp = Repo.one(Waypoint)
      assert wp.geojson

      query = Waypoint.select_without_gps(Waypoint)
      wp = Repo.one(query)
      refute wp.geojson
    end
  end
end

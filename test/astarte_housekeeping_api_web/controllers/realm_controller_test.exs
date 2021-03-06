#
# This file is part of Astarte.
#
# Astarte is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Astarte is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Astarte.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright (C) 2017 Ispirata Srl
#

defmodule Astarte.Housekeeping.APIWeb.RealmControllerTest do
  use Astarte.Housekeeping.APIWeb.ConnCase

  alias Astarte.Housekeeping.API.Realms
  alias Astarte.Housekeeping.API.Realms.Realm

  @pubkey """
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAE6ssZpULEsn+wSQdc+DI2+4aj98a1hDKM
+bxRibfFC0G6SugduGzqIACSdIiLEn4Nubx2jt4tHDpel0BIrYKlCw==
-----END PUBLIC KEY-----
"""
  @malformed_pubkey """
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYAoDQgAE6ssZpw4aj98a1hDKM
  +bxRibfFC0G6SugduGzqIACSdIiLEn4Nubx2jt4tHDpel0BIrYKlCw==
-----END PUBLIC KEY-----
"""

  @create_attrs %{"realm_name" => "testrealm", "jwt_public_key_pem" => @pubkey}
  @update_attrs %{}
  @invalid_name_attrs %{"realm_name" => "0invalid", "jwt_public_key_pem" => @pubkey}
  @no_pubkey_attrs %{"realm_name" => "valid"}
  @invalid_pubkey_attrs %{"realm_name" => "valid", "jwt_public_key_pem" => "invalid"}
  @malformed_pubkey_attrs %{"realm_name" => "valid", "jwt_public_key_pem" => @malformed_pubkey}
  @non_existing_realm_name "nonexistingrealm"

  def fixture(:realm) do
    {:ok, realm} = Realms.create_realm(@create_attrs)
    realm
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, realm_path(conn, :index)
    assert json_response(conn, 200) == [] || json_response(conn, 200) == ["testrealm"]
  end

  test "creates realm and renders realm when data is valid", %{conn: conn} do
    conn = post conn, realm_path(conn, :create), @create_attrs
    assert response(conn, 201)

    conn = get conn, realm_path(conn, :show, @create_attrs["realm_name"])
    assert json_response(conn, 200) == %{"realm_name" => @create_attrs["realm_name"], "jwt_public_key_pem" => @create_attrs["jwt_public_key_pem"]}
  end

  test "returns a 404 on show non-existing realm", %{conn: conn} do
    conn = get conn, realm_path(conn, :show, @non_existing_realm_name)
    assert json_response(conn, 404)
  end

  test "does not create realm and renders errors when realm_name is invalid", %{conn: conn} do
    conn = post conn, realm_path(conn, :create), @invalid_name_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create realm and renders errors when no public key is provided", %{conn: conn} do
    conn = post conn, realm_path(conn, :create), @no_pubkey_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create realm and renders errors when public key is invalid", %{conn: conn} do
    conn = post conn, realm_path(conn, :create), @invalid_pubkey_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create realm and renders errors when public key is malformed", %{conn: conn} do
    conn = post conn, realm_path(conn, :create), @malformed_pubkey_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :wip
  test "updates chosen realm and renders realm when data is valid", %{conn: conn} do
    %Realm{realm_name: realm_name} = realm = fixture(:realm)
    conn = put conn, realm_path(conn, :update, realm), @update_attrs
    assert %{"realm_name" => ^realm_name} = json_response(conn, 200)

    conn = get conn, realm_path(conn, :show, realm_name)
    assert json_response(conn, 200) == %{
      "realm_name" => realm_name}
  end

  @tag :wip
  test "does not update chosen realm and renders errors when data is invalid", %{conn: conn} do
    realm = fixture(:realm)
    conn = put conn, realm_path(conn, :update, realm), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :wip
  test "deletes chosen realm", %{conn: conn} do
    realm = fixture(:realm)
    conn = delete conn, realm_path(conn, :delete, realm)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, realm_path(conn, :show, realm)
    end
  end
end

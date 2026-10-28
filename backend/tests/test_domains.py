import pytest

@pytest.mark.asyncio
async def test_add_and_list_domains(client):
    login_resp = await client.post("/api/v1/auth/demo-login")
    token = login_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    add_resp = await client.post(
        "/api/v1/domains",
        json={"domain_name": "example.com", "verification_method": "DNS_TXT"},
        headers=headers
    )
    assert add_resp.status_code == 200
    dom = add_resp.json()
    assert dom["domain_name"] == "example.com"
    assert "verification_token" in dom

    list_resp = await client.get("/api/v1/domains", headers=headers)
    assert list_resp.status_code == 200
    domains = list_resp.json()
    assert len(domains) >= 1

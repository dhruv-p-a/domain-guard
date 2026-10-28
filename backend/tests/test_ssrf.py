import pytest
from fastapi import HTTPException
from app.core.ssrf import validate_target_domain_or_url

def test_valid_public_domain():
    domain = validate_target_domain_or_url("example.com")
    assert domain == "example.com"

def test_blocked_localhost():
    with pytest.raises(HTTPException) as exc_info:
        validate_target_domain_or_url("localhost")
    assert exc_info.value.status_code == 400
    assert "restricted" in exc_info.value.detail.lower()

def test_blocked_metadata_ip():
    with pytest.raises(HTTPException) as exc_info:
        validate_target_domain_or_url("http://169.254.169.254/latest/meta-data/")
    assert exc_info.value.status_code == 400

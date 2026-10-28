import ipaddress
import socket
from urllib.parse import urlparse
from fastapi import HTTPException, status

BLOCKED_IP_NETWORKS = [
    ipaddress.ip_network("127.0.0.0/8"),         # IPv4 loopback
    ipaddress.ip_network("10.0.0.0/8"),          # Private RFC 1918
    ipaddress.ip_network("172.16.0.0/12"),       # Private RFC 1918
    ipaddress.ip_network("192.168.0.0/16"),      # Private RFC 1918
    ipaddress.ip_network("169.254.0.0/16"),      # Link-local / AWS IMDS
    ipaddress.ip_network("0.0.0.0/8"),           # Current network
    ipaddress.ip_network("::1/128"),             # IPv6 loopback
    ipaddress.ip_network("fc00::/7"),            # IPv6 unique local
    ipaddress.ip_network("fe80::/10"),           # IPv6 link-local
]

BLOCKED_HOSTNAMES = {
    "localhost",
    "loopback",
    "metadata.google.internal",
    "169.254.169.254",
    "kubernetes.default.svc",
}

def is_ip_blocked(ip_str: str) -> bool:
    try:
        ip_obj = ipaddress.ip_address(ip_str)
        for net in BLOCKED_IP_NETWORKS:
            if ip_obj in net:
                return True
        return False
    except ValueError:
        return True

def validate_target_domain_or_url(target: str) -> str:
    """
    Validates that target domain or URL is a safe public target and not an SSRF exploit.
    """
    if not target:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Target cannot be empty"
        )

    # Clean target
    clean_target = target.strip()
    if not clean_target.startswith("http://") and not clean_target.startswith("https://"):
        url = "https://" + clean_target
    else:
        url = clean_target

    parsed = urlparse(url)
    hostname = parsed.hostname or parsed.path.split('/')[0]

    if not hostname:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid hostname"
        )

    hostname_lower = hostname.lower()

    if hostname_lower in BLOCKED_HOSTNAMES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Security violation: Target '{hostname}' is a restricted internal or metadata host."
        )

    # Resolve IP addresses for hostname to check for DNS rebinding / private IP targets
    try:
        resolved_ips = socket.getaddrinfo(hostname, None)
        for entry in resolved_ips:
            ip = entry[4][0]
            if is_ip_blocked(ip):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Security violation: Domain '{hostname}' resolves to restricted internal IP address ({ip})."
                )
    except socket.gaierror:
        # Domain name DNS resolution error - allow proceed to scanner to mark domain unreachable,
        # but check if hostname itself is formatted like an IP
        if is_ip_blocked(hostname_lower):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Security violation: Restricted target IP address."
            )

    return hostname_lower

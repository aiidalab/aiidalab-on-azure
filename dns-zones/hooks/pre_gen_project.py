import sys

import validators

DNS_ZONE_NAME = "{{ cookiecutter.dns_zone_name }}"

if validators.domain(DNS_ZONE_NAME) is not True:
    print(f"{DNS_ZONE_NAME!r} is not a valid domain name.", file=sys.stderr)
    sys.exit(1)

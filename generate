#!/usr/bin/env python
import click
import secrets
import os

from cookiecutter.main import cookiecutter
import validators
import petname


class HostnameParamType(click.ParamType):
    name = "hostname"

    def convert(self, value, param, ctx):
        if validators.domain(value) is not True:
            self.fail(f"{value!r} is not a valid domain name.", param, ctx)

        return value


@click.command()
@click.argument("hostname", type=HostnameParamType())
@click.option("-f", "--overwrite-if-exists", is_flag=True, default=False)
@click.option("-r", "--generate-random-domain-name", is_flag=True, default=False)
def cli(hostname, overwrite_if_exists, generate_random_domain_name):
    click.echo("Generating deployment...")

    if generate_random_domain_name:
        # Automatically generate random domain name in case that the provided
        # hostname has less than 3 labels.
        labels = hostname.split(".")
        hostname = ".".join(([petname.generate()] if len(labels) < 3 else []) + labels)
    assert validators.domain(hostname) is True

    cookiecutter(
        ".",
        extra_context={
            "hostname": hostname,
            "secret_token": secrets.token_hex(32),
            "aks_service_principal_app_id": os.environ.get(
                "AKS_SERVICE_PRINCIPAL_APP_ID"
            ),
            "aks_service_principal_client_secret": os.environ.get(
                "AKS_SERVICE_PRINCIPAL_CLIENT_SECRET"
            ),
            "aks_service_principal_object_id": os.environ.get(
                "AKS_SERVICE_PRINCIPAL_OBJECT_ID"
            ),
        },
        overwrite_if_exists=overwrite_if_exists,
    )


if __name__ == "__main__":
    cli()

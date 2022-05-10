#!/usr/bin/env python
import click
import secrets
import os

from cookiecutter.main import cookiecutter


@click.command()
@click.option("-f", "--overwrite-if-exists", is_flag=True, default=False)
def cli(overwrite_if_exists):
    click.echo("Generating deployment...")

    cookiecutter(
        '.',
        extra_context={
            'secret_token': secrets.token_hex(32),
            'aks_service_principal_app_id': os.environ.get("AKS_SERVICE_PRINCIPAL_APP_ID"),
            'aks_service_principal_client_secret': os.environ.get("AKS_SERVICE_PRINCIPAL_CLIENT_SECRET"),
            'aks_service_principal_object_id': os.environ.get("AKS_SERVICE_PRINCIPAL_OBJECT_ID"),
        },
        overwrite_if_exists=overwrite_if_exists,
    )



if __name__ == "__main__":
    cli()

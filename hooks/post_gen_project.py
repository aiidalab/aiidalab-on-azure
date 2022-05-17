from pathlib import Path

# Rename j2 template files.
values_yaml = Path("modules", "aiidalab", "values.yml")
values_yaml.with_suffix(".yml.j2").rename(values_yaml)

# Rename j2 template file names in terraform configuration files.
helm_tf = Path("modules", "aiidalab", "jupyterhub.tf")
helm_tf.write_text(helm_tf.read_text().replace("values.yml.j2", "values.yml"))

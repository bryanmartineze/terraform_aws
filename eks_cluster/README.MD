

Use "terraform output -raw bastion_key > bastion_key.pem" to reach the PEM key after that, assing read-only permissions (chdmod 400) to they key file.
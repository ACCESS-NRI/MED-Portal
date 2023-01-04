# The ACCESS-MED Portal


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## ⚙️ Development

The repository comes with a Dockerfile and a docker-compose.yaml file that can be used to run a containerised development environment.
As the Authentication uses SSL, you need to have a self-signed certificate.

You can generate a self-signed certificate as [follow](https://devcenter.heroku.com/articles/ssl-certificate-self)

### Generate private key and certificate signing request
A private key and certificate signing request are required to create an SSL certificate. These can be generated with a few simple commands.

When the openssl req command asks for a “challenge password”, just press return, leaving the password empty. This password is used by Certificate Authorities to authenticate the certificate owner when they want to revoke their certificate. Since this is a self-signed certificate, there’s no way to revoke it via CRL (Certificate Revocation List).

```bash
openssl genrsa -aes256 -passout pass:gsahdg -out server.pass.key 4096
openssl rsa -passin pass:gsahdg -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -key server.key -out server.csr
```

### Generate SSL certificate
The self-signed SSL certificate is generated from the server.key private key and server.csr files.

```bash
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
```

### LiveReload (Heroku)

[LiveReload](https://github.com/guard/guard-livereload) enables the browser to automatically refresh on change during development.

1. Download the [LiveReload Chrome plugin](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei/)
2. Run `bundle exec guard`

### Environment variables

Environment variables should be stored in a .env file. DO NOT COMMIT YOUR FILE TO THE REPO.
# Create a self-signed SSL certificate to use with the Ingress
openssl req -new -x509 -nodes -out internal.corp.crt -keyout internal.corp.key -subj "/CN=*.internal.corp" -addext "subjectAltName=DNS:*.internal.corp"

# Export the SSL certificate
openssl pkcs12 -export -in internal.corp.crt -inkey internal.corp.key -out internal.corp.pfx

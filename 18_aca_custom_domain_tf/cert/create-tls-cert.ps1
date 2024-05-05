# Create a self-signed SSL certificate to use with the Ingress
openssl req -new -x509 -nodes -out aca-app.com.crt -keyout aca-app.com.key -subj "/CN=aca-app.com" -addext "subjectAltName=DNS:aca-app.com"

# Export the SSL certificate
openssl pkcs12 -export -in aca-app.com.crt -inkey aca-app.com.key -out aca-app.com.pfx

# Password for the PFX file: @Aa123456789

cat aca-app.com.crt > aca-app.com.pem
cat aca-app.com.key >> aca-app.com.pem




openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes `
  -keyout poorclaresarundel.org.key -out poorclaresarundel.org.crt -subj "/CN=aca-app.com" `
  -addext "subjectAltName=DNS:aca-app.com,DNS:www.aca-app.com,IP:8.8.8.8"

# sudo chmod +r poorclaresarundel.org.key
cat poorclaresarundel.org.crt > poorclaresarundel.org.pem
cat poorclaresarundel.org.key >> poorclaresarundel.org.pem
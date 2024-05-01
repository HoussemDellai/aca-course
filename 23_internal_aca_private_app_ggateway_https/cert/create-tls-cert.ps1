# Create a self-signed SSL certificate to use with the Ingress
openssl req -new -x509 -nodes -out azureapp01.com.crt -keyout azureapp01.com.key -subj "/CN=azureapp01.com" -addext "subjectAltName=DNS:azureapp01.com"

# Export the SSL certificate
openssl pkcs12 -export -in azureapp01.com.crt -inkey azureapp01.com.key -out azureapp01.com.pfx







# Create a self-signed SSL certificate to use with the Ingress
openssl req -new -x509 -nodes -out aca-app-01.com.crt -keyout aca-app-01.com.key -subj "/CN=aca-app-01.com" -addext "subjectAltName=DNS:aca-app-01.com"

# Export the SSL certificate
openssl pkcs12 -export -in aca-app-01.com.crt -inkey aca-app-01.com.key -out aca-app-01.com.pfx

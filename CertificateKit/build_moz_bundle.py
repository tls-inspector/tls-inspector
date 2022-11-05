import json
import os
import subprocess
import tempfile
import urllib.request

moz_bundle = urllib.request.urlopen("https://ccadb-public.secure.force.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites").read()

pem_certs = []
pem = b''
for line in moz_bundle.split(b'\n'):
    pem += line
    if line == b'-----END CERTIFICATE-----':
        pem_certs.append(pem.replace(b'\r', b'\n'))
        pem = b''

wd = os.getcwd()

with tempfile.TemporaryDirectory() as tmpdirname:
    os.chdir(tmpdirname)

    params = [
        "/usr/local/bin/openssl",
        "crl2pkcs7",
        "-nocrl"
    ]

    i = 0
    for cert in pem_certs:
        file_name = "cert" + str(i) + ".cer"
        with open(file_name, 'wb') as cert_file:
            cert_file.write(cert)

        params.append("-certfile")
        params.append(file_name)
        i += 1

    params.append("-out")
    params.append("moz_ca_bundle.p7b")

    subprocess.run(params)
    subprocess.run(["mv", "moz_ca_bundle.p7b", os.path.join(wd, "moz_ca_bundle.p7b")])
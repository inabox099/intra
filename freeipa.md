docker run --name freeipa-server-container -ti \
    -h ipa.namedi.org --read-only \
    -v ipa-data:/data:Z freeipa/freeipa-server:centos-9-stream-4.12.2
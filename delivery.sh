#!/bin/bash

# Refer: .github/workflows/ci.yml
# echo "${{ secrets.LSPSERVER_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
docker push ghcr.io/lspserver/servers:latest

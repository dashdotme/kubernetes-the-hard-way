#!/usr/bin/env bash
set -euo pipefail

echo "Installing packages"
DEPS=(wget curl vim-gtk3 xclip openssl git tmux)
if ! dpkg -s "${DEPS[@]}" >/dev/null 2>&1; then
    apt update
    apt install -y "${DEPS[@]}"
fi

echo "Setting up repo"
WORKING_DIR="/root/kubernetes-the-hard-way"
REPO_URL="https://github.com/kelseyhightower/kubernetes-the-hard-way.git"
if [[ -d "$WORKING_DIR/.git" ]]; then
    git -C "$WORKING_DIR" pull --ff-only
else
    git clone --depth 1 "$REPO_URL" "$WORKING_DIR"
fi
cd "$WORKING_DIR"

echo "Downloading and installing binaries"
ARCH=$(dpkg --print-architecture)
if [[ ! -x downloads/client/kubectl ]]; then
    wget -q --https-only --timestamping -P downloads -i "downloads-${ARCH}.txt"
    mkdir -p downloads/{client,cni-plugins,controller,worker}
    tar -xf "downloads/crictl-v1.32.0-linux-${ARCH}.tar.gz" -C downloads/worker/
    tar -xf "downloads/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz" --strip-components=1 -C downloads/worker/
    tar -xf "downloads/cni-plugins-linux-${ARCH}-v1.6.2.tgz" -C downloads/cni-plugins/
    tar -xf "downloads/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz" \
        --strip-components=1 -C downloads/ \
        etcd-v3.6.0-rc.3-linux-${ARCH}/{etcdctl,etcd}
    cp -f downloads/{etcdctl,kubectl} downloads/client/
    cp -f downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} downloads/controller/ || true
    cp -f downloads/{kubelet,kube-proxy} downloads/worker/ || true
    cp -f "downloads/runc.${ARCH}" downloads/worker/runc || true
    rm -f downloads/*.gz downloads/*.tgz
    chmod +x downloads/{client,cni-plugins,controller,worker}/* || true
fi
if ! command -v kubectl >/dev/null 2>&1; then
    cp downloads/client/kubectl /usr/local/bin/
    chmod +x /usr/local/bin/kubectl
fi

echo "Verifying"
kubectl version --client || true
vim --version | grep clipboard || true

echo "Done. SSH with: ssh root@jumpbox"
echo "In Vim, use \"+y to copy text to your local clipboard via OSC 52."

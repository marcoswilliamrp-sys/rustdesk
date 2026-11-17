#!/usr/bin/env bash
# Rebrand de um checkout do RustDesk 1.5.1 para RPMDesk, com servidor e chave embutidos.
# Uso: bash aplicar-rpmdesk.sh <pasta-do-checkout-rustdesk>
set -euo pipefail
cd "${1:?informe a pasta do checkout}"

NOME="RPMDesk"
HOST="168.227.237.241"
KEY="L02qPHIRQOeJWJtP+GKXV1AVOqDNqJyg9nDghcI7wZ0="

# Nome do app (pastas de config, serviço, janela, instalação) + servidor/chave padrão
sed -i \
  -e "s|RwLock::new(\"RustDesk\".to_owned())|RwLock::new(\"$NOME\".to_owned())|" \
  -e "s|^pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[\".*\"\];|pub const RENDEZVOUS_SERVERS: \&[\&str] = \&[\"$HOST\"];|" \
  -e "s|^pub const RS_PUB_KEY: &str = \".*\";|pub const RS_PUB_KEY: \&str = \"$KEY\";|" \
  libs/hbb_common/src/config.rs

# Metadados do executável (Propriedades > Detalhes) e título padrão da janela.
# Nomes de arquivo (rustdesk.exe / librustdesk.dll) ficam iguais: o workflow e o main.cpp dependem deles.
sed -i -e "s|\"RustDesk Remote Desktop\"|\"$NOME Remote Desktop\"|" -e "s|\"ProductName\", \"RustDesk\"|\"ProductName\", \"$NOME\"|" flutter/windows/runner/Runner.rc
sed -i "s|L\"RustDesk\";|L\"$NOME\";|" flutter/windows/runner/main.cpp
sed -i -e "s|\"RustDesk Remote Desktop\"|\"$NOME Remote Desktop\"|" -e "s|ProductName = \"RustDesk\"|ProductName = \"$NOME\"|" libs/portable/Cargo.toml Cargo.toml

# Confere que cada troca pegou (falha alto se o upstream mudou)
grep -q "RwLock::new(\"$NOME\"" libs/hbb_common/src/config.rs
grep -q "\"$HOST\"" libs/hbb_common/src/config.rs
grep -q "\"$KEY\"" libs/hbb_common/src/config.rs
grep -q "\"ProductName\", \"$NOME\"" flutter/windows/runner/Runner.rc
grep -q "L\"$NOME\";" flutter/windows/runner/main.cpp
grep -q "ProductName = \"$NOME\"" libs/portable/Cargo.toml
echo "OK: rebrand $NOME aplicado."

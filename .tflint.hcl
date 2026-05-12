config {
  call_module_type = "none"
}

# Sem plugin de provider — bpg/proxmox não tem suporte oficial no tflint.
# Checks ativos: variáveis não usadas, tipos inválidos, deprecated syntax.
#
# Nota: terraform validate não roda no lint workflow porque requer terraform init,
# que por sua vez precisa do token do TF Cloud (TF_API_TOKEN).
# O validate roda no infra.yml, antes do terraform plan.

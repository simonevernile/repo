locals {
  external_results = {
    for k, m in module.external :
    k => {
      external_ip          = try(m.external_ip, null)
      internal_ip          = null
      tcp_forwarding_rules = try(m.tcp_forwarding_rules, null)
      udp_forwarding_rules = try(m.udp_forwarding_rules, null)
    }
  }

  internal_results = {
    for k, m in module.internal :
    k => {
      external_ip          = null
      internal_ip          = try(m.internal_ip, null)
      tcp_forwarding_rules = try(m.tcp_forwarding_rules, null)
      udp_forwarding_rules = try(m.udp_forwarding_rules, null)
    }
  }
}

output "results" {
  description = "Per-LB outputs keyed by index (module address → outputs)."
  value       = merge(local.external_results, local.internal_results)
}

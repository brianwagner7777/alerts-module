output "action_groups" {
  description = "Action groups with all attributes."
  value       = azurerm_monitor_action_group.action_groups
}

output "query_alert_rules" {
  description = "Scheduled query (log) alert rules with all attributes."
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.query_alert_rules
}

output "metric_alert_rules" {
  description = "Metric alert rules with all attributes."
  value       = azurerm_monitor_metric_alert.metric_alert_rules
}

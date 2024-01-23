variable "resource_group_name" {
  description = "Name of the resource group where the resources will be created."
  type        = string
}

variable "location" {
  description = "Location where the resources will be created."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all created resources."
  default     = {}
}

variable "action_groups" {
  type = list(object({
    name            = string,
    short_name      = string,
    email_receivers = list(object({ name = string, email_address = string }))
  }))
  default     = []
  description = <<EOT
    Deploys actions groups to Azure Monitor.
    action_group = {
      name            : "The name of the action group."
      short_name      : "The short name of the action group."
      email_receivers : "List of email recipients for the alert."
    }
  EOT
}

variable "query_alert_rules" {
  type = list(object({
    name                              = string,
    description                       = optional(string),
    enabled                           = bool,
    evaluation_frequency              = string,
    scope                             = string,
    severity                          = number,
    window_duration                   = string,
    auto_mitigation_enabled           = optional(bool, false),
    workspace_alerts_storage_enabled  = optional(bool, false),
    mute_actions_after_alert_duration = optional(string),
    query_time_range_override         = optional(string),
    skip_query_validation             = optional(bool, false),
    target_resource_types             = optional(set(string)),
    action_group_names                = set(string),
    action_custom_properties          = optional(map(string)),

    criteria = object({
      operator                = string,
      query                   = string,
      threshold               = number,
      time_aggregation_method = string,
      metric_measure_column   = optional(string),
      resource_id_column      = optional(string),

      dimension = optional(object({
        name     = string,
        operator = string,
        values   = set(string)
      })),

      failing_periods = optional(object({
        minimum_failing_periods_to_trigger_alert = number,
        number_of_evaluation_periods             = number
      }))
    })
  }))

  default     = []
  description = <<EOT
    Deploys query (log) alerts to Azure Monitor. The alert rule is provisioned using azurerm_monitor_scheduled_query_rules_alert_v2.
    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2
    query_alert_rule = {
      name                              : "The name of the scheduled query alert rule."
      description                       : "The description of the query alert rule."
      enabled                           : "Indicates if the alert is enabled."
      evaluation_frequency              : "How often the scheduled query alert rule is evaluated. Possible values are PT1M, PT5M, PT10M, PT15M, PT30M, PT45M, PT1H, PT2H, PT3H, PT4H, PT5H, PT6H, P1D."
      scopes                            : "The resource ID the alert rule is scoped to. The API currently supports exactly 1 resource ID in the scopes list."
      severity                          : "Severity of the alert. Possible values are 0, 1, 2, 3, 4 with 0 being the most severe."
      window_duration                   : "The period of time in ISO 8601 duration format on which the alert rule will be executed."
      auto_mitigation_enabled           : "Indicates whether the alert should be automatically resolved or not. Resolve the alert when the condition is not met anymore, and don't fire a new one until it's resolved."
      workspace_alerts_storage_enabled  : "Indicates whether to check if storage is configured."
      mute_actions_after_alert_duration : "Mute actions for the chosen period of time in ISO 8601 duration format after the alert is fired."
      query_time_range_override         : "Set this if the alert evaluation period is different from the query time range."
      skip_query_validation             : "Indicates whether the provided query should be validated or not."
      target_resource_types             : "List of resource types of the target resource(s) on which the alert is created/updated."
      action_group_name                 : "The name of the action group"
      action_custom_properties          : "Specifies the properties of an alert payload."
      criteria = {
        operator                : "The criteria operator. Possible values are Equal, GreaterThan, GreaterThanOrEqual, LessThan, and LessThanOrEqual."
        query                   : "The query to run on logs. The results returned by this query are used to populate the alert."
        threshold               : "The criteria threshold value that activates the alert."
        time_aggregation_method : "The type of aggregation to apply to the data points in aggregation granularity. Possible values are Average, Count, Maximum, Minimum, and Total."
        metric_measure_column   : "The column containing the metric measure number. Required if time_aggregation_method is Average, Minimum, Maximum, or Total."
        resource_id_column      : "The column containing the resource ID. The content of the column must be an uri formatted as resource ID."
      
        dimension = {
          name      : "Name of the dimension"
          operator  : "Operator for dimension values. Possible values are Exclude and Include.
          values    : "List of dimension values. Use a wildcard * to collect all.
        }
        falling_periods = {
          minimum_failing_periods_to_trigger_alert  : "The number of violations to trigger an alert. Should be smaller or equal to number_of_evaluation_periods. Possible value is integer between 1 and 6."
          number_of_evaluation_periods              : "The number of aggregated look-back points. The look-back time window is calculated based on the aggregation granularity window_duration and the selected number of aggregated points. Possible value is integer between 1 and 6."
        }
      }
    }
  EOT
}

variable "metric_alert_rules" {
  type = list(object({
    name                      = string,
    description               = optional(string),
    enabled                   = bool,
    scopes                    = set(string),
    auto_mitigate             = optional(bool, false),
    frequency                 = string,
    severity                  = number,
    target_resource_type      = optional(string),
    target_resource_location  = optional(string),
    window_size               = string,
    action_group_name         = string,
    action_webhook_properties = optional(map(string)),

    criteria = optional(object({
      metric_namespace       = string,
      metric_name            = string,
      aggregation            = string,
      operator               = string,
      threshold              = number,
      skip_metric_validation = optional(bool, false),

      dimension = optional(object({
        name     = string,
        operator = string,
        values   = set(string)
      }))
    }))

    dynamic_criteria = optional(object({
      metric_namespace         = string,
      metric_name              = string,
      aggregation              = string,
      operator                 = string,
      alert_sensitivity        = string,
      evaluation_total_count   = number,
      evaluation_failure_count = number,
      ignore_data_before       = optional(string),
      skip_metric_validation   = optional(bool, false),

      dimension = optional(object({
        name     = string,
        operator = string,
        values   = set(string)
      }))
    }))
  }))

  default     = []
  description = <<EOT
    Deploys metric alerts to Azure Monitor. The alert rule is provisioned using azurerm_monitor_metric_alert.
    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert
    metric_alert_rule = {
      name                      : "The name of the metric alert rule."
      description               : "The description of the metric alert rule."
      enabled                   : "Indicates if the alert is enabled."
      scopes                    : "A set of strings of resource IDs at which the metric criteria should be applied."
      auto_mitigate             : "Indicates if the alerts be auto resolved."
      frequency                 : "The evaluation frequency represented in ISO 8601 duration format. Possible values are PT1M, PT5M, PT15M, PT30M and PT1H."
      severity                  : "Severity of the alert. Possible values are 0, 1, 2, 3, 4 with 0 being the most severe."
      target_resource_type      : "The resource type of the target resource."
      target_resource_location  : "The location of the target resource."
      window_size               : "The period of time that is used to monitor alert activity. Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D."
      action_webhook_properties : "The map of custom string properties to include with the post operation. These data are appended to the webhook payload."
      criteria = {
        metric_namespace        : "One of the metric namespaces to be monitored."
        metric_name             : "One of the metric names to be monitored."
        aggregation             : "The statistic that runs over the metric values. Possible values are Average, Count, Minimum, Maximum and Total."
        operator                : "The criteria operator. Possible values are Equals, GreaterThan, GreaterThanOrEqual, LessThan and LessThanOrEqual."
        threshold               : "The criteria threshold value that activates the alert."
        skip_metric_evaluation  : "Skip the metric validation to allow creating an alert rule on a custom metric that isn't yet emitted?"
      
        dimension = {
          name      : "Name of the dimension"
          operator  : "Operator for dimension values. Possible values are Exclude and Include.
          values    : "List of dimension values. Use a wildcard * to collect all.
        }
      }
      dynamic_criteria = {
        metric_namespace          : "One of the metric namespaces to be monitored."
        metric_name               : "One of the metric names to be monitored."
        aggregation               : "The statistic that runs over the metric values. Possible values are Average, Count, Minimum, Maximum and Total."
        operator                  : "The criteria operator. Possible values are LessThan, GreaterThan and GreaterOrLessThan."
        alert_sensitivity         : "The extent of deviation required to trigger an alert. Possible values are Low, Medium and High."
        evaluation_total_count    : "The number of aggregated lookback points. The lookback time window is calculated based on the aggregation granularity (window_size) and the selected number of aggregated points."
        evaluation_failure_count  : "The number of violations to trigger an alert. Should be smaller or equal to evaluation_total_count."
        ignore_data_before        : "The ISO8601 date from which to start learning the metric historical data and calculate the dynamic thresholds."
        skip_metric_evaluation    : "Skip the metric validation to allow creating an alert rule on a custom metric that isn't yet emitted?"
      
        dimension = {
          name      : "Name of the dimension"
          operator  : "Operator for dimension values. Possible values are Exclude and Include.
          values    : "List of dimension values. Use a wildcard * to collect all.
        }
      }
    }
  EOT
}

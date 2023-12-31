############################
## Deploy Alerts WorkBook ##
############################
resource "azurerm_application_insights_workbook" "alerts_analyese" {
  name                = "ce314efa-fe06-402d-b98b-294a8d90a060"
  location            = var.location
  resource_group_name = var.resource_group_name
  display_name        = "Alerts_Analyses"
  data_json = jsonencode({
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 9,
      "content": {
        "version": "KqlParameterItem/1.0",
        "crossComponentResources": [
          "{Subscription}"
        ],
        "parameters": [
          {
            "id": "92e646b9-04fe-49b8-ae9c-cee454328024",
            "version": "KqlParameterItem/1.0",
            "name": "Subscription",
            "type": 6,
            "isRequired": true,
            "multiSelect": true,
            "quote": "'",
            "delimiter": ",",
            "typeSettings": {
              "additionalResourceOptions": [
                "value::1",
                "value::all"
              ],
              "includeAll": true
            },
            "timeContext": {
              "durationMs": 86400000
            },
            "defaultValue": "value::all",
            "value": [
              "/subscriptions/55f14124-5284-4924-9f3b-20a1b58ea068",
              "/subscriptions/c504f0ee-6e91-4e99-a4ef-780206c8899d",
              "/subscriptions/d1d64257-50ae-4f67-93f6-2d3a404e3563",
              "/subscriptions/2b5f23a9-08c4-44f1-8ec8-e3fb44256de9"
            ]
          },
          {
            "id": "88f789f4-125d-49f4-9edf-afe3f70e7d78",
            "version": "KqlParameterItem/1.0",
            "name": "TimeRange",
            "type": 4,
            "isRequired": true,
            "typeSettings": {
              "selectableValues": [
                {
                  "durationMs": 300000
                },
                {
                  "durationMs": 900000
                },
                {
                  "durationMs": 1800000
                },
                {
                  "durationMs": 3600000
                },
                {
                  "durationMs": 14400000
                },
                {
                  "durationMs": 43200000
                },
                {
                  "durationMs": 86400000
                },
                {
                  "durationMs": 172800000
                },
                {
                  "durationMs": 259200000
                },
                {
                  "durationMs": 604800000
                },
                {
                  "durationMs": 1209600000
                },
                {
                  "durationMs": 2419200000
                },
                {
                  "durationMs": 2592000000
                },
                {
                  "durationMs": 5184000000
                },
                {
                  "durationMs": 7776000000
                }
              ],
              "allowCustom": true
            },
            "timeContext": {
              "durationMs": 86400000
            },
            "value": {
              "durationMs": 5184000000
            }
          },
          {
            "id": "ee5e9c26-6ff6-4b8a-861d-0cd4d4665c35",
            "version": "KqlParameterItem/1.0",
            "name": "AlertTarget",
            "type": 2,
            "isRequired": true,
            "multiSelect": true,
            "quote": "'",
            "delimiter": ",",
            "query": "alertsmanagementresources\r\n| extend AlertTarget = tostring(properties.essentials.targetResourceType), MonitorService = tostring(properties.essentials.monitorService)\r\n| extend AlertTarget = case(\r\n        MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n        AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n        AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n        AlertTarget)\r\n| distinct AlertTarget",
            "crossComponentResources": [
              "{Subscription}"
            ],
            "typeSettings": {
              "additionalResourceOptions": [
                "value::1",
                "value::all"
              ]
            },
            "defaultValue": "value::all",
            "queryType": 1,
            "resourceType": "microsoft.resourcegraph/resources",
            "value": [
              "value::all"
            ]
          },
          {
            "id": "ae5dc3ff-60fb-46bf-acb5-b991faa0b6af",
            "version": "KqlParameterItem/1.0",
            "name": "Help",
            "label": "Show Help",
            "type": 10,
            "isRequired": true,
            "typeSettings": {
              "additionalResourceOptions": []
            },
            "jsonData": "[\r\n { \"value\": \"Yes\", \"label\": \"Yes\"},\r\n { \"value\": \"No\", \"label\": \"No\", \"selected\":true },\r\n { \"value\": \"Change Log\", \"label\": \"Change Log\"}\r\n]",
            "timeContext": {
              "durationMs": 86400000
            }
          }
        ],
        "style": "pills",
        "queryType": 0,
        "resourceType": "microsoft.resourcegraph/resources"
      },
      "name": "parameters - 2"
    },
    {
      "type": 11,
      "content": {
        "version": "LinkItem/1.0",
        "style": "tabs",
        "links": [
          {
            "id": "9f3aed5d-01d5-48cb-8a54-ad84fa223a24",
            "cellValue": "tab",
            "linkTarget": "parameter",
            "linkLabel": "Active Alerts",
            "subTarget": "active",
            "style": "link"
          },
          {
            "id": "acf71c82-4135-40c1-8850-0ebf9a58c29e",
            "cellValue": "tab",
            "linkTarget": "parameter",
            "linkLabel": "Alert Inventory",
            "subTarget": "inventory",
            "style": "link"
          }
        ]
      },
      "name": "links - 3"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "resources\r\n| where type =~ 'microsoft.insights/activitylogalerts'\r\n          or type =~ 'microsoft.alertsmanagement/smartdetectoralertrules'\r\n          or type =~ 'microsoft.insights/scheduledqueryrules'\r\n          or type =~ 'microsoft.insights/alertrules'\r\n          or type =~ 'microsoft.insights/metricalerts'\r\n| extend Enabled = iff(isnotnull(properties.state), properties.state, properties.enabled),\r\n                Severity = properties.severity,\r\n                AutoResolve = properties.autoMitigate,\r\n                Query = properties.source.query\r\n| extend Enabled = case(Enabled == \"Enabled\", \"true\", Enabled == \"Disabled\", \"false\", Enabled)\r\n| extend Condition = properties.criteria.allOf\r\n| extend Condition = properties.criteria.allOf\r\n| mv-expand Condition\r\n| extend AlertTarget = case(\r\n                properties.criteria contains 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria', 'App Insights',\r\n                type =~ 'microsoft.insights/activitylogalerts', 'ActivityLog',\r\n                type =~ 'microsoft.insights/components', 'App Insights',\r\n                type =~ 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n                type =~ 'microsoft.insights/scheduledqueryrules', 'Log Analytics',\r\n                type =~ 'microsoft.alertsmanagement/smartdetectoralertrules', 'App Insights',\r\n                type =~ 'microsoft.insights/components', 'App Insights',\r\n                Condition.metricNamespace =~ 'microsoft.insights/components', 'App Insights',\r\n                Condition.metricNamespace =~ 'Microsoft.OperationalInsights/workspaces', 'Log Analytics',\r\n                tolower(Condition.metricNamespace))\r\n| join kind=leftouter(\r\n              alertsmanagementresources \r\n                    | extend FireTime = todatetime(properties.essentials.startDateTime), \r\n                                    LastModifiedTime = todatetime(properties.essentials.lastModifiedDateTime),\r\n                                    MonitorCondition = tostring(properties.essentials.monitorCondition)\r\n                     | extend TimeOpen = iff(MonitorCondition == \"Resolved\", datetime_diff('minute', LastModifiedTime, FireTime), datetime_diff('minute', now(), FireTime))\r\n                     | where FireTime {TimeRange}\r\n                     | summarize count(), avg(TimeOpen) by name) \r\n              on name\r\n| extend TimesFired = iff(isnull(count_), 0, count_)\r\n| project-away name1, count_\r\n| extend Scopes = properties.scopes\r\n| extend TargetResource = todynamic(case(\r\n                 type =~ 'microsoft.insights/scheduledqueryrules', properties.source.dataSourceId,\r\n                 type =~ 'microsoft.alertsmanagement/smartdetectoralertrules', properties.scope, properties.scopes))\r\n| extend TargetResource = iff(isnull(TargetResource), Scopes, TargetResource)\r\n| mv-expand TargetResource\r\n| extend ActionGroup = todynamic(case( \r\n                 type =~ 'microsoft.alertsmanagement/smartdetectoralertrules', properties.actionGroups.groupIds, \r\n                 type =~ 'microsoft.insights/metricalerts', properties.actions, \r\n                 type =~ 'microsoft.insights/scheduledqueryrules', properties.action.aznsAction.actionGroup, \r\n                 type =~ 'microsoft.insights/activitylogalerts', properties.actions.actionGroups, '')) \r\n| mv-expand ActionGroup \r\n| extend ActionGroup = case(\r\n                 isnull(ActionGroup), 'No Action Group Assigned', \r\n                 isnotnull(ActionGroup.actionGroupId), tolower(ActionGroup.actionGroupId), \r\n                 tolower(ActionGroup)) \r\n| join kind=leftouter ( \r\n                 resources \r\n                       | where type =~ 'microsoft.insights/actiongroups'\r\n                       | extend Email = properties.emailReceivers \r\n                       | mv-expand Email = Email \r\n                       | summarize EmailList=make_list(Email.emailAddress) by ActionGroup=tolower(id)) \r\n                 on ActionGroup\r\n| extend AutoResolve = iff(isnull(AutoResolve), \"N/A\", AutoResolve),\r\nDetails = pack_all()\r\n| project id, name, TimesFired, TargetResource, subscriptionId, EmailList, Enabled, AutoResolve, Severity\r\n| sort by TimesFired desc\r\n",
              "size": 2,
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscription}"
              ],
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "$gen_group",
                    "formatter": 15,
                    "formatOptions": {
                      "linkTarget": null,
                      "showIcon": true
                    }
                  },
                  {
                    "columnMatch": "id",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "name",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "avg_TimeOpen",
                    "formatter": 8,
                    "formatOptions": {
                      "palette": "greenRed"
                    },
                    "numberFormat": {
                      "unit": 25,
                      "options": {
                        "style": "decimal"
                      }
                    }
                  },
                  {
                    "columnMatch": "TimesFired",
                    "formatter": 8,
                    "formatOptions": {
                      "palette": "greenRed"
                    }
                  },
                  {
                    "columnMatch": "TargetResource",
                    "formatter": 13,
                    "formatOptions": {
                      "linkTarget": null,
                      "showIcon": true
                    }
                  },
                  {
                    "columnMatch": "subscriptionId",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "Enabled",
                    "formatter": 18,
                    "formatOptions": {
                      "thresholdsOptions": "icons",
                      "thresholdsGrid": [
                        {
                          "operator": "==",
                          "thresholdValue": "true",
                          "representation": "success",
                          "text": "{0}{1}"
                        },
                        {
                          "operator": "Default",
                          "thresholdValue": null,
                          "representation": "disabled",
                          "text": "{0}{1}"
                        }
                      ]
                    }
                  }
                ],
                "hierarchySettings": {
                  "treeType": 1,
                  "groupBy": [
                    "subscriptionId"
                  ],
                  "expandTopLevel": true,
                  "finalBy": "name"
                }
              }
            },
            "name": "query - 0"
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tab",
        "comparison": "isEqualTo",
        "value": "inventory"
      },
      "name": "group - Alert Inventory"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n        MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n        AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n        AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n        AlertTarget)\r\n| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget})\r\n| extend Total = \"TotalAlerts\"\r\n| summarize TotalAlerts= count(MonitorCondition) by Total\r\n\r\n",
              "size": 4,
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscription}"
              ],
              "visualization": "tiles",
              "tileSettings": {
                "titleContent": {
                  "columnMatch": "Total",
                  "formatter": 18,
                  "formatOptions": {
                    "thresholdsOptions": "icons",
                    "thresholdsGrid": [
                      {
                        "operator": "==",
                        "thresholdValue": "Total",
                        "representation": "Alert",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "Default",
                        "thresholdValue": null,
                        "representation": "Alert",
                        "text": "{0}{1}"
                      }
                    ]
                  }
                },
                "leftContent": {
                  "columnMatch": "TotalAlerts",
                  "formatter": 12,
                  "formatOptions": {
                    "palette": "blue"
                  }
                },
                "showBorder": true
              },
              "graphSettings": {
                "type": 0
              }
            },
            "customWidth": "50",
            "name": "query - 0",
            "styleSettings": {
              "maxWidth": "15%"
            }
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n        MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n        AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n        AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n        AlertTarget)\r\n| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget})\r\n| summarize TotalAlerts= count() by MonitorCondition\r\n\r\n\r\n",
              "size": 4,
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscription}"
              ],
              "visualization": "tiles",
              "tileSettings": {
                "titleContent": {
                  "columnMatch": "MonitorCondition",
                  "formatter": 18,
                  "formatOptions": {
                    "thresholdsOptions": "icons",
                    "thresholdsGrid": [
                      {
                        "operator": "==",
                        "thresholdValue": "Fired",
                        "representation": "warning",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "==",
                        "thresholdValue": "Resolved",
                        "representation": "success",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "Default",
                        "thresholdValue": null,
                        "representation": "1",
                        "text": "{0}{1}"
                      }
                    ]
                  }
                },
                "leftContent": {
                  "columnMatch": "TotalAlerts",
                  "formatter": 12,
                  "formatOptions": {
                    "palette": "none"
                  }
                },
                "showBorder": true
              },
              "graphSettings": {
                "type": 0
              }
            },
            "customWidth": "50",
            "name": "query - 0 - Copy",
            "styleSettings": {
              "maxWidth": "30%"
            }
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n        MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n        AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n        AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n        AlertTarget)\r\n| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget})\r\n| summarize count() by Severity\r\n\r\n\r\n",
              "size": 4,
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscription}"
              ],
              "visualization": "tiles",
              "tileSettings": {
                "titleContent": {
                  "columnMatch": "Severity",
                  "formatter": 18,
                  "formatOptions": {
                    "thresholdsOptions": "icons",
                    "thresholdsGrid": [
                      {
                        "operator": "==",
                        "thresholdValue": "Sev0",
                        "representation": "Sev0",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "==",
                        "thresholdValue": "Sev1",
                        "representation": "Sev1",
                        "text": "{0}{1}"
                      },
                      {
                        "thresholdValue": "Sev2",
                        "representation": "Sev2",
                        "text": "{0}{1}"
                      },
                      {
                        "thresholdValue": "Sev3",
                        "representation": "Sev3",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "Default",
                        "thresholdValue": null,
                        "representation": "Sev4",
                        "text": "{0}{1}"
                      }
                    ]
                  }
                },
                "leftContent": {
                  "columnMatch": "count_",
                  "formatter": 12,
                  "formatOptions": {
                    "palette": "none"
                  }
                },
                "showBorder": true
              },
              "graphSettings": {
                "type": 0
              }
            },
            "customWidth": "50",
            "name": "query - 0 - Copy - Copy",
            "styleSettings": {
              "maxWidth": "65%"
            }
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         LastModifiedTime = todatetime(properties.essentials.lastModifiedDateTime),\r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService),\r\n         ResolvedTime = todatetime(properties.essentials.monitorConditionResolvedDateTime)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n                MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n                AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n                AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n                AlertTarget)   \r\n| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget})           \r\n| mv-expand Condition = properties.context.context.condition.allOf\r\n| extend SignalLogic = case(\r\n                MonitorService == \"VM Insights - Health\", strcat(\"VM Health for \", properties.essentials.targetResourceName, \" Changed from \", properties.context.monitorStateBeforeAlertCreated, \" to \", properties.context.monitorStateWhenAlertCreated),\r\n                AlertTarget == \"ActivityLog\", strcat(\"When the Activity Log has Category = \", properties.context.context.activityLog.properties.eventCategory, \" and Signal name = \", properties.context.context.activityLog.properties.message),\r\n                MonitorService == \"Smart Detector\", strcat(properties.SmartDetectorName, \" Detected failure rate of \", properties.DetectedFailureRate, \" above normal failure rate of \", properties.context.NormalFailureRate),\r\n                MonitorService == \"Log Analytics\", strcat(\"Alert when \", properties.context.AlertType, \" is \", properties.context.AlertThresholdOperator, \" threshold \", properties.context.AlertThresholdValue),\r\n                MonitorService == \"ActivityLog Autoscale\", strcat(properties.context.context.activityLog.operationName, \" from \", properties.context.context.activityLog.properties.oldInstancesCount, \" to \", properties.context.context.activityLog.properties.newInstancesCount),\r\n                strcat(\"Alert when metric \", Condition.metricName, Condition.timeAggregation, \" is \", Condition.operator, \" threshold \", Condition.threshold)),\r\n         Query = case(\r\n                 MonitorService == \"Log Alerts V2\", tostring(Condition.searchQuery),\r\n                 MonitorService == \"Log Analytics\", tostring(properties.context.SearchQuery), \"N/A\"),\r\n         MetricValue = iff(MonitorService == \"Log Analytics\", toint(properties.context.ResultCount), toint(Condition.metricValue)),\r\n         ResourceName = iff(AlertTarget == \"ActivityLog\", properties.context.context.activityLog.subscriptionId, tostring(properties.essentials.targetResourceName))\r\n| extend OpenTime = iff(MonitorCondition == \"Resolved\", datetime_diff('minute', ResolvedTime, FireTime), datetime_diff('minute', now(), FireTime)),\r\n         Details = pack_all()\r\n| project name, ResourceName, id, subscriptionId, AlertTarget, SignalLogic, FireTime, MonitorCondition",
              "size": 2,
              "showAnalytics": true,
              "title": "alerts in {TimeRange}",
              "noDataMessage": "No Alerts in the Assigned Time Range",
              "showExportToExcel": true,
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscription}"
              ],
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "$gen_group",
                    "formatter": 15,
                    "formatOptions": {
                      "linkTarget": "OpenBlade",
                      "linkIsContextBlade": true,
                      "showIcon": true,
                      "bladeOpenContext": {
                        "bladeName": "AlertDetailsTemplateBlade",
                        "extensionName": "Microsoft_Azure_Monitoring",
                        "bladeParameters": [
                          {
                            "name": "alertId",
                            "source": "column",
                            "value": "id"
                          },
                          {
                            "name": "alertName",
                            "source": "column",
                            "value": "name"
                          },
                          {
                            "name": "invokedFrom",
                            "source": "static",
                            "value": "Workbooks"
                          }
                        ]
                      }
                    }
                  },
                  {
                    "columnMatch": "name",
                    "formatter": 5,
                    "formatOptions": {
                      "linkTarget": "OpenBlade",
                      "linkIsContextBlade": true,
                      "bladeOpenContext": {
                        "bladeName": "AlertDetailsTemplateBlade",
                        "extensionName": "Microsoft_Azure_Monitoring",
                        "bladeParameters": [
                          {
                            "name": "alertId",
                            "source": "column",
                            "value": "id"
                          },
                          {
                            "name": "alertName",
                            "source": "column",
                            "value": "name"
                          },
                          {
                            "name": "invokedFrom",
                            "source": "static",
                            "value": "Workbooks"
                          }
                        ]
                      }
                    },
                    "tooltipFormat": {
                      "tooltip": "View alert details"
                    }
                  },
                  {
                    "columnMatch": "id",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "subscriptionId",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "MonitorCondition",
                    "formatter": 18,
                    "formatOptions": {
                      "thresholdsOptions": "icons",
                      "thresholdsGrid": [
                        {
                          "operator": "==",
                          "thresholdValue": "Fired",
                          "representation": "2",
                          "text": "{0}{1}"
                        },
                        {
                          "operator": "==",
                          "thresholdValue": "Resolved",
                          "representation": "success",
                          "text": "{0}{1}"
                        },
                        {
                          "operator": "Default",
                          "thresholdValue": null,
                          "representation": "success",
                          "text": "{0}{1}"
                        }
                      ]
                    }
                  },
                  {
                    "columnMatch": "FireTime",
                    "formatter": 6
                  },
                  {
                    "columnMatch": "LastModifiedTime",
                    "formatter": 6
                  },
                  {
                    "columnMatch": "OpenTime",
                    "formatter": 8,
                    "formatOptions": {
                      "palette": "greenRed"
                    }
                  }
                ],
                "rowLimit": 10000,
                "filter": true,
                "hierarchySettings": {
                  "treeType": 1,
                  "groupBy": [
                    "subscriptionId"
                  ],
                  "expandTopLevel": true,
                  "finalBy": "name"
                }
              }
            },
            "showPin": true,
            "name": "query - 1"
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tab",
        "comparison": "isEqualTo",
        "value": "active"
      },
      "name": "group - Active Alerts"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         LastModifiedTime = todatetime(properties.essentials.lastModifiedDateTime),\r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService),\r\n         ResolvedTime = todatetime(properties.essentials.monitorConditionResolvedDateTime)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n                MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n                AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n                AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n                AlertTarget)   \r\n| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget}) \r\n| extend OpenTime = datetime_diff('minute', now(), FireTime)\r\n| summarize avg(OpenTime) by Severity",
              "size": 4,
              "title": "Open Time by Severity",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "value::all"
              ],
              "visualization": "tiles",
              "tileSettings": {
                "titleContent": {
                  "columnMatch": "Severity",
                  "formatter": 18,
                  "formatOptions": {
                    "thresholdsOptions": "icons",
                    "thresholdsGrid": [
                      {
                        "operator": "==",
                        "thresholdValue": "Sev0",
                        "representation": "Sev0",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "==",
                        "thresholdValue": "Sev1",
                        "representation": "Sev1",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "==",
                        "thresholdValue": "Sev2",
                        "representation": "Sev2",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "==",
                        "thresholdValue": "Sev3",
                        "representation": "Sev3",
                        "text": "{0}{1}"
                      },
                      {
                        "operator": "Default",
                        "thresholdValue": null,
                        "representation": "Sev4",
                        "text": "{0}{1}"
                      }
                    ]
                  }
                },
                "leftContent": {
                  "columnMatch": "avg_OpenTime",
                  "formatter": 12,
                  "formatOptions": {
                    "min": 0,
                    "palette": "greenRed"
                  },
                  "numberFormat": {
                    "unit": 25,
                    "options": {
                      "style": "decimal",
                      "maximumFractionDigits": 2,
                      "maximumSignificantDigits": 3
                    }
                  }
                },
                "showBorder": true
              }
            },
            "name": "query - 1"
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         LastModifiedTime = todatetime(properties.essentials.lastModifiedDateTime),\r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService),\r\n         ResolvedTime = todatetime(properties.essentials.monitorConditionResolvedDateTime)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n                MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n                //AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n                //AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n                AlertTarget)   \r\n//| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget}) \r\n| extend OpenTime = datetime_diff('minute', now(), FireTime)\r\n| summarize avg(OpenTime) by AlertTarget",
              "size": 4,
              "title": "Top 5 Open Time by Target Resource Type",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "value::all"
              ],
              "visualization": "tiles",
              "tileSettings": {
                "titleContent": {
                  "columnMatch": "AlertTarget",
                  "formatter": 16,
                  "formatOptions": {
                    "showIcon": true
                  }
                },
                "leftContent": {
                  "columnMatch": "avg_OpenTime",
                  "formatter": 12,
                  "formatOptions": {
                    "min": 0,
                    "palette": "greenRed"
                  },
                  "numberFormat": {
                    "unit": 25,
                    "options": {
                      "style": "decimal",
                      "maximumFractionDigits": 2,
                      "maximumSignificantDigits": 3
                    }
                  }
                },
                "showBorder": true
              }
            },
            "name": "query - 1 - Copy - Copy"
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "alertsmanagementresources\r\n| extend FireTime = todatetime(properties.essentials.startDateTime), \r\n         LastModifiedTime = todatetime(properties.essentials.lastModifiedDateTime),\r\n         Severity = tostring(properties.essentials.severity), \r\n         MonitorCondition = tostring(properties.essentials.monitorCondition), \r\n         AlertTarget = tostring(properties.essentials.targetResourceType), \r\n         MonitorService = tostring(properties.essentials.monitorService),\r\n         ResolvedTime = todatetime(properties.essentials.monitorConditionResolvedDateTime),\r\n         TargetResource = tostring(properties.essentials.targetResource)\r\n| where FireTime {TimeRange}\r\n| extend AlertTarget = case(\r\n                MonitorService == 'ActivityLog Administrative', 'ActivityLog',\r\n                AlertTarget == 'microsoft.insights/components', 'App Insights',\r\n                AlertTarget == 'microsoft.operationalinsights/workspaces', 'Log Analytics', \r\n                AlertTarget)   \r\n| where AlertTarget in~ ({AlertTarget}) or '*' in~ ({AlertTarget}) \r\n| extend OpenTime = datetime_diff('minute', now(), FireTime)\r\n| summarize avg(OpenTime) by TargetResource\r\n| top 5 by avg_OpenTime\r\n| sort by avg_OpenTime desc",
              "size": 4,
              "title": "Top 5 Open Time by Target Resource",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "value::all"
              ],
              "visualization": "tiles",
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "TargetResource",
                    "formatter": 13,
                    "formatOptions": {
                      "linkTarget": null,
                      "showIcon": true
                    }
                  }
                ]
              },
              "tileSettings": {
                "titleContent": {
                  "columnMatch": "TargetResource",
                  "formatter": 13,
                  "formatOptions": {
                    "linkTarget": "Resource",
                    "showIcon": true
                  }
                },
                "leftContent": {
                  "columnMatch": "avg_OpenTime",
                  "formatter": 12,
                  "formatOptions": {
                    "min": 0,
                    "palette": "greenRed"
                  },
                  "numberFormat": {
                    "unit": 25,
                    "options": {
                      "style": "decimal",
                      "maximumFractionDigits": 2,
                      "maximumSignificantDigits": 3
                    }
                  }
                },
                "showBorder": true
              }
            },
            "name": "query - 1 - Copy - Copy - Copy"
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tab",
        "comparison": "isEqualTo",
        "value": "stats"
      },
      "name": "group - Stats"
    }
  ],
  "fallbackResourceIds": [
    "azure monitor"
  ],
  "$schema": "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
})
tags = local.common_tags
}
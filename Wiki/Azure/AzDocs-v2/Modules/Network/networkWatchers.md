# networkWatchers

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| networkWatcherName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the NetworkWatcher resource |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| networkWatcherName | string | Outputs the network watcher\'s resource name. |
| networkWatcherResourceId | string | Outputs the network watcher\'s resource id. |

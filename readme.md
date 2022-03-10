Returns the local ip addresses.
It parses:

- windows:
  - ipconfig
  - wmic
- unix:
  - ifconfig
  - ip a

```nim
import nimLocalIp
echo getLocalIps()
```

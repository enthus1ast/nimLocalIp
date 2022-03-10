Returns the local ip addresses.
It parses:

- windows:
  - ipconfig
- unix:
  - ifconfig
  - ip a

```nim
import nimLocalIp
echo getLocalIps()
```

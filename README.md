![](./tsockm_logo.png)

# TsockM

* The **LIGHTWEIGHT**, **FAST** and **PRIVACY FOCUSED** chatting program
    * p.s. communications are transmitted as plaintext 

## Prerequisits

* xorg-X11
    * `libX11-dlevel`
    * `libXcursor-dlevel`
    * `libXrandr-dlevel`
    * `libXinerama-dlevel`
* wayland
    * `wayland-dev` or `wayland-deval`

* OpenGL
    * `mesa-libGL-dlevel`

## Fedora 40 [RedHat]
* Install required libraries
```bash
sudo yum install wayland-devel.x86_64 libxkbcommon-devel.x86_64 mesa-libGL-devel.x86_64
```

## Quick Start
* Zig version at least `0.12.0`

* **SERVER**
```bash
zig build server -- <subcommand>
```
* **CLIENT**
```bash
zig build client -- <subcommand>
```

## Server

* The server portion of the application that handles communication between multiple client instances

### Protocol

* Communication between *server* and *client* is achived through the use of `TsockM.Protocol` 
* Protocol definition:
```
[type]::[action]::[status]::[origin]::[sender_id]::[src]::[dst]::[body]
```
* `[type]` defines the protocol type:
    * `REQ`: request protocol
    * `RES`: response protocol
    * `ERR`: error protocol
* `[action]` defines the action the protocol is performing
    * `COMM`: establishing a communication socket
    * `COMM_END`: terminate the communication socket
    * `MSG`: message handling 
    * `GET_PEER`: when pinging a peer
    * `NTFY_KILL`: reporting termination of a peer
* `[status]` defines the status code of the program (based on HTTP status codes)
    * `OK`: 200
    * `BAD_REQUEST`: 400
    * `NOT_FOUND`: 404
    * `METHOD_NOT_ALLOWED`: 405,
    * `BAD_GATEWAY`: 502,
* `[origin]` defines the status code of the program (based on HTTP status codes)
    * `CLIENT`: protocol comes from the client app
    * `SERVER`: protocol comes from the server
    * `UNKNOWN`: I don't know from where the protocol is comming from :)
* `[sender_id]` defines some unsigned integer value
    * Used when communicating the `sender id` value
    * Used when communicating the `error code` of an *error protocol*
* `[src]` defines the source of the protocol
    * *TBA*
* `[dst]` defines the destination address of the protocol
    * *TBA*
* `[body]` text data
    * used for sending a variaty of plaintext(for now) data

### TODO

#### 0.6.x
* [ ] {FEAT} encrypt body of the protocol
* [ ] {FEAT} store messages
#### 0.5.x
* [ ] {FEAT} PeerPool v2
    * Hash table approach
#### 0.4.5
* [x] {FIX} printing commands
#### 0.4.4
* [x] {TEST} `peer`
* [x] {UPDATE} make `Peer` more robust with more functions and quality of life things
#### 0.4.3
* [x] {TEST} `protocol`
* [x] {UPDATE} `core.zig` rename to `server.zig`
* [x] {TEST} `actioner`
* [x] {UPDATE} make `Protocol` more robust with more functions and quality of life things
* [x] {FIX} report unknown argument
* [x] {FEAT} ERROR protocol sent when peer was ping that does not exist
#### 0.3.0
* [x] {FEAT} Introduce server commands
* [x] {FEAT} Introduce server actions
* [x] {FEAT} `:mute` and `:unmute` server commands
#### 0.2.0
* [x] {FEAT} Server strcture
* [x] {FEAT} Consume program arguments:
    * `--log-level <level>` ... specify log level to be used
* [x] {UPDATE} introduce `thread_pool` 
* [x] {UPDATE} transform functions to be camel case as per zig standrad
* [x] {UPDATE} transform variables to be snake case as per zig standrad
* [x] {UPDATE} Unwrap Protocol structure file
* [x] {UPDATE} Unwrap Peer structure file
#### 0.2.x
* [ ] {BUG} notifying peer death does not work every time
* [ ] `peerFindUsernameMatch` find all peers with specific username
#### 0.1.0
* [x] send a notification to client when a peer gets terminated
* [x] Test message coloring
* [x] `:info` action for printing server stats (amount of peers connected, uptime, server-address, etc.)
* [x] `:ping <peer_username>` action for pinging the status of a peer
* [x] Thread shared data - Mutex and shared data between threads
* [x] Send periodic peer health check protocol ~ look for dead peers and remove them from the pool
* Executable commands on the server application
        * [x] `KILL <peer_id>` - removes a specific peer
        * [x] `KILL_ALL`       - removes all peers
        * [x] `LIST`           - prints relevant peer data
        * [x] `CC`             - Clear screen
* [x] Accept address as a variable when launching a server
* [x] Protocol should also contain `src` and `dest` IP addresses, socket form
* [x] Peer unique hash as ID 
* [x] Handle invalid *action* arguments
    * `KILL` - action must be provided with eather `<peer_id` or `all`, error otherwise 

## Client

* Application given to the user for chatting
    
### TODO

#### 0.6.x
* [ ] {FEAT} decrypt body of the protocol
* [ ] {UPADTE} removed depricated code
* [ ] {FEAT} custom messeging commands like `\c{RED};HELLO\` that applies special properties to text
    * `\b;HELLO\` prints bold text
    * `\u;HELLO\` prints underlined text
    * `\c{#00FFAA};HELLO\` prints colored text based on hex value 
* {FEAT} Client commands
    * [ ] `:ping` ~ ping user by username and print user info
* {FEAT} keybind list screen that shows all keybinds and their functionality 
* [ ] {UPDATE} `Input-Box` report when switching between `selection` and `insert` mode
* [ ] {UPDATE} `Input-Box` report deletion of text
* [ ] Introduce tests
* {FEAT} InputBox should have cursors
    * [ ] `SelectionCursor` move around text
    * [ ] `InsertCursor` place where char should be appended
#### 0.5.x
* [ ] {FEAT} Unit tests
* [ ] {BUG} when a message is sent to the server the server responds with `OK`, this should not be printed
* [ ] {BUG} message input box not in bounds (overflows)
* [ ] {BUG} client should respond with `OK` on `ping` ??
#### 0.4.8
* [x] {UPDATE} `INSERT` mode for input-box
* [x] {UPDATE} selection cursor movement ~ not all text selected at once
* [x] {UPDATE} Client FPS inforamtion
#### 0.4.7
* [x] {FEAT} `SimplePopup` multiposition support
* [x] {UPDATE} clean up and make popup hanling more robust
    * assert `popup.text.len > 0`, popups with no text should not be allowed
* [x] {BUG} input filed click detection too high for `server_ip_input`
* [x] {BUG} only two popups are displayed at a time, there should be more
* [x] {BUG} when `tab` is pressed and no ui element is selected the client crashes (LoginScreen)
* [x] {BUG} when client uses `:close` and reconnects and sends a message two messages are sent
#### 0.4.6
* [x] {UPDATE} `localhost` is a valid `server_ip_input` string that is mapped to `127.0.0.1`
* [x] {FEAT}   `:close` command that disconnects from the server and returns to the login screen
* [x] {UPDATE} `Input-Box` should hold font data to be used within the input box
* [x] {UPDATE} `Input-Box` should hold sizing information of the client
* [x] {FEAT}   `Input-Box` copying selected text support
#### 0.4.5
* [x] {UPDATE} Replace succesful connection screen with a popupdon't crash the the client wait for a connection to the server be available
* [x] {UPDATE} Input box should accept placeholder "ghost" text
* [x] {UPDATE} Input box should accept a label
* [x] {UPDATE} Switching active input using the TAB key inside `LoginScreen`
* [x] {UPDATE} TAB key enables messaging input if it is disabled `MessagingScreen`
* [x] {UPDATE} If no port is specified in `server_ip_input` assume port `6969`
* [x] {FEAT} `CTRL A` combination selects whole input box text 
* [x] {UPDATE} when `x` is pressed the selected text gets deleated
* [x] {UPDATE} when `enter` or `space` is pressed the exit `selection mode` 
* [x] {UPDATE} when `CTRL C` is pressed exit `selection mode`
#### 0.4.4
* [x] {UPDATE} don't allow login if login name is empy or ip is not defined
* [x] {UPDATE} ask for server ip before login
* [x] {UPDATE} report connection request blocked (unsuccessful conection)
* [x] {FEAT} server termination handler (bad-request::collectError)
#### 0.4.3
* {UPDATE} Multicolor support for message display
    * [x] `SimplePopup`
    * [x] `Message`
#### 0.4.1
* [x] {UPDATE} make `Action` and `Command` a shared library between server and client src code
* [x] {UPDATE} finish implementaton of `:exit` action ~ handle COMM_END response
#### 0.4.x
* [x] {FEAT} popups for warnings and errors
* [x] {FEAT} clipboard paste support
* {FEAT} `ClientScreen` ~ groups of related render/functionality code
    * [x] `LoginScreen`
    * [x] `MessagingScreen`
#### 0.3.0
* [x] {FEAT} print client termination
* {FEAT} Introduce `ClientActions`
    * [x] bad-request-action
    * [x] comm-action
    * [x] comm-end-action
    * [x] get-peer-action
    * [x] msg-action
    * [x] ntfy-kill-action
* [x] {FEAT} Introduce `ClientCommands`
#### 0.2.2
* [x] {FIX} when exiting duuring `connection succesful` the program deadlocks
* [x] {FEAT} consume `-fp` for setting location to the font 
* [x] {FEAT} consume `-F` start parameter to set scaling factor of the window
* [x] set client address source when sending things to the server
#### 0.2.x
* [x] {FEAT} read server adddress as program argument
#### 0.1.0
* [x] Consume peer termination notification and print it on screen
* [x] Test message coloring
* [x] Accept address as a variable when connecting a server
* [x] Use **Mutex** to share `should_exit` state between `read_cmd` and `listen_for_comms`
* [x] `:info` command to print information about the client instance

---

# References

* Raylib.zig: https://github.com/Not-Nik/raylib-zig

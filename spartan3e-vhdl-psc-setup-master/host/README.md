
# Serial client 

## Configuration 

First of all, set up your environment. If you are using board for this seminar, then defaults will work. 

```sh

export SERIAL_BAUDRATE=115200
export SERIAL_PARITY=N
export SERIAL_STOPBITS=1
export SERIAL_BYTESIZE=8
export SERIAL_TIMEOUT=1
export SERIAL_PORT=/dev/ttyUSB0

```

## Usage 


### List Available Serial Ports
To list all available serial ports on your system, use the following command:

```sh
python -m client list
```

### Get a Serial Port
To get a specific serial port for communication, use the following command:

```sh
python -m client get --port <port_name>
```

Replace `<port_name>` with the name of the serial port you want to use (e.g., `/dev/ttyUSB0`).

### Pipe Serial Port to Console
To pipe the serial port to the console (read and write simultaneously), use:

```sh
python -m client pipe --port <port_name>
```

### Read from Serial Port
To read data from a serial port and output it to the console, use:

```sh
python -m client read --port <port_name>
```

### Write to Serial Port
To write data to a serial port from the console, use:

```sh
python -m client write --port <port_name>
```

### Send File to Serial Port
To send the contents of a file to a serial port and output the returned data to the console, use:

```sh
python -m client --file <file_path> --port <port_name>
```

Replace `<file_path>` with the path to the file you want to send.

### Block Pipe (bpipe)
To send and receive data block by block to/from a serial port, use:

```sh
python -m client bpipe --read-size <read_size> --write-size <write_size> --port <port_name>
```

Replace `<read_size>` and `<write_size>` with the sizes of the blocks to read and write, respectively.

### Notes
- Replace `<port_name>` with the name of the serial port you want to use (e.g., `/dev/ttyUSB0`).
- If no port is specified, the program will prompt you to select one from the available ports.
- Ensure the environment variables in the **Configuration** section are set correctly before running these commands.
- Port can be also set in environment variable, see [Configuration](#configuration)


# ncurl - NETCONF URL Tool

A command-line utility for interacting with NETCONF devices, like curl but for NETCONF. Written in [Acton](https://www.acton-lang.org/), ncurl provides a simple interface for common NETCONF operations.

## Features

ncurl currently supports the following NETCONF operations:

- **get-config**: Retrieve configuration from a NETCONF datastore with optional filtering
- **list-schemas**: List all available schemas from a NETCONF server
- **get-schema**: Download individual or all schemas from a NETCONF server

## Installation

### Prerequisites

- [Acton](https://www.acton-lang.org/) programming language installed
- Network access to NETCONF-enabled devices

### Building

```bash
acton build
```

## Usage

### Basic Syntax

```bash
./ncurl [global-options] <command> [command-options]
```

### Global Options

- `--host <hostname>`: NETCONF server hostname (default: localhost)
- `--port <port>`: NETCONF server port (default: 42830)
- `--username <username>`: Username for authentication (default: admin)
- `--password <password>`: Password for authentication (default: admin)
- `--verbose`: Enable verbose logging for SSH/NETCONF client debugging

### Commands

#### List Schemas

List all available schemas from a NETCONF server:

```bash
./ncurl --host router.example.com list-schemas
```

#### Get Configuration

Retrieve configuration from a NETCONF datastore:

```bash
# Get entire running configuration
./ncurl --host router.example.com get-config

# Get startup configuration
./ncurl --host router.example.com get-config --source startup

# Apply subtree filter
./ncurl --host router.example.com get-config \
  --filter-subtree '<interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"/>'

# Apply XPath filter with namespaces
./ncurl --host router.example.com get-config \
  --filter-xpath '/if:interfaces/if:interface[if:name="eth0"]' \
  --xpath-namespaces 'if=urn:ietf:params:xml:ns:yang:ietf-interfaces'

# Save configuration to file
./ncurl --host router.example.com get-config --output config.xml

# Get configuration in JSON format
./ncurl --host router.example.com get-config --format json

# Get configuration as Acton GData
./ncurl --host router.example.com get-config --format acton-gdata
```

**Options:**
- `--source <datastore>`: Configuration datastore (running, startup, candidate) (default: running)
- `--filter-subtree <xml>`: XML subtree filter
- `--filter-xpath <expression>`: XPath expression for filtering
- `--xpath-namespaces <prefix=uri>`: Namespace declarations for XPath filtering (can be specified multiple times)
- `--format <format>`: Output format (raw-xml, xml, json, acton-gdata, acton-adata) (default: raw-xml)
- `--output <file>`: Output file (if not specified, prints to stdout)

#### Get Schema

Download schema(s) from a NETCONF server:

```bash
# Download a specific schema
./ncurl --host router.example.com get-schema ietf-interfaces

# Download a specific version
./ncurl --host router.example.com get-schema ietf-interfaces --version 2018-02-20

# Download all available schemas
./ncurl --host router.example.com get-schema all

# Specify output directory
./ncurl --host router.example.com get-schema all --output-dir yang-models

# Download in YIN format instead of YANG
./ncurl --host router.example.com get-schema ietf-interfaces --format yin
```

**Arguments:**
- `identifier`: Schema identifier or 'all' to download all schemas

**Options:**
- `--version <version>`: Schema version
- `--format <format>`: Schema format (yang or yin) (default: yang)
- `--output-dir <directory>`: Output directory for downloaded schemas (default: schemas)

## Examples

### Connect to a Cisco device and get interface configuration

```bash
./ncurl --host 192.168.1.1 --username cisco --password secret \
  get-config --filter-xpath '/interfaces/interface' \
  --output interfaces.xml
```

### Download all YANG models from a device

```bash
./ncurl --host 192.168.1.1 --username admin --password admin \
  get-schema all --output-dir device-models
```

### Debug connection issues

```bash
./ncurl --host 192.168.1.1 --verbose list-schemas
```

## Dependencies

ncurl is built using the following Acton libraries:
- [netconf](https://github.com/orchestron-orchestrator/netconf.git) - NETCONF client implementation
- [yang](https://github.com/orchestron-orchestrator/acton-yang.git) - YANG data modeling support


# ncurl - NETCONF URL Tool
[![REUSE Compliance Check](https://github.com/orchestron-orchestrator/ncurl/actions/workflows/reuse-compliance.yml/badge.svg)](https://github.com/orchestron-orchestrator/ncurl/actions/workflows/reuse-compliance.yml)

A command-line utility for interacting with NETCONF devices, like curl but for NETCONF. Written in [Acton](https://www.acton-lang.org/), ncurl provides a simple interface for common NETCONF operations.

## Features

ncurl currently supports the following NETCONF operations:

- **get-config**: Retrieve configuration from a NETCONF datastore with optional filtering
- **edit-config**: Edit configuration in a NETCONF datastore
- **list-schemas**: List all available schemas from a NETCONF server
- **get-schema**: Download individual or all schemas from a NETCONF server

## Installation

There are pre-built [binary releases](https://github.com/orchestron-orchestrator/ncurl/releases) for MacOS and Linux on x86_64 and aarch64 that you can download. ncurl is a single binary with no external dependencies.
- `curl -O https://github.com/orchestron-orchestrator/ncurl/releases/download/tip/ncurl-macos-aarch64.tar.gz` (or one of the other platforms / arch)
- `tar xvf ncurl-*.tar.gz`
- `chmod a+x ncurl`
- `./ncurl --help`

### Building

You can build ncurl yourself from source. First ensure you have the [Acton](https://www.acton-lang.org/) programming language installed, see [the install guide](https://acton.guide/install.html).

```bash
acton build
```

## Quick Start with notconf

The easiest way to test ncurl is using
[notconf](https://github.com/notconf/notconf), a NETCONF server for testing. The
published NETCONF server port (42830) and default credentials (admin/admin)
align with ncurl defaults:

```bash
# Start a notconf server
docker run -td --name notconf --rm --publish 42830:830 ghcr.io/notconf/notconf

# List available schemas (--insecure skips SSH host key verification for testing)
./ncurl --insecure list-schemas

# Get running configuration
./ncurl --insecure get-config
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
- `--insecure`: Skip SSH host key verification (useful for testing/development)
- `--verbose`: Enable verbose logging for SSH/NETCONF client debugging

**Note:** All examples use the `--insecure` flag to skip SSH host key verification. This is convenient for testing and development environments where devices may have self-signed certificates or changing host keys because of container restarts.

### Commands

#### List Schemas

List all available schemas from a NETCONF server:

```bash
./ncurl --insecure --host router.example.com list-schemas
```

#### Get Configuration

Retrieve configuration from a NETCONF datastore:

```bash
# Get entire running configuration
./ncurl --insecure --host router.example.com get-config

# Get startup configuration
./ncurl --insecure --host router.example.com get-config --source startup

# Apply subtree filter
./ncurl --insecure --host router.example.com get-config \
  --filter-subtree '<interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces"/>'

# Apply XPath filter with namespaces
./ncurl --insecure --host router.example.com get-config \
  --filter-xpath '/if:interfaces/if:interface[if:name="eth0"]' \
  --xpath-namespaces 'if=urn:ietf:params:xml:ns:yang:ietf-interfaces'

# Save configuration to file
./ncurl --insecure --host router.example.com get-config --output config.xml

# Get configuration in JSON format
./ncurl --insecure --host router.example.com get-config --format json

# Get configuration as Acton GData
./ncurl --insecure --host router.example.com get-config --format acton-gdata
```

**Options:**
- `--source <datastore>`: Configuration datastore (running, startup, candidate) (default: running)
- `--filter-subtree <xml>`: XML subtree filter
- `--filter-xpath <expression>`: XPath expression for filtering
- `--xpath-namespaces <prefix=uri>`: Namespace declarations for XPath filtering (can be specified multiple times)
- `--format <format>`: Output format (raw-xml, xml, json, acton-gdata, acton-adata) (default: raw-xml)
- `--output <file>`: Output file (if not specified, prints to stdout)

#### Edit Configuration

Edit configuration in a NETCONF datastore:

```bash
# Edit candidate configuration with XML from file
./ncurl --insecure --host router.example.com edit-config config.xml

# Edit running configuration directly
./ncurl --insecure --host router.example.com edit-config --target running config.xml

# Read configuration from stdin (end with two empty lines or Ctrl+D)
./ncurl --insecure --host router.example.com edit-config -

# Use replace operation instead of merge
./ncurl --insecure --host router.example.com edit-config --default-operation replace config.xml
```

**Arguments:**
- `config`: Configuration XML file path, or `-` to read from stdin

**Options:**
- `--target <datastore>`: Configuration datastore to edit (running, startup, candidate) (default: candidate)
- `--default-operation <operation>`: Default operation for config elements (merge, replace, none) (default: merge)

**Example Configuration XML:**
```xml
<interfaces xmlns="urn:ietf:params:xml:ns:yang:ietf-interfaces">
  <interface>
    <name>eth1</name>
    <description>Updated via ncurl</description>
    <enabled>true</enabled>
  </interface>
</interfaces>
```

#### Get Schema

Download schema(s) from a NETCONF server:

```bash
# Download a specific schema
./ncurl --insecure --host router.example.com get-schema ietf-interfaces

# Download a specific version
./ncurl --insecure --host router.example.com get-schema ietf-interfaces --version 2018-02-20

# Download all available schemas
./ncurl --insecure --host router.example.com get-schema all

# Specify output directory
./ncurl --insecure --host router.example.com get-schema all --output-dir yang-models

# Download in YIN format instead of YANG
./ncurl --insecure --host router.example.com get-schema ietf-interfaces --format yin
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


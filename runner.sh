#!/bin/sh
set -e

# =============================================================================
# FIPS and Java Configuration
# =============================================================================
# Environment variables for FIPS compliance:
#   JAVA_HOME              - Path to Java installation (default: system java)
#   TIKA_JAR_PATH          - Path to Tika server JAR (default: /app/tika-server-standard-3.2.3.jar)
#   TIKA_CONFIG_PATH       - Path to Tika config XML (default: /app/tika-config.xml)
#   JAVA_OPTS              - Additional JVM options for main process
#   TIKA_CLASSPATH         - Additional classpath entries (e.g., FIPS provider JARs)
#   TIKA_FORKED_JAVA_OPTS  - Additional JVM options for forked Tika processes
#   FIPS_MODE              - Set to "true" to enable FIPS mode logging
#
# Example FIPS configuration:
#   JAVA_HOME=/usr/lib/jvm/java-17-openjdk-fips
#   JAVA_OPTS="-Djava.security.properties=/app/fips.java.security"
#   TIKA_FORKED_JAVA_OPTS="-Djava.security.properties=/app/fips.java.security"
#   FIPS_MODE=true
# =============================================================================

# Default values
: "${JAVA_HOME:=}"
: "${TIKA_JAR_PATH:=/app/tika-server-standard-3.2.3.jar}"
: "${TIKA_CONFIG_PATH:=/app/tika-config.xml}"
: "${JAVA_OPTS:=}"
: "${TIKA_FORKED_JAVA_OPTS:=}"
: "${FIPS_MODE:=false}"

# Determine java command path for tika-config.xml
if [ -n "$JAVA_HOME" ]; then
  JAVA_CMD="$JAVA_HOME/bin/java"
else
  JAVA_CMD="java"
fi

# Export for use by openrc scripts
export JAVA_HOME TIKA_JAR_PATH TIKA_CONFIG_PATH JAVA_OPTS TIKA_CLASSPATH

# Log configuration
echo "=== Data Extraction Service Configuration ==="
echo "JAVA_CMD: $JAVA_CMD"
echo "TIKA_JAR_PATH: $TIKA_JAR_PATH"
echo "TIKA_CONFIG_PATH: $TIKA_CONFIG_PATH"
echo "JAVA_OPTS: ${JAVA_OPTS:-<not set>}"
echo "TIKA_CLASSPATH: ${TIKA_CLASSPATH:-<not set>}"
echo "TIKA_FORKED_JAVA_OPTS: ${TIKA_FORKED_JAVA_OPTS:-<not set>}"
echo "FIPS_MODE: $FIPS_MODE"
echo "=============================================="

# Update tika-config.xml with the correct javaPath for forked processes
# This is necessary because Tika spawns child processes using this path
if [ -f "$TIKA_CONFIG_PATH" ]; then
  # Update javaPath
  sed -i "s|<javaPath>.*</javaPath>|<javaPath>${JAVA_CMD}</javaPath>|g" "$TIKA_CONFIG_PATH"
  echo "Updated javaPath in $TIKA_CONFIG_PATH to: $JAVA_CMD"

  # Add additional forked JVM args if specified
  if [ -n "$TIKA_FORKED_JAVA_OPTS" ]; then
    # Convert space-separated opts to XML arg elements
    forked_args=""
    for opt in $TIKA_FORKED_JAVA_OPTS; do
      forked_args="${forked_args}        <arg>${opt}</arg>\n"
    done

    # Insert additional args before the closing </forkedJvmArgs> tag
    sed -i "s|</forkedJvmArgs>|${forked_args}      </forkedJvmArgs>|g" "$TIKA_CONFIG_PATH"
    echo "Added forked JVM args to $TIKA_CONFIG_PATH"
  fi
fi

# Clear OpenRC crashed/started state to allow fresh start
rc-service tika zap 2>/dev/null || true
rc-service openresty zap 2>/dev/null || true

echo "Service 'All': Status"
rc-status -a
rc-update add tika boot
rc-update add openresty boot

echo "Service 'Tika': Starting ..."
rc-service tika start

echo "Service 'Openresty': Starting ..."
rc-service openresty start

# keep alive (TODO convert to health check)
while true; do sleep 1; done


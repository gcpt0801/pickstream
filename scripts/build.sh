#!/bin/bash

# Build script for Random Names Web Application

set -e

echo "========================================="
echo "Building Random Names Web Application"
echo "========================================="

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "Error: Maven is not installed"
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed"
    exit 1
fi

echo ""
echo "Maven version:"
mvn -version

echo ""
echo "Java version:"
java -version

echo ""
echo "Cleaning previous builds..."
mvn clean

echo ""
echo "Building application..."
mvn package

if [ -f "target/pickstream.war" ]; then
    echo ""
    echo "========================================="
    echo "Build successful!"
    echo "WAR file location: target/pickstream.war"
    echo "========================================="
    ls -lh target/pickstream.war
else
    echo ""
    echo "========================================="
    echo "Build failed - WAR file not found"
    echo "========================================="
    exit 1
fi

#!/bin/bash

# Set the name of your container
container_name="jenkins"

# Command to execute once the container is running
command_to_execute="docker exec -it jenkins  /etc/init.d/jenkins start"

# Loop until the container status is "running"
while :; do
    # Get the current status of the container
    status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)

    # Check if the status is "running"
    if [ "$status" = "running" ]; then
        echo "Container is running. Executing command..."
        # Execute your command here
        $command_to_execute
        break # Exit the loop
    else
        echo "Waiting for container to run..."
        sleep 1 # Wait for a second before checking again
    fi
done

#!/bin/bash

# Read input variables
read -p "Enter Docker images (separated by space): " images_input
read -p "Enter registry URL: " registry
read -p "Enter tag for the images: " tag

# Convert input to array
images=($images_input)

# Loop through the images
for image in "${images[@]}"; do
    # Pull the image
    docker pull $image

    # Extract image name from repository (e.g., repository:tag -> repository)
    image_name=$(echo $image | cut -d: -f1)

    docker login $registry

    # Tag the image with the new registry and tag
    tagged_image="$registry/quayadmin/$image_name:$tag"
    docker tag $image $tagged_image

    # Push the tagged image to the registry
    docker push $tagged_image

    # Clean up: remove the pulled image and the locally tagged image
    docker rmi $image $tagged_image
done

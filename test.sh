docker run -it --rm \
  --mount type=image,source=volume:docker,destination=/opt/docker \
  --mount type=image,source=volume:node,destination=/opt/node \
  --mount type=image,source=volume:kubectl,destination=/opt/kubectl \
  --mount type=image,source=volume:opencode,destination=/opt/opencode \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  -v $PWD:/work \
  debian:dev

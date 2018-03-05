#!/bin/bash

docker run                        \
  --rm                            \
  -it                             \
  -v $(pwd)/test:/test            \
  brandocorp/chefdk-resource      \
  /bin/bash -i /test/func_test.sh
